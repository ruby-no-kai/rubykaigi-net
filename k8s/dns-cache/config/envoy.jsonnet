local upstream_tls_transport_socket(domain) =
  {
    name: 'envoy.transport_sockets.tls',
    typed_config: {
      '@type': 'type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext',
      common_tls_context: {
        validation_context: {
          trusted_ca: { filename: '/etc/ssl/certs/ca-certificates.crt' },
          match_typed_subject_alt_names: [
            {
              san_type: 'DNS',
              matcher: { exact: domain },
            },
          ],
        },
      },
      sni: domain,
    },
  };

local tls_certificate = {
  certificate_chain: { filename: '/secrets/tls-cert/tls.crt' },
  private_key: { filename: '/secrets/tls-cert/tls.key' },
};


local route_config = {
  virtual_hosts: [
    {
      name: 'default',
      domains: ['*'],
      routes: [
        {
          name: 'dns-query',
          match: {
            path: '/dns-query',
          },
          route: { cluster: 'unbound' },
        },
      ],
    },
  ],
};

local http_connection_manager(codec_type, stat_prefix) = {
  name: 'envoy.filters.network.http_connection_manager',
  typed_config: {
    '@type': 'type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager',
    codec_type: codec_type,
    stat_prefix: stat_prefix,
    use_remote_address: true,
    normalize_path: true,
    merge_slashes: true,
    path_with_escaped_slashes_action: 'UNESCAPE_AND_REDIRECT',
    common_http_protocol_options: {
      idle_timeout: '3600s',
      headers_with_underscores_action: 'REJECT_REQUEST',
    },
    http2_protocol_options: {
      max_concurrent_streams: 100,
      initial_stream_window_size: 65536,  // 64 KiB
      initial_connection_window_size: 1048576,  // 1 MiB
    },
    stream_idle_timeout: '300s',
    request_timeout: '300s',
    http_filters: [
      {
        name: 'envoy.filters.http.router',
        typed_config: {
          '@type': 'type.googleapis.com/envoy.extensions.filters.http.router.v3.Router',
        },
      },
    ],
    route_config: route_config,
    access_log: [
      {
        name: 'envoy.access_loggers.file',
        typed_config: {
          '@type': 'type.googleapis.com/envoy.extensions.access_loggers.file.v3.FileAccessLog',
          path: '/dev/stdout',
        },
      },
    ],
  },
};

{
  overload_manager: {
    refresh_interval: '0.25s',
    resource_monitors: [
      {
        name: 'envoy.resource_monitors.fixed_heap',
        typed_config: {
          '@type': 'type.googleapis.com/envoy.extensions.resource_monitors.fixed_heap.v3.FixedHeapConfig',
          max_heap_size_bytes: 524288000,  // 500MiB
        },
      },
    ],
    actions: [
      {
        name: 'envoy.overload_actions.shrink_heap',
        triggers: [
          {
            name: 'envoy.resource_monitors.fixed_heap',
            threshold: { value: 0.95 },
          },
        ],
      },
      {
        name: 'envoy.overload_actions.stop_accepting_requests',
        triggers: [
          {
            name: 'envoy.resource_monitors.fixed_heap',
            threshold: { value: 0.98 },
          },
        ],
      },
    ],
  },

  static_resources: {
    listeners: [
      {
        name: 'tcp',
        address: {
          socket_address: { protocol: 'TCP', address: '0.0.0.0', port_value: 11443 },
        },
        listener_filters: [
          {
            name: 'envoy.filters.listener.tls_inspector',
            typed_config: {
              '@type': 'type.googleapis.com/envoy.extensions.filters.listener.tls_inspector.v3.TlsInspector',
            },
          },
          {
            name: 'envoy.filters.listener.http_inspector',
            typed_config: {
              '@type': 'type.googleapis.com/envoy.extensions.filters.listener.http_inspector.v3.HttpInspector',
            },
          },
        ],
        per_connection_buffer_limit_bytes: 32768,  // 32 KiB
        filter_chains: [
          {
            transport_socket: {
              name: 'envoy.transport_sockets.tls',
              typed_config: {
                '@type': 'type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext',
                common_tls_context: {
                  tls_params: {
                    tls_minimum_protocol_version: 'TLSv1_3',
                  },
                  tls_certificates: [tls_certificate],
                  alpn_protocols: ['h2', 'http/1.1'],
                },
              },
            },
            filters: [
              http_connection_manager('AUTO', 'ingress_http_tcp'),
            ],
          },
        ],
      },
      {
        name: 'udp',
        address: {
          socket_address: { protocol: 'UDP', address: '0.0.0.0', port_value: 11443 },
        },
        udp_listener_config: {
          quic_options: {},
          downstream_socket_config: {
            prefer_gro: true,
          },
        },
        per_connection_buffer_limit_bytes: 32768,  // 32 KiB
        filter_chains: [
          {
            transport_socket: {
              name: 'envoy.transport_sockets.quic',
              typed_config: {
                '@type': 'type.googleapis.com/envoy.extensions.transport_sockets.quic.v3.QuicDownstreamTransport',
                downstream_tls_context: {
                  common_tls_context: {
                    tls_certificates: [tls_certificate],
                  },
                },
              },
            },
            filters: [
              http_connection_manager('HTTP3', 'ingress_http_udp'),
            ],
          },
        ],
      },
    ],
    clusters: [
      {
        name: 'unbound',
        connect_timeout: '0.25s',
        per_connection_buffer_limit_bytes: 32768,  // 32 KiB
        load_assignment: {
          cluster_name: 'unbound',
          endpoints: [
            {
              lb_endpoints: [
                {
                  endpoint: {
                    address: { socket_address: { address: '127.0.0.1', port_value: 10443 } },
                  },
                },
              ],
            },
          ],
        },
        transport_socket: upstream_tls_transport_socket('resolver.rubykaigi.net'),
        typed_extension_protocol_options: {
          'envoy.extensions.upstreams.http.v3.HttpProtocolOptions': {
            '@type': 'type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions',
            explicit_http_config: {
              http2_protocol_options: {
                initial_stream_window_size: 65536,  // 64 KiB
                initial_connection_window_size: 1048576,  // 1 MiB
              },
            },
          },
        },
      },
    ],
  },

  layered_runtime: {
    layers: [
      {
        name: 'static',
        static_layer: {
          envoy: {
            resource_limits: {
              listener: {
                tcp: { connection_limit: 2000 },
              },
            },
          },
          overload: {
            global_downstream_max_connections: 2000,
          },
        },
      },
    ],
  },
}

local s3_host = 'rk-tftp.s3.ap-northeast-1.amazonaws.com';
local route_config = {
  local s3 = {
    route: { cluster: 's3-tftp', timeout: '3600s' },
  },
  virtual_hosts: [
    {
      name: 'default',
      domains: ['*'],
      routes: [
        s3 {
          name: 'tftpboot',
          match: { prefix: '/tftpboot/' },
        },
        s3 {
          name: 'ro',
          match: { prefix: '/ro/' },
        },
      ],
      include_request_attempt_count: true,
      include_attempt_count_in_response: true,
      retry_policy: {
        retry_on: '5xx,connect-failure',
        num_retries: 2,
        per_try_timeout: '10s',
      },
    },
  ],
};

local access_log_json_format = {
  start_time: '%START_TIME%',
  method: '%REQ(:METHOD)%',
  path: '%REQ_WITHOUT_QUERY(X-ENVOY-ORIGINAL-PATH?:PATH)%',
  protocol: '%PROTOCOL%',
  response_code: '%RESPONSE_CODE%',
  response_flags: '%RESPONSE_FLAGS%',
  bytes_received: '%BYTES_RECEIVED%',
  bytes_sent: '%BYTES_SENT%',
  duration: '%DURATION%',
  upstream_service_time: '%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%',
  host: '%DOWNSTREAM_DIRECT_REMOTE_ADDRESS_WITHOUT_PORT%',
  xff: '%REQ(X-FORWARDED-FOR)%',
  ua: '%REQ(USER-AGENT)%',
  request_id: '%REQ(X-REQUEST-ID)%',
  authority: '%REQ(:AUTHORITY)%',
  upstream_host: '%UPSTREAM_HOST%',
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
        name: 'envoy.filters.http.aws_request_signing',
        typed_config: {
          '@type': 'type.googleapis.com/envoy.extensions.filters.http.aws_request_signing.v3.AwsRequestSigning',
          service_name: 's3',
          region: 'ap-northeast-1',
          host_rewrite: s3_host,
          use_unsigned_payload: true,
          match_excluded_headers: [
            { prefix: 'x-envoy' },
            { prefix: 'x-forwarded' },
            { exact: 'x-amzn-trace-id' },
          ],
          // Manually specifying to disable other providers
          credential_provider: {
            assume_role_with_web_identity_provider: {
              web_identity_token_data_source: { filename: '/var/run/secrets/eks.amazonaws.com/serviceaccount/token' },
              role_arn: 'arn:aws:iam::005216166247:role/NetTftp',
              role_session_name: 'envoy',
            },
          },
        },
      },
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
        name: 'envoy.access_loggers.stdout',
        typed_config: {
          '@type': 'type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog',
          log_format: {
            json_format: access_log_json_format,
            formatters: [
              {
                name: 'envoy.formatter.req_without_query',
                typed_config: {
                  '@type': 'type.googleapis.com/envoy.extensions.formatter.req_without_query.v3.ReqWithoutQuery',
                },
              },
            ],
          },
        },
      },
    ],
  },
};

{
  admin: {
    address: {
      socket_address: { address: '0.0.0.0', port_value: 9901 },
    },
  },
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
          socket_address: { protocol: 'TCP', address: '0.0.0.0', port_value: 11080 },
        },
        listener_filters: [
          {
            name: 'envoy.filters.listener.http_inspector',
            typed_config: {
              '@type': 'type.googleapis.com/envoy.extensions.filters.listener.http_inspector.v3.HttpInspector',
            },
          },
        ],
        per_connection_buffer_limit_bytes: 2097152,  // 2 MiB
        filter_chains: [
          {
            filters: [
              http_connection_manager('AUTO', 'ingress_http_tcp'),
            ],
          },
        ],
      },
    ],
    local upstream_tls_transport_socket(domains) =
      {
        name: 'envoy.transport_sockets.tls',
        typed_config: {
          '@type': 'type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext',
          common_tls_context: {
            validation_context: {
              trusted_ca: { filename: '/etc/ssl/certs/ca-certificates.crt' },
              match_typed_subject_alt_names: std.map(function(d) {
                san_type: 'DNS',
                matcher: { exact: d },
              }, domains),
            },
          },
          sni: domains[0],
        },
      },
    clusters: [
      {
        name: 's3-tftp',
        connect_timeout: '1s',
        per_connection_buffer_limit_bytes: 32768,  // 32 KiB
        type: 'STRICT_DNS',
        load_assignment: {
          cluster_name: 's3-tftp',
          endpoints: [
            {
              lb_endpoints: [
                {
                  endpoint: {
                    address: { socket_address: { address: s3_host, port_value: 443 } },
                  },
                },
              ],
            },
          ],
        },
        transport_socket: upstream_tls_transport_socket([s3_host, '*.s3.ap-northeast-1.amazonaws.com']),
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
                tcp: { connection_limit: 1000 },
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

{
  groups+: [
    {
      name: 'dns',
      rules: [
        {
          alert: 'DNSCacheTooManyServFail',
          expr: 'sum by (instance) (rate(unbound_answer_rcodes_total{rcode="SERVFAIL"}[1m])) / sum by (instance) (rate(unbound_answer_rcodes_total[1m])) > 0.10',
          'for': '5m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.instance}}: Unbound SERVFAIL > 10% for 5m',
          },
        },
        {
          alert: 'DNSCacheTooMany50x',
          expr: 'sum by (instance, envoy_http_conn_manager_prefix) (rate(envoy_http_downstream_rq_xx{envoy_http_conn_manager_prefix=~"ingress_http_.*",envoy_response_code_class="5"}[1m])) / sum by (instance, envoy_http_conn_manager_prefix) (rate(envoy_http_downstream_rq_xx{envoy_http_conn_manager_prefix=~"ingress_http_.*"}[1m])) > 0.1',
          'for': '5m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.instance}}: Envoy 50x > 10% for 5m',
          },
        },
      ],
    },
  ],
}

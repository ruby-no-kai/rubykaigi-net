[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'fluentd',
      annotations: {
        'service.beta.kubernetes.io/aws-load-balancer-nlb-target-type': 'ip',
        'service.beta.kubernetes.io/aws-load-balancer-scheme': 'internal',
        'service.beta.kubernetes.io/aws-load-balancer-manage-backend-security-group-rules': 'false',
        'service.beta.kubernetes.io/aws-load-balancer-healthcheck-protocol': 'HTTP',
        'service.beta.kubernetes.io/aws-load-balancer-healthcheck-port': '10068',
        'service.beta.kubernetes.io/aws-load-balancer-healthcheck-path': '/healthz',
        'service.beta.kubernetes.io/aws-load-balancer-healthcheck-timeout': '3',
        'service.beta.kubernetes.io/aws-load-balancer-healthcheck-interval': '3',
        'service.beta.kubernetes.io/aws-load-balancer-target-group-attributes': 'deregistration_delay.timeout_seconds=10,deregistration_delay.connection_termination.enabled=true',
      },
    },
    spec: {
      type: 'LoadBalancer',
      loadBalancerClass: 'service.k8s.aws/nlb',
      selector: {
        'rubykaigi.org/app': 'syslog-fluentd',
      },
      ports: [
        { name: 'syslog', port: 514, targetPort: 'syslog', protocol: 'UDP' },
      ],
    },
  },
]

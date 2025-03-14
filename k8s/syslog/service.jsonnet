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
        'service.beta.kubernetes.io/aws-load-balancer-healthcheck-path': '/api/plugins.json',
        'service.beta.kubernetes.io/aws-load-balancer-target-group-attributes': 'deregistration_delay.timeout_seconds=10,deregistration_delay.connection_termination.enabled=true',
        'service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags': 'Project=rk25net,Component=syslog',
        'service.beta.kubernetes.io/aws-load-balancer-subnets': 'subnet-03b83376cdff5f681,subnet-04459368f75060d34',
        'service.beta.kubernetes.io/aws-load-balancer-private-ipv4-addresses': '10.33.136.14,10.33.152.14',

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
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'fluentd-forward',
    },
    spec: {
      type: 'ClusterIP',
      selector: {
        'rubykaigi.org/app': 'syslog-fluentd',
      },
      ports: [
        { name: 'forward', port: 24224, targetPort: 24224, protocol: 'TCP' },
      ],
    },
  },
]

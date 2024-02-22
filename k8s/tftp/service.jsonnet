{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 's3tftpd',
    annotations: {
      'service.beta.kubernetes.io/aws-load-balancer-nlb-target-type': 'ip',
      'service.beta.kubernetes.io/aws-load-balancer-scheme': 'internal',
      'service.beta.kubernetes.io/aws-load-balancer-manage-backend-security-group-rules': 'false',
      'service.beta.kubernetes.io/aws-load-balancer-healthcheck-protocol': 'HTTP',
      'service.beta.kubernetes.io/aws-load-balancer-healthcheck-port': '8080',
      'service.beta.kubernetes.io/aws-load-balancer-healthcheck-path': '/ping',
      'service.beta.kubernetes.io/aws-load-balancer-target-group-attributes': 'deregistration_delay.timeout_seconds=10,deregistration_delay.connection_termination.enabled=true',
      'service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags': 'Project=rk24net,Component=tftp',
    },

  },
  spec: {
    type: 'LoadBalancer',
    loadBalancerClass: 'service.k8s.aws/nlb',
    selector: {
      'rubykaigi.org/app': 's3tftpd',
    },
    ports: [
      { name: 'tftp', port: 69, targetPort: 'tftp', protocol: 'UDP' },
    ],
  },
}

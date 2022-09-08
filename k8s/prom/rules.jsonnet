[
  {
  apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PrometheusRule',
    metadata: {
      name: 'common-rules',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: std.foldl(
      function(a, b) a + b,
      [
        import './rules/aws_ec2.libsonnet',
        import './rules/aws_elb.libsonnet',
        import './rules/aws_nat.libsonnet',
        import './rules/aws_rds.libsonnet',
        import './rules/cloudwatch.libsonnet',
        import './rules/snmp.libsonnet',
      ],
      {},
    ),
  }
]

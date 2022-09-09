{
  groups+: [
    {
      name: 'alb_5xx',
      rules: [
        {
          alert: 'AwsAlbTarget5xx',
          expr: 'sum by(load_balancer,target_group) (aws_applicationelb_httpcode_target_5_xx_count_sum{target_group=~".+"} offset 2m) > 0',
          'for': '4m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.load_balancer}} (target={{$labels.target_group}}): Target 5xx > 0; 5m+ ({{$value}})',
          },
        },
        {
          alert: 'AwsAlb5xx',
          expr: 'sum by(load_balancer) (aws_applicationelb_httpcode_elb_5_xx_count_sum offset 2m) > 0',
          'for': '4m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.load_balancer}}: ELB 5xx > 0; 5m+ ({{$value}})',
          },
        },
      ],
    },
  ],
}

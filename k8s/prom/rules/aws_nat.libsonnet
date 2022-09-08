{
  groups+: [
    {
      name: 'awsnat_errors',
      rules: [
        {
          alert: 'AwsNatPortAllocErrorsWarn',
          expr: 'aws_natgateway_error_port_allocation_sum offset 6m > 0',
          labels: {
            severity: 'warn',
          },
          annotations: {
            summary: '{{$labels.nat_gateway_id}}: Port allocation had failed ({{$value}})',
          },
        },
        {
          alert: 'AwsNatPortAllocErrors',
          expr: 'aws_natgateway_error_port_allocation_sum offset 6m > 0',
          'for': '15m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.nat_gateway_id}}: Port allocation is failing 15m+ ({{$value}})',
          },
        },
      ],
    },
  ],
}

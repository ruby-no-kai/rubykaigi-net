{
  groups+: [
    {
      name: 'ec2_cpucredits',
      rules: [
        {
          alert: 'AwsEc2CpuCredits50',
          expr: 'aws_ec2_cpucredit_balance_maximum offset 6m < 50',
          'for': '5m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.instance_id}}: CPU credits balance < 50 ({{$value}})',
          },
        },
        {
          alert: 'AwsEc2CpuSurplusCharged',
          expr: 'aws_ec2_cpusurplus_credits_charged_minimum offset 6m > 0',
          'for': '15m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.instance_id}}: CPU surplus credits charged 15m+',  //
          },
        },
      ],
    },
    {
      name: 'ec2_statuscheck',
      rules: [
        {
          alert: 'AwsEc2ImpairedSystem',
          expr: 'aws_ec2_status_check_failed_maximum offset 6m < 1',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.instance_id}}: System Impaired',
          },
        },
        {
          alert: 'AwsEc2ImpairedInstance',
          expr: 'aws_ec2_status_check_failed_instance_maximum offset 6m < 1',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.instance_id}}: Instance Impaired',  //
          },
        },
      ],
    },
    {
      name: 'ebs_burstcredits',
      rules: [
        {
          alert: 'AwsEbsBurstCredits40',
          expr: 'aws_ebs_burst_balance_maximum offset 6m < 40',
          'for': '6m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.volume_id}}: EBS burst credits balance < 40 ({{$value}})',
          },
        },
      ],
    },
  ],
}

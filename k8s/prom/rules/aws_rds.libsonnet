{
  groups+: [
    {
      name: 'rds_memory',
      rules: [
        {
          alert: 'AwsRdsFreeableMemory200M',
          expr: 'aws_rds_freeable_memory_sum offset 6m < 200000000',
          labels: {
            severity: 'warn',
          },
          annotations: {
            summary: '{{$labels.dbinstance_identifier}}: RDS Freeable Memory < 200MB ({{$value}})',
          },
        },
      ],
    },
  ],
}

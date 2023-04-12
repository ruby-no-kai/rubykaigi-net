local u = import './util.libsonnet';

{
  region: 'ap-northeast-1',
  period_seconds: 60,
  delay_seconds: 120,
  metrics: (
    u.product([
      [
        {
          aws_namespace: 'AWS/ApplicationELB',
          aws_dimensions: ['LoadBalancer', 'AvailabilityZone', 'TargetGroup'],
        },
      ],
      u.product([
        [
          { aws_statistics: ['Average', 'Minimum', 'Maximum'] },
          { aws_extended_statistics: ['p50', 'p95', 'p99'] },
        ],
        std.map(
          function(metric) { aws_metric_name: metric },
          [
            'TargetResponseTime',
          ],
        ),
      ]) +
      u.product([
        [
          { aws_statistics: ['Sum'] },
        ],
        std.map(
          function(metric) { aws_metric_name: metric },
          [
            'RequestCount',
            'NewConnectionCount',
            'HTTPCode_Target_5XX_Count',
            'HTTPCode_Target_4XX_Count',
            'HTTPCode_Target_3XX_Count',
            'HTTPCode_Target_2XX_Count',
            'HTTPCode_ELB_5XX_Count',
            'HTTPCode_ELB_4XX_Count',
          ],
        ),

      ]),
    ])
  ),
}

{
  groups+: [
    {
      name: 'cloudprober',
      rules: [
        {
          alert: 'HighPacketLossRate',
          expr: '1 - rate(cloudprober_success{probe=~"ping[46]"}[1m]) / rate(cloudprober_total{probe=~"ping[46]"}[1m]) > 0.30',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.probe}} loss > 30%: {{$labels.instance}} -> {{$labels.dst}}',
          },
        },
      ],
    },
  ],
}

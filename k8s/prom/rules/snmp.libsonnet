{
  groups+: [
    {
      name: 'snmp',
      rules: [
        {
          alert: 'SnmpTargetDown',
          expr: 'up{job=~"^.*/snmp-.*$"} == 0',
          'for': '1m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.instance}}: SNMP Target Down',
          },
        },
      ],
    },
  ],
}

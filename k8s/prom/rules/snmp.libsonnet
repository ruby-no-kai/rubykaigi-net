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
        {
          alert: 'SnmpRebootDetected',
          expr: 'resets(sysUpTime[5m]) > 0',
          labels: {
            severity: 'warning',
          },
          annotations: {
            summary: 'Rebooted within 5m',
          },
        },
        {
          alert: 'IXSystemUtilization',
          expr: 'picoSchedRtUtl1Min > 70',
          'for': '10m',
          labels: {
            severity: 'warning',
          },
          annotations: {
            summary: 'System utilization >70% for 10m',
          },
        },
        {
          alert: 'IXSystemUtilization',
          expr: 'picoSchedRtUtl1Min > 80',
          'for': '5m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: 'System utilization >80% for 5m',
          },
        },
      ],
    },
  ],
}

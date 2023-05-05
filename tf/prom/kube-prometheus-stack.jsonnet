local volumeClaimTemplate(size) = {
  spec: {
    storageClassName: 'gp2',
    accessModes: ['ReadWriteOnce'],
    resources: {
      requests: {
        storage: size,
      },
    },
  },
};


{
  cleanPrometheusOperatorObjectNames: true,
  prometheusOperator: {
  },
  prometheus: {
    prometheusSpec: {
      resources: {
        requests: {
          cpu: '100m',
          memory: '2048M',
        },
      },
      storageSpec: {
        volumeClaimTemplate: volumeClaimTemplate('100Gi'),
      },

      scrapeInterval: '20s',
      scrapeTimeout: '15s',
      evaluationInterval: '20s',

      retention: '720h',
    },
  },
  alertmanager: {
    config: {
      global: {
        slack_api_url_file: '/etc/alertmanager/secrets/alertmanager-slack-webhook/url',
      },
      route: {
        routes: [
          // {
          //   matchers: [
          //     'severity=~"warning|critical"',
          //   ],
          //   group_by: ['alertname', 'job'],
          //   group_wait: '12s',
          //   group_interval: '12s',
          //   repeat_interval: '1h',
          //   receiver: 'slack-default',
          // },
        ],
        receiver: 'null',
      },
      receivers: [
        {
          name: 'null',
        },
        {
          name: 'slack-default',
          slack_configs: [
            {
              send_resolved: true,
              title_link: 'https://grafana.rubykaigi.net/alerting/list?view=state&dataSource=Prometheus&queryString=alertname%3D{{ .GroupLabels.alertname | urlquery }}',
              title: '{{ .GroupLabels.alertname }}{{ with .GroupLabels.job }} - {{ . }}{{ end }}',
              text: '{{ range .Alerts }}*{{ .Status }}* {{ with .Labels.instance }}{{ . }} - {{ end }}{{ .Annotations.summary }}\n{{ end }}',
            },
          ],
        },
      ],
    },
    alertmanagerSpec: {
      resources: {
        requests: {
          cpu: '5m',
          memory: '64M',
        },
      },
      storage: {
        volumeClaimTemplate: volumeClaimTemplate('10Gi'),
      },
      secrets: [
        'alertmanager-slack-webhook',
      ],
      retention: '720h',
    },
  },
  'prometheus-node-exporter': {
    resources: {
      requests: {
        cpu: '5m',
        memory: '16M',
      },
    },
  },
  grafana: {
    enabled: false,
  },

  defaultRules: {
    rules: {
      general: false,
      kubeControllerManager: false,
      kubeScheduler: false,
    },
  },
  kubeControllerManager: { enabled: false },
  kubeScheduler: { enabled: false },

  'kube-state-metrics': {
    metricLabelsAllowlist: [
      'nodes=[kubernetes.io/arch,topology.kubernetes.io/region,topology.kubernetes.io/zone,node-group.k8s.cookpad.com/name]',
      'pods=[pod-template-hash,rubykaigi.org/app]',
      'replicasets=[pod-template-hash,rubykaigi.org/app]',
      'deployments=[rubykaigi.org/app]',
    ],
  },
}

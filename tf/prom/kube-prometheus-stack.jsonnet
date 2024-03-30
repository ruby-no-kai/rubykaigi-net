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

      additionalScrapeConfigs: [
        {
          job_name: 'cloudprober',
          dns_sd_configs: [{
            names: ['_prometheus._http.cloudprober.rubykaigi.net'],
          }],
        },
      ],
    },
  },
  alertmanager: {
    config: {
      global: {
        slack_api_url_file: '/etc/alertmanager/secrets/alertmanager-slack-webhook/url',
      },
      route: {
        routes: [
          {
            matchers: [
              'severity=~"warning|critical"',
              'send_resolved="false"',
            ],
            group_by: ['alertname'],
            group_wait: '12s',
            group_interval: '12s',
            repeat_interval: '1h',
            receiver: 'slack-without-resolved',
          },
          {
            matchers: [
              'severity=~"warning|critical"',
            ],
            group_by: ['alertname'],
            group_wait: '12s',
            group_interval: '12s',
            repeat_interval: '1h',
            receiver: 'slack-default',
          },
        ],
        receiver: 'null',
      },
      receivers:
        local slack_config = {
          send_resolved: true,
          title_link: 'https://grafana.rubykaigi.net/alerting/list?view=state&dataSource=Prometheus&queryString=alertname%3D{{ .GroupLabels.alertname | urlquery }}',
          title: '{{ .GroupLabels.alertname }}',
          text: '{{ range .Alerts }}*{{ .Status }}* {{ with .Labels.instance }}{{ . }} - {{ end }}{{ .Annotations.summary }}\n{{ end }}',
        }; [
          {
            name: 'null',
          },
          {
            name: 'slack-default',
            slack_configs: [
              slack_config { send_resolved: true },
            ],
          },
          {
            name: 'slack-without-resolved',
            slack_configs: [
              slack_config { send_resolved: false },
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
    tolerations: [  // TODO: onpremises nodes
      // {
      //   effect: 'NoSchedule',
      //   operator: 'Exists',
      // },
    ],
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

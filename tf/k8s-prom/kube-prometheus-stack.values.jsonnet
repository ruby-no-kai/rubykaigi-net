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
      storageSpec: {
        volumeClaimTemplate: volumeClaimTemplate('100Gi'),
      },
      retention: '720h',
    },
  },
  alertmanager: {
    config: {
    },
    alertmanagerSpec: {
      storage: {
        volumeClaimTemplate: volumeClaimTemplate('10Gi'),
      },
      retention: '720h',
    },
  },
  grafana: {
    enabled: false,
  },

  defaultRules: {
    rules: {
      kubeControllerManager: false,
      kubeScheduler: false,
    },
  },
  kubeControllerManager: { enabled: false },
  kubeScheduler: {enabled: false },
}

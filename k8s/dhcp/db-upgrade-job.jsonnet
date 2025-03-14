local pod = (import './pod.libsonnet') {
  app_container+:: {
    resources: {
      requests: {
        cpu: '64m',
        memory: '20M',
      },
    },
    command: ['/app/db-upgrade.rb'],
    env+: [
      { name: 'AWS_REGION', value: 'ap-northeast-1' },
      { name: 'KEA_ADMIN_DB_USER', value: 'kea-admin' },
    ],
  },
  spec+: {
    restartPolicy: 'Never',
    serviceAccountName: 'kea',
  },
};

// dummy cron job for 'kubectl create job --from=cronjob/kea-dhcp-upgrade kea-dhcp-upgrade-$(TZ=Etc/UTC date +%Y%m%d-%H%M%S)'
{
  apiVersion: 'batch/v1',
  kind: 'CronJob',
  metadata: {
    name: 'kea-dhcp-upgrade',
    namespace: 'default',
  },
  spec: {
    schedule: '0 * * * *',
    suspend: true,
    jobTemplate: {
      spec: {
        template: {
          spec: pod.spec,
        },
      },
    },
  },
}

{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'trapbridge-config',
  },
  data: {
    // //tf/trapbridge/gen-mibs.rb
    'mibs.json': importstr './config/mibs.json',
    'config.json': importstr './config/config.json',
  },
}

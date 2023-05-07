// tf/tftp contains permanent s3 bucket so I'd like to avoid strong dependency on k8s
{
  apiVersion: 'v1',
  kind: 'ServiceAccount',
  metadata: {
    annotations: {
      'eks.amazonaws.com/role-arn': 'arn:aws:iam::005216166247:role/NetTftp',
      'eks.amazonaws.com/sts-regional-endpoints': 'true',
    },
    name: 's3tftpd',
    namespace: 'default',
  },
}

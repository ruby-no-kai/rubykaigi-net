{
  apiVersion: 'storage.k8s.io/v1',
  kind: 'StorageClass',
  metadata: {
    name: 'gp3',
  },
  parameters: {
    fsType: 'ext4',
    type: 'gp3',
    tagSpecification_1: 'Project=rk25net',
    tagSpecification_2: 'Component=k8s',
    tagSpecification_3: 'Role=k8s/pvc',
    tagSpecification_4: 'Name=rknet-k8s-{{ .PVCNamespace }}-{{ .PVCName }}-{{ .PVName }}',
  },
  provisioner: 'ebs.csi.aws.com',
  reclaimPolicy: 'Delete',
  volumeBindingMode: 'WaitForFirstConsumer',
}

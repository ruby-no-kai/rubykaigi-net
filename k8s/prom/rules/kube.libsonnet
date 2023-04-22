{
  groups+: [
    {
      name: 'kube',
      rules: [
        {
          record: 'kube:pods_with_zone:ready',
          expr: 'max by (namespace, pod, uid) (kube_pod_status_ready{condition="true"}) * on(uid) group_left(node, pod_ip) max by (uid, pod_ip, node) (kube_pod_info) * on(node) group_left(label_topology_kubernetes_io_zone) max by (node, label_topology_kubernetes_io_zone) (kube_node_labels)',
        },
      ],
    },
  ],
}

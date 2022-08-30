output "node_security_group" {
  value = module.cluster.config.node_security_group
}

output "cluster_config" {
  value = module.cluster.config
}

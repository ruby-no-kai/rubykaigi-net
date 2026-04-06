local cloud_config = (import '../cloudconfig.base.libsonnet') + {
};

{
  cloud_config: cloud_config,
  user_data: std.format('#cloud-config\n%s\n', std.manifestYamlDoc(cloud_config)),
}

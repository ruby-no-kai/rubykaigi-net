namespace :gen do
  desc 'Generate Kubernetes manifests'
  task :k8s do
    sh './gen-k8s.rb'
  end

  desc 'Generate hosts.json'
  task :hosts do
    sh './gen-hosts.rb'
  end

  desc 'Generate GitHub Actions workflows'
  task :workflows do
    sh './gen-workflows.rb'
  end
end

namespace :vendor do
  desc 'Vendor jsonnet packages'
  task :jsonnet do
    sh 'jb', 'install', '--jsonnetpkg-home=vendor/jb'
  end
end

#!/usr/bin/env ruby
=begin
Usage: rka ./misc/update_kubeconfig.rb [/path/to/kubeconfig]
See also https://scrapbox.io/rknet/AWS
=end
require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'aws-sdk-eks'
  gem 'yaml'
end

REGION = 'ap-northeast-1'
CLUSTER = 'rknet'
ROLE = 'arn:aws:iam::005216166247:role/NocAdmin'
MAIRU_SERVER = 'rubykaigi'
NICK = 'rknet'

kubeconfig = ARGV[0] || File.expand_path('~/.kube/config')

config = YAML.load_file(kubeconfig)
%w[clusters users contexts].each do |key|
  config[key].reject! { |it| it['name'] == NICK }
end

cluster = Aws::EKS::Client.new(region: REGION).describe_cluster(name: CLUSTER).cluster

config['clusters'] << {
  'name' => NICK,
  'cluster' => {
    'server' => cluster.endpoint,
    'certificate-authority-data' => cluster.certificate_authority.data,
  }
}

config['users'] << {
  'name' => NICK,
  'user' => {
    'exec' => {
      'apiVersion' => 'client.authentication.k8s.io/v1beta1',
      'command' => 'mairu',
      'args' => %W[
        exec --server #{MAIRU_SERVER} #{ROLE}
        aws eks get-token --region #{REGION} --cluster-name #{CLUSTER} --output json
      ],
    },
  },
}

config['contexts'] << {
  'name' => NICK,
  'context' => {
    'cluster' => NICK,
    'user' => NICK,
  },
}

File.write(kubeconfig, config.to_yaml)

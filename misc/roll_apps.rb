#!/usr/bin/env ruby
require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'pathname'
  gem 'aws-sdk-ecr'
end

REGISTRIES = %w[005216166247]
TAG_RE = %r{(?<registry>\d+)\.dkr\.ecr\.(?<region>[\w-]+)\.amazonaws\.com/(?<repository>[\w/-]+):\K(?<tag>[0-9a-f]{40})}

@ecr = Hash.new {|h, region| h[region] = Aws::ECR::Client.new(region:) }

Pathname(__dir__).glob('../k8s/**/*.{j,lib}sonnet') do |path|
  content = path.read

  updated = content.gsub!(TAG_RE) do
    m = $~
    next m unless REGISTRIES.include?(m[:registry])

    ecr = @ecr[m[:region]]

    images = ecr.describe_images(
      registry_id: m[:registry],
      repository_name: m[:repository],
      filter: {tag_status: 'TAGGED'},
    ).image_details.sort_by!(&:image_pushed_at)

    images.reverse_each do |image|
      tag = image.image_tags.find {|tag| tag =~ /\A[0-9a-f]{40}\z/ }
      break tag if tag
    end or begin
      warn "Tag not found for #{m[:repository]}"
      m
    end
  end

  path.write(content) if updated
end

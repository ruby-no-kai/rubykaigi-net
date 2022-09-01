{
  name: 'docker-fluentd',
  on: {
    push: {
      branches: ['master', 'test'],
      paths: [
        'docker/syslog/**',
        '.github/workflows/docker-fluentd.jsonnet',
      ],
    },
  },
  jobs: {
    build: {
      name: 'build',
      'runs-on': 'ubuntu-latest',
      permissions: { 'id-token': 'write', contents: 'read' },
      steps: [
        { uses: 'docker/setup-qemu-action@v2' },
        { uses: 'docker/setup-buildx-action@v2' },
        {
          uses: 'aws-actions/configure-aws-credentials@v1',
          with: {
            'aws-region': 'ap-northeast-1',
            'role-to-assume': 'arn:aws:iam::005216166247:role/GhaDockerPush',
            'role-skip-session-tagging': true,
          },
        },
        {
          uses: 'aws-actions/amazon-ecr-login@v1',
          id: 'login-ecr',
        },
        {
          uses: 'docker/build-push-action@v3',
          with: {
            context: '{{defaultContext}}:docker/fluentd',
            platforms: std.join(',', ['linux/arm64']),
            tags: std.join(',', [
              '${{ steps.login-ecr.outputs.registry }}/fluentd:${{ github.sha }}',
              '${{ steps.login-ecr.outputs.registry }}/fluentd:latest',
            ]),
            push: true,
          },
        },
      ],
    },
  },
}

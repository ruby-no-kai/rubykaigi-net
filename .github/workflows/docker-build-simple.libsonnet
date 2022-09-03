// Convention:
//   Workflow definition: .github/workflow/docker-#{name}.yml
//   Docker manifest docker/#{name}/Dockerfile
//   ECR repository: #{name}

function(name) {
  name: std.format('docker-%s', name),
  on: {
    push: {
      branches: ['master', 'test'],
      paths: [
        std.format('docker/%s/**', name),
        std.format('.github/workflows/docker-%s.yml', name),
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
            context: std.format('{{defaultContext}}:docker/%s', name),
            platforms: std.join(',', ['linux/arm64']),
            tags: std.join(',', [
              std.format('${{ steps.login-ecr.outputs.registry }}/%s:${{ github.sha }}', name),
              std.format('${{ steps.login-ecr.outputs.registry }}/%s:latest', name),
            ]),
            push: true,
          },
        },
      ],
    },
  },
}

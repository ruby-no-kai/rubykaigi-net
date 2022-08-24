{
  name: 'docker-kea',
  on: {
    push: {
      branches: ['master', 'test'],
      paths: ['docker/kea/**'],
    },
  },
  jobs: {
    build: {
      name: 'build',
      'runs-on': 'ubuntu-latest',
      permissions: { 'id-token': 'write', contents: 'read' },
      steps: [
        { uses: 'actions/checkout@v3' },
        {
          name: 'setup docker multiarch',
          run: |||
            mkdir -p ~/.docker
            sudo docker run --rm --privileged multiarch/qemu-user-static --reset --persistent yes --credential yes
          |||,
        },
        {
          uses: 'docker/setup-buildx-action@v2',
          with: { install: true },
        },
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
            context: 'docker/kea',
            platforms: std.join(',', ['linux/arm64']),
            tags: std.join(',', [
              '${{ steps.login-ecr.outputs.registry }}/kea:${{ github.sha }}',
              '${{ steps.login-ecr.outputs.registry }}/kea:latest',
            ]),
            push: true,
          },
        },
      ],
    },
  },
}

local resolvers = ['1.1.1.1:53', '8.8.8.8:53'];

{
  installCRDs: true,
  extraArgs: [
    '--dns01-recursive-nameservers-only',
    '--dns01-recursive-nameservers=' + std.join(',', resolvers),
  ],
}

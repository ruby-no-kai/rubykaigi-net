{
  global: {
    trace: {
      verbose: true,
    },
  },

  multiplexer: {
    collectors: [
      {
        name: 'tap',
        dnstap: {
          'listen-ip': '127.0.0.1',
          'listen-port': 6000,
        },
      },
    ],
    loggers: [
      {
        name: 'prom',
        prometheus: {
          'listen-ip': '0.0.0.0',
          'listen-port': 8081,
          'basic-auth-enable': false,
          'top-n': 0,
          'histogram-metrics-enabled': true,
          'requesters-metrics-enabled': false,
        },
      },
    ],
    routes: [
      { from: ['tap'], to: ['prom'] },
    ],
  },
}

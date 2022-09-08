{
  groups+: [
    {
      name: 'cloudwatch_down',
      rules: [
        {
          alert: 'CloudwatchDown',
          expr: 'up{job=~"^cloudwatch(_.+)?$"} == 0',
          'for': '6m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.instance}} (job={{$labels.job}}): CloudWatch Exporter Down 6m+',
          },
        },
        {
          alert: 'CloudwatchScrapeError',
          expr: 'cloudwatch_exporter_scrape_error > 0',
          'for': '6m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.instance}} (job={{$labels.job}}): CloudWatch Scrape Error 6m+',  //
          },
        },
      ],
    },
  ],
}

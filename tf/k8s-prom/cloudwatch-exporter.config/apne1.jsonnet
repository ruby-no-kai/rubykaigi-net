local u = import './util.libsonnet';

{
  region: 'ap-northeast-1',
  period_seconds: 300,
  delay_seconds: 360,
  metrics: (
    u.product([
      [
        {
          aws_namespace: 'AWS/NetworkELB',
          aws_dimensions: ['LoadBalancer', 'AvailabilityZone'],
        },
      ],
      u.product([
        [
          { aws_statistics: ['Average', 'Minimum', 'Maximum'] },
        ],
        std.map(
          function(metric) { aws_metric_name: metric },
          [
            'ActiveFlowCount_TCP',
            'ActiveFlowCount_TLS',
            'ActiveFlowCount_UDP',
          ]
        ),
      ]) +
      u.product([
        [
          { aws_statistics: ['Sum'] },
        ],
        std.map(
          function(metric) { aws_metric_name: metric },
          [
            'NewFlowCount_TCP',
            'NewFlowCount_TLS',
            'NewFlowCount_UDP',
            'ProcessedBytes_TCP',
            'ProcessedBytes_TLS',
            'ProcessedBytes_UDP',
            'PortAllocationErrorCount',
          ],
        ),
      ]),
    ]) +

    u.product([
      [
        {
          aws_namespace: 'AWS/EBS',
          aws_dimensions: ['VolumeId'],
        },
      ],
      [
        { aws_statistics: ['Average', 'Minimum', 'Maximum'] },
      ],
      std.map(
        function(metric) { aws_metric_name: metric },
        [
          'VolumeReadBytes',
          'VolumeIdleTime',
          'VolumeReadOps',
          'BurstBalance',
          'VolumeQueueLength',
          'VolumeWriteBytes',
          'VolumeWriteOps',
          'VolumeTotalReadTime',
          'VolumeTotalWriteTime',
        ],
      ),
    ]) +

    u.product([
      [
        {
          aws_namespace: 'AWS/EC2',
          aws_dimensions: ['InstanceId'],
        },
      ],
      [
        { aws_statistics: ['Average', 'Minimum', 'Maximum'] },
      ],
      std.map(
        function(metric) { aws_metric_name: metric },
        [
          'CPUCreditBalance',
          'CPUCreditUsage',
          'CPUSurplusCreditBalance',
          'CPUSurplusCreditsCharged',
          'CPUUtilization',
          'DiskReadOps',
          'DiskWriteOps',
          'NetworkIn',
          'NetworkOut',
          'NetworkPacketsIn',
          'NetworkPacketsOut',
          'StatusCheckFailed',
          'StatusCheckFailed_Instance',
        ],
      ),
    ]) +

    u.product([
      [
        {
          aws_namespace: 'AWS/NATGateway',
          aws_dimensions: ['NatGatewayId'],
          aws_statistics: ['Sum', 'Average', 'Minimum', 'Maximum'],
        },
      ],
      std.map(
        function(metric) { aws_metric_name: metric },
        [
          'ConnectionAttemptCount',
          'IdleTimeoutCount',
          'BytesInFromDestination',
          'PacketsDropCount',
          'ConnectionEstablishedCount',
          'ErrorPortAllocation',
          'BytesOutToSource',
          'BytesInFromSource',
          'BytesOutToDestination',
          'ActiveConnectionCount',
        ]
      ),
    ]) +

    u.product([
      [
        {
          aws_namespace: 'AWS/RDS',
          aws_dimensions: ['DBInstanceIdentifier'],
          aws_statistics: ['Sum', 'Average', 'Minimum', 'Maximum'],
        },
      ],
      std.map(
        function(metric) { aws_metric_name: metric },
        [
          'CPUCreditBalance',
          'CPUCreditUsage',
          'CPUUtilization',
          'DatabaseConnections',
          'DBLoad',
          'DBLoadCPU',
          'DBLoadNonCPU',
          'Deadlocks',
          'DiskQueueDepth',
          'EngineUptime',
          'FreeableMemory',
          'FreeLocalStorage',
          'FreeStorageSpace',
          'NetworkReceiveThroughput',
          'NetworkThroughput',
          'NetworkTransmitThroughput',
          'OldestReplicationSlotLag',
          'RDSToAuroraPostgreSQLReplicaLag',
          'ReadIOPS',
          'ReadLatency',
          'ReadThroughput',
          'ReplicationSlotDiskUsage',
          'SwapUsage',
          'TransactionLogsDiskUsage',
          'TransactionLogsGeneration',
          'WriteIOPS',
          'WriteLatency',
          'WriteThroughput',
        ]
      ),
    ])

  ),
}

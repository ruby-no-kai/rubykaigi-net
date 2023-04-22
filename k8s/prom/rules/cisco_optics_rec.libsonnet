{
  groups+: [
    {
      name: 'cisco_optics_rec',
      rules: [
        {
          record: 'cisco_optics:receive_power_sensor',
          expr: |||
            label_replace(
              entSensorValue{entPhysicalName=~".*Receive Power Sensor$"}
              * 1
              / 10^entSensorPrecision
            ,
              "ifName", "$1",
              "entPhysicalName", "^([^ ]+) .*$"
            )
          |||,
        },
        {
          record: 'cisco_optics:transmit_power_sensor',
          expr: |||
            label_replace(
              entSensorValue{entPhysicalName=~".*Transmit Power Sensor$"}
              * 1
              / 10^entSensorPrecision
            ,
              "ifName", "$1",
              "entPhysicalName", "^([^ ]+) .*$"
            )
          |||,
        },
      ],
    },
  ],
}

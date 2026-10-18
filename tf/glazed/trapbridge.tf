locals {
  # Loopback address (hosts.txt) that trapbridge sees as the trap source => glazed node
  trap_nodes = {
    "10.33.0.1"   = "br-01.hnd"
    "10.33.0.2"   = "br-01.nrt"
    "10.33.0.3"   = "br-01.itm"
    "10.33.0.151" = "tun-01.hnd"
    "10.33.0.152" = "tun-01.nrt"
    "10.33.0.153" = "tun-01.itm"
    "10.33.0.72"  = "recon-01.nrt"
    "10.33.0.11"  = "er-01.venue"
    "10.33.0.12"  = "er-02.venue"
    "10.33.0.30"  = "cs-01.venue"
    "10.33.0.161" = "tun-01.venue"
    "10.33.0.162" = "tun-02.venue"
    "10.33.0.21"  = "nat-41.venue"
    "10.33.0.22"  = "nat-42.venue"
  }

  # Junos commit and NEC IX save
  trap_config_changed = [
    "JUNIPER-CFGMGMT-MIB::jnxCmCfgChange",
    "PICO-SMI::picoConfigModified",
  ]
  # NEC IX refuses the dump while another session is in configure mode
  trap_config_released = [
    "PICO-SMI::picoConfigMode",
    "PICO-SMI::picoLoginSession",
  ]

  # glazed's own IX sessions come from the Lambda ENIs and also raise the release traps
  trap_ignored_peer_prefixes = flatten([
    for s in data.aws_subnet.private : [
      for i in range(pow(2, 24 - tonumber(split("/", s.cidr_block)[1]))) :
      replace(cidrsubnet(s.cidr_block, 24 - tonumber(split("/", s.cidr_block)[1]), i), "/\\d+\\/24$/", "")
    ]
  ])

  trap_query_node     = "$lookup(${jsonencode(local.trap_nodes)}, $states.input.detail.source.address)"
  trap_query_varbinds = "$states.input.detail.varbinds"
  trap_query_peer     = "${local.trap_query_varbinds}[name = 'PICO-SMI::picoLoginSessionPeerIpAddress'].value"
  trap_state_machine = {
    QueryLanguage = "JSONata"
    StartAt       = "Classify"
    States = {
      Classify = {
        Type = "Pass"
        Assign = {
          node = "{% $exists(${local.trap_query_node}) ? ${local.trap_query_node} : '' %}"
          trap = "{% $states.input.detail.trap.name %}"
          peer = "{% $exists(${local.trap_query_peer}) ? ${local.trap_query_peer} : '' %}"
          released = join(" ", [
            "{%",
            "$states.input.detail.trap.name = 'PICO-SMI::picoConfigMode' and $exists(${local.trap_query_varbinds}[name = 'PICO-SMI::picoLoginSessionProcessMode' and value_name = 'operation'])",
            "or $states.input.detail.trap.name = 'PICO-SMI::picoLoginSession' and $exists(${local.trap_query_varbinds}[name = 'PICO-SMI::picoLoginSessionStatus' and value_name = 'logout'])",
            "%}",
          ])
        }
        Next = "Decide"
      }
      Decide = {
        Type = "Choice"
        Choices = [
          {
            Condition = "{% $node = '' %}"
            Next      = "Skip"
          },
          {
            Condition = "{% $trap in ${jsonencode(local.trap_config_changed)} %}"
            Next      = "Signal"
          },
          {
            Condition = "{% $released and $count($filter(${jsonencode(local.trap_ignored_peer_prefixes)}, function($p) { $substring($peer, 0, $length($p)) = $p })) = 0 %}"
            Next      = "Signal"
          },
        ]
        Default = "Skip"
      }
      Signal = {
        Type     = "Task"
        Resource = "arn:aws:states:::aws-sdk:sfn:startExecution"
        Arguments = {
          StateMachineArn = aws_sfn_state_machine.glazed.arn
          Input           = "{% $string({'signals': [{'node': $node, 'workflows': ['backup'], 'source': 'trap'}]}) %}"
        }
        End = true
      }
      Skip = {
        Type = "Succeed"
      }
    }
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

# Signals are not immediate, so the glazed state machine debounces them.
resource "aws_sfn_state_machine" "glazed-trap" {
  name       = "glazed-trap"
  type       = "EXPRESS"
  role_arn   = aws_iam_role.StatesGlazedTrap.arn
  definition = jsonencode(local.trap_state_machine)
}

resource "aws_cloudwatch_event_rule" "glazed-trap" {
  name        = "glazed-trap"
  description = "rubykaigi-net//tf/glazed"
  event_pattern = jsonencode({
    source      = ["trapbridge.0w0.co"]
    detail-type = ["SNMP Trap"]
    detail = {
      source = { address = keys(local.trap_nodes) }
      trap   = { name = concat(local.trap_config_changed, local.trap_config_released) }
    }
  })
}

resource "aws_cloudwatch_event_target" "glazed-trap" {
  rule     = aws_cloudwatch_event_rule.glazed-trap.name
  arn      = aws_sfn_state_machine.glazed-trap.arn
  role_arn = aws_iam_role.EventsGlazed.arn
}

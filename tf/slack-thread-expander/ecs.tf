data "aws_ecs_cluster" "fargate" {
  cluster_name = "rk-usw2-fargate"
}

data "aws_iam_role" "EcsExecBasic" {
  name = "EcsExecBasic"
}

resource "aws_ecs_service" "app" {
  name    = "slack-thread-expander"
  cluster = data.aws_ecs_cluster.fargate.id

  task_definition = aws_ecs_task_definition.app.arn

  desired_count = 1

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }

  network_configuration {
    subnets          = data.aws_subnets.public.ids
    security_groups  = [data.aws_security_group.default.id]
    assign_public_ip = true
  }

  propagate_tags = "SERVICE"
}

resource "aws_ecs_task_definition" "app" {
  family = "slack-thread-expander"

  cpu    = "256"
  memory = "512"

  network_mode       = "awsvpc"
  execution_role_arn = data.aws_iam_role.EcsExecBasic.arn

  container_definitions = jsonencode([
    {
      name        = "app"
      image       = "${aws_ecr_repository.app.repository_url}:5ca8de3ac184594089943423f796f9906df2fa98",
      environment = []
      secrets = [
        {
          name      = "SLACK_APP_TOKEN"
          valueFrom = "arn:aws:ssm:us-west-2:005216166247:parameter/ecs/slack-thread-expander/SLACK_APP_TOKEN"
        },
        {
          name      = "SLACK_OAUTH_TOKEN"
          valueFrom = "arn:aws:ssm:us-west-2:005216166247:parameter/ecs/slack-thread-expander/SLACK_OAUTH_TOKEN"
        },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = "us-west-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  requires_compatibilities = ["FARGATE"]
}


resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/slack-thread-expander"
  retention_in_days = 3
}

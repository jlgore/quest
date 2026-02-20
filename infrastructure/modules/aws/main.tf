terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

resource "aws_secretsmanager_secret" "this" {
  name                    = var.deployment_secret_word
  recovery_window_in_days = 0 # set to 0 for easy teardown in this exercise - IRL this would not happen
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = var.secret_word_value
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/quest"
  retention_in_days = 30
}

resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = var.ecs_cluster_insights_available
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "service"
  execution_role_arn       = aws_iam_role.this.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([
    {
      name      = "quest-aws-ecs"
      image     = "ghcr.io/jlgore/quest:${var.image_tag}"
      essential = true
      secrets = [{
        name = "SECRET_WORD"
        valueFrom = aws_secretsmanager_secret.this.arn
      }]
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "quest-ecs-service-def"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  depends_on      = [aws_iam_role_policy.this, aws_lb_listener.this]

  network_configuration {
    subnets          = data.aws_subnets.this.ids
    security_groups  = [aws_security_group.this_ecs_allow_tls_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "quest-aws-ecs"
    container_port   = 3000
  }
}
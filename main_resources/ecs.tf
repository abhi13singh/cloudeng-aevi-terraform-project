# create ecs cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name      = "${var.project}-${var.environment}-ecs-cluster"

  setting {
    name    = "containerInsights"
    value   = "disabled"
  }
}

# create cloudwatch log group
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/ecs/${var.project}-${var.environment}-td"
  retention_in_days = 7

  lifecycle {
    create_before_destroy = true
  }
}

# create task definition
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                    = "${var.project}-${var.environment}-td"
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  network_mode              = "awsvpc"
  requires_compatibilities  = ["FARGATE"]
  cpu                       = 256
  memory                    = 512

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.architecture
  }

  # create container definition
  container_definitions     = jsonencode([
    {
      name                  = "${var.project}-${var.environment}-container-app"
      image                 = "${var.conatainer_image}"
      essential             = true

      portMappings          = [
        {
          containerPort     = 80
          hostPort          = 80
        }
      ]

      environmentFiles = [
        {
          value = "arn:aws:s3:::aevi-test-env-file-bucket/env-files/<env-file-name>"
          type  = "s3"
        }
      ]
      
      logConfiguration = {
        logDriver      = "awslogs",
        options        = {
          "awslogs-group"          = "${aws_cloudwatch_log_group.log_group.name}",
           "awslogs-region"        = "${var.region}",
          "awslogs-stream-prefix"  = "ecs"
        }
      }
    }
  ])
}

# create ecs service
resource "aws_ecs_service" "ecs_service" {
  name                               = "${var.project}-${var.environment}-service"
  launch_type                        = "FARGATE"
  cluster                            = aws_ecs_cluster.ecs_cluster.id
  task_definition                    = aws_ecs_task_definition.ecs_task_definition.arn
  platform_version                   = "LATEST"
  desired_count                      = 2
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  # task tagging configuration
  enable_ecs_managed_tags            = false
  propagate_tags                     = "SERVICE"

  # vpc and security groups
  network_configuration {
    subnets                 = var.private_subnet_cidrs
    security_groups         = [aws_security_group.ecs_cluster_security_group.id]
    assign_public_ip        = false
  }

  # load balancing
  load_balancer {
    target_group_arn = module.alb.target_groups["ex_ecs"].arn
    container_name   = "${var.project}-${var.environment}-container-app"
    container_port   = 80
  }
}

# security group for ecs cluster
resource "aws_security_group" "ecs_cluster_security_group" {
  name        = "${var.project}-${var.environment}-ecs-cluster-sg"
  description = "enable http access on port 80 via alb sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = module.alb.security_group_id
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "${var.project}-${var.environment}-ecs-cluster-sg"
  }
}

# create an auto scaling group for the ecs service
resource "aws_appautoscaling_target" "ecs_asg" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${var.project}-${var.environment}-ecs-cluster/${var.project}-${var.environment}-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [aws_ecs_service.ecs_service]
}

# create scaling policy for the auto scaling group
resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "${var.project}-${var.environment}-asg-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "service/${var.project}-${var.environment}-ecs-cluster/${var.project}-${var.environment}-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  
  target_tracking_scaling_policy_configuration {

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 70
    scale_out_cooldown = 300
    scale_in_cooldown  = 300
    disable_scale_in   = false
  }

  depends_on = [aws_appautoscaling_target.ecs_asg]
}

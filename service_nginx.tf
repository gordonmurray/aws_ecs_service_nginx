resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = 1
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.arn
    container_name   = "nginx" # Use the container name from the task definition
    container_port   = 80
  }

  depends_on = [aws_lb_listener.nginx_http]
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "1024" # 1 vCPU
  memory                   = "2048" # 2 GB
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "${var.ecr_repository_url}:nginx"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 8080
        },
        {
          containerPort = 443
          hostPort      = 4443
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_log_group.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "nginx"
        }
      }
    }
  ])

}

resource "aws_lb_target_group" "nginx" {
  name        = "nginx-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    port                = "8080"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "nginx_http" {
  load_balancer_arn = var.load_balancer_arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx.arn
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/nginx"
  retention_in_days = 7
}

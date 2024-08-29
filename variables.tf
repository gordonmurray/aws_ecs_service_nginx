
variable "region" {
  type        = string
  description = "The AWS region to deploy to"
  default     = "us-west-2"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "default_tag" {
  type        = string
  description = "A default tag to add to everything"
  default     = "terraform_ecs_service_nginx"
}

variable "application_name" {
  description = "The name of the application"
  type        = string
}

variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  type        = string
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  type        = string
}

variable "load_balancer_arn" {
  description = "The ARN of the load balancer"
  type        = string
}

variable "task_execution_role_arn" {
  description = "ECS tasks execution role arn."
}

variable "service_security_groups" {
  type = list
  description = "ECS service security groups."
}

variable "subnets" {
  type = list
  description = "ECS service subnets."
}

variable "target_group_arn" {
  description = "ALB target group arn."
}
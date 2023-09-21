variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "ecs_task_cpu" {
  type    = number
  default = 512
}

variable "ecs_task_memory" {
  type    = number
  default = 1024
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  aws_region     = data.aws_region.current.name
}

### Task Execution Role ###
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole-${var.workload}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_taskexecution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


### Task Role ###
resource "aws_iam_role" "ecs_task" {
  name = "ecsTaskRole-${var.workload}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Condition = {
          ArnLike = {
            "aws:SourceArn" : "arn:aws:ecs:${local.aws_region}:${local.aws_account_id}:*"
          }
          StringEquals = {
            "aws:SourceAccount" : "${local.aws_account_id}"
          }
        }
      },
    ]
  })
}


resource "aws_iam_policy" "ecs_tasks" {
  name = "ECSFargateTaskCloudWatchPolicy-${var.workload}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Logs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
        ]
        Resource = [
          "arn:aws:logs:${local.aws_region}:${local.aws_account_id}:*"
        ]
      },
      {
        Sid    = "SSM"
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
        ]
        Resource = [
          "arn:aws:ssm:${local.aws_region}:${local.aws_account_id}:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_tasks" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_tasks.arn
}

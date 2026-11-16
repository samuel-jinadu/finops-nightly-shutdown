

# EC2
resource "aws_instance" "dev_server" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.instance.id]
}

# RDS
resource "aws_db_parameter_group" "postgres17_custom" {
  name   = "postgres17-custom-params"
  family = "postgres17"

  parameter {
    name  = "work_mem"
    value = "4096"
  }
}

resource "aws_db_instance" "default" {
  identifier           = "dev-db"
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "postgres"
  engine_version       = "17"
  instance_class       = var.db_instance_class
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = aws_db_parameter_group.postgres17_custom.name
  skip_final_snapshot  = true
  multi_az             = false
}


# VPC
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# IAM
data "aws_caller_identity" "current" {}


resource "aws_iam_role" "events_role" {
  name = "events_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }

        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
    ]
  })

}

resource "aws_iam_role_policy" "start_stop_ec2_policy" {
  name = "start_stop_ec2_policy"
  role = aws_iam_role.events_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
        ]
        Effect   = "Allow"
        Resource = aws_instance.dev_server.arn
      },
    ]
  })
}

resource "aws_iam_role_policy" "start_stop_rds_policy" {
  name = "start_stop_rds_policy"
  role = aws_iam_role.events_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:StartDBInstance",
          "rds:StopDBInstance",
        ]
        Effect   = "Allow"
        Resource = aws_db_instance.default.arn
      },
    ]
  })
}


resource "aws_iam_role_policy" "describe_policy" {
  name = "describe_policy"
  role = aws_iam_role.events_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "rds:DescribeDBInstances",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Cloudwatch/Events
resource "aws_cloudwatch_event_rule" "stopec2_cronjob" {
  name        = "stopec2_cronjob"
  description = "Runs everyday at 7pm"

  schedule_expression = var.stop_schedule
}

resource "aws_cloudwatch_event_target" "stop_ec2_target" {
  rule      = aws_cloudwatch_event_rule.stopec2_cronjob.name
  target_id = "StopEC2Instance"
  arn       = aws_instance.dev_server.arn
  role_arn  = aws_iam_role.events_role.arn

  input = jsonencode({
    InstanceIds = [aws_instance.dev_server.id]
  })
}

resource "aws_cloudwatch_event_rule" "start_ec2_cronjob" {
  name        = "startec2_cronjob"
  description = "Runs everyday at 7am"

  schedule_expression = var.start_schedule
}

resource "aws_cloudwatch_event_target" "start_ec2_target" {
  rule      = aws_cloudwatch_event_rule.start_ec2_cronjob.name
  target_id = "StartEC2Instance"
  arn       = aws_instance.dev_server.arn
  role_arn  = aws_iam_role.events_role.arn

  input = jsonencode({
    InstanceIds = [aws_instance.dev_server.id]
  })
}

resource "aws_cloudwatch_event_rule" "start_rds_cronjob" {
  name                = "start-rds-cronjob"
  description         = "Runs everyday at 7am to start RDS"
  schedule_expression = var.start_schedule
}

resource "aws_cloudwatch_event_target" "start_rds_target" {
  rule      = aws_cloudwatch_event_rule.start_rds_cronjob.name
  target_id = "StartRDSInstance"

  arn      = aws_db_instance.default.arn
  role_arn = aws_iam_role.events_role.arn

  input = jsonencode({
    DBInstanceIdentifier = aws_db_instance.default.identifier
  })
}

resource "aws_cloudwatch_event_rule" "stop_rds_cronjob" {
  name                = "stop-rds-cronjob"
  description         = "Runs everyday at 7pm to stop RDS"
  schedule_expression = var.stop_schedule
}

resource "aws_cloudwatch_event_target" "stop_rds_target" {
  rule      = aws_cloudwatch_event_rule.stop_rds_cronjob.name
  target_id = "StopRDSInstance"
  arn       = aws_db_instance.default.arn
  role_arn  = aws_iam_role.events_role.arn

  input = jsonencode({
    DBInstanceIdentifier = aws_db_instance.default.identifier
  })
}
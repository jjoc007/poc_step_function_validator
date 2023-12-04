resource "aws_iam_role" "example_lambda_role" {
  name               = "example_lambda_role_for_numbers"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "LambdaLoggingPolicy_SF"
  description = "Allow Lambda to log to CloudWatch Logs."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "event_policy" {
  name = "process_validator_event_policy"
  role = aws_iam_role.events_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "states:StartExecution",
      Effect = "Allow",
      Resource = [aws_sfn_state_machine.process_validator_sf.arn]
    }]
  })
}

resource "aws_iam_role" "step_functions_role" {
  name = "step_functions_role_poc_number_sf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "events_role" {
  name = "events_role_poc_validator_sf"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "step_functions_policy_lambda" {
  name   = "step_functions_policy_lambda_policy_all_poc_number_sf"
  policy = data.aws_iam_policy_document.lambda_access_policy.json
}

data "aws_iam_policy_document" "lambda_access_policy" {
  statement {
    actions = [
      "lambda:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "sfn_logging_policy" {
  name        = "SFNLoggingPolicy"
  description = "Allow Step Functions to log to CloudWatch Logs."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sfn_logging_attach" {
  policy_arn = aws_iam_policy.sfn_logging_policy.arn
  role       = aws_iam_role.step_functions_role.name
}

resource "aws_iam_role_policy_attachment" "step_functions_to_lambda" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.step_functions_policy_lambda.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attach" {
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
  role       = aws_iam_role.example_lambda_role.name
}
resource "aws_cloudwatch_log_group" "step_validator_logs" {
  name              = "/aws/states/lambda_validator"
  retention_in_days = 1
}
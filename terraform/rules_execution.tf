resource "aws_scheduler_schedule" "example" {
  name = "poc-schedule-validation"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(2 minutes)"

  target {
    arn      = aws_sfn_state_machine.process_validator_sf.arn
    role_arn = aws_iam_role.events_role.arn

    input = jsonencode({
      Comment = "test"
    })
  }
}


# Step Functions State Machine
resource "aws_sfn_state_machine" "deploy_validator_sf" {

  depends_on = [aws_cloudwatch_log_group.step_validator_logs]

  name     = "DeployValidatorSF"
  role_arn = aws_iam_role.step_functions_role.arn

  logging_configuration {
    level     = "ALL"
    include_execution_data = true
    log_destination = "${aws_cloudwatch_log_group.step_validator_logs.arn}:*"
  }

  definition = <<EOF
{
  "Comment": "Ejecuta la Lambda para controlar el estado de un despliegue",
  "StartAt": "Create",
  "States": {
    "Create": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.number_validator_lambda.arn}",
      "Parameters": {
        "input.$": "$",
        "action": "create"
      },
      "Next": "WaitForExecuteAction"
    },
    "WaitForExecuteAction": {
      "Type": "Wait",
      "Seconds": 10,
      "Next": "ExecuteAction"
    },
    "ExecuteAction": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.number_validator_lambda.arn}",
      "Parameters": {
        "number.$": "$.number",
        "update.$": "$.update",
        "status.$": "$.status",
        "action": "execute_action"
      },
      "Retry": [
          {
            "ErrorEquals": [
              "States.ALL"
            ],
            "IntervalSeconds": 5,
            "MaxAttempts": 5,
            "BackoffRate": 1.5
          }
        ],
      "Next": "WaitForEnd"
    },
    "WaitForEnd": {
      "Type": "Wait",
      "Seconds": 10,
      "Next": "EndDeploy"
    },
    "EndDeploy": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.number_validator_lambda.arn}",
      "Parameters": {
        "number.$": "$.number",
        "update.$": "$.update",
        "status.$": "$.status",
        "action": "end"
      },
      "Retry": [
          {
            "ErrorEquals": [
             "States.ALL"
            ],
            "IntervalSeconds": 5,
            "MaxAttempts": 5,
            "BackoffRate": 1.5
          }
        ],
      "Next": "Ended"
    },
    "Ended": {
      "Type": "Succeed"
    }
  }
}
EOF
}
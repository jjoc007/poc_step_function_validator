resource "aws_sfn_state_machine" "process_validator_sf" {
  name     = "ProcessValidatorSF"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = <<EOF
{
  "Comment": "Ejecuta la Lambda para controlar el estado de un despliegue",
  "StartAt": "Create",
  "States": {
    "Create": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.process_lambda.arn}",
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
      "Resource": "${aws_lambda_function.process_lambda.arn}",
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
      "Resource": "${aws_lambda_function.process_lambda.arn}",
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

resource "aws_sfn_state_machine" "process_parent_validator_sf" {
  name     = "ProcessParentValidatorSF"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = <<EOF
{
  "Comment": "Ejecuta la Lambda para controlar el estado de un despliegue",
  "StartAt": "Create",
  "States": {
    "Create": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.process_parent_lambda.arn}",
      "Parameters": {
        "input.$": "$",
        "action": "create_process_parent"
      },
      "Next": "WaitForChildAction"
    },
    "WaitForChildAction": {
      "Type": "Wait",
      "Seconds": 10,
      "Next": "ExecuteChildProcess"
    },
    "ExecuteAction": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.process_lambda.arn}",
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
      "Resource": "${aws_lambda_function.process_lambda.arn}",
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
resource "aws_lambda_function" "process_lambda" {
  filename      =  data.archive_file.process_validator.output_path
  source_code_hash = data.archive_file.process_validator.output_base64sha256
  function_name = "poc_process_lambda"
  role          = aws_iam_role.example_lambda_role.arn
  handler       = "process.handler"
  runtime = "nodejs18.x"
}

resource "aws_lambda_function" "process_parent_lambda" {
  filename      =  data.archive_file.process_validator.output_path
  source_code_hash = data.archive_file.process_validator.output_base64sha256
  function_name = "poc_process_parent_lambda"
  role          = aws_iam_role.example_lambda_role.arn
  handler       = "process_parent.handler"
  runtime = "nodejs18.x"
}
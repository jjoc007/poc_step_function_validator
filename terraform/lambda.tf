resource "aws_lambda_function" "number_validator_lambda" {
  filename      =  data.archive_file.number_validator.output_path
  source_code_hash = data.archive_file.number_validator.output_base64sha256
  function_name = "poc_number_validator_lambda"
  role          = aws_iam_role.example_lambda_role.arn
  handler       = "lambda/main.handler"
  runtime = "nodejs18.x"
}
data "archive_file" "number_validator" {
  type        = "zip"
  source_dir = "../lambda/"
  output_path = "./dist/lambda.zip"
}
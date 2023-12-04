data "archive_file" "process_validator" {
  type        = "zip"
  source_dir = "../lambda/"
  output_path = "./dist/lambda.zip"
}
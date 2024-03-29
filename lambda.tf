data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda/lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "alert_setup_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  function_name = "auto-setup-utilization-alert"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.9"

  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  role          = aws_iam_role.iam_for_lambda.arn
  layers        = []
  timeout       = 60

  environment {
    variables = {
      foo = "bar"
    }
  }
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.alert_setup_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.trigger_lambda.arn
  depends_on = [ aws_lambda_function.alert_setup_lambda, aws_sns_topic_subscription.trigger_lambda ]
}
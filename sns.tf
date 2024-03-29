################
# SNS TOPIC to create utilisation alert on the basis of team
################
resource "aws_sns_topic" "trigger_lambda" {
  name = "trigger_lambda"
  #lambda_failure_feedback_role_arn         = "arn:aws:iam::730335430970:role/SNSFailureFeedback" 
  #lambda_success_feedback_role_arn         = "arn:aws:iam::730335430970:role/SNSSuccessFeedback"
  #lambda_success_feedback_sample_rate      = 100 
  depends_on = [ aws_lambda_function.alert_setup_lambda ]
}

resource "aws_sns_topic_subscription" "trigger_lambda" {
  topic_arn = aws_sns_topic.trigger_lambda.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.alert_setup_lambda.arn

  depends_on = [ aws_sns_topic.trigger_lambda ]
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.trigger_lambda.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {

  statement {
    actions = [
      "SNS:Publish"
    ]

    effect = "Allow"

    principals {
        type        = "Service"
        identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.trigger_lambda.arn
    ]
  }
}

################
# SNS TOPIC to send alert to team from Mumbai
################

resource "aws_sns_topic" "pod1" {
  name = "pod1"
}

resource "aws_sns_topic_subscription" "pod1" {
  topic_arn = aws_sns_topic.pod1.arn
  protocol  = "email"
  endpoint  = var.email_address

  depends_on = [ aws_sns_topic.pod1 ]
}

################
# SNS TOPIC to send alert to team from North Virginia
################

resource "aws_sns_topic" "pod1_usea1" {
  name = "pod1"
  provider = aws.usea1 
}

resource "aws_sns_topic_subscription" "pod1_usea1" {
  topic_arn = aws_sns_topic.pod1_usea1.arn
  protocol  = "email"
  endpoint  = var.email_address

  depends_on = [ aws_sns_topic.pod1_usea1 ]
  provider = aws.usea1 
}
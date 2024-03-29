resource "aws_iam_policy" "iam_policy_for_lambda" {
 
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
    {
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
                "ec2:DescribeTags",
                "sns:GetTopicAttributes", 
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DeleteAlarms",
                "cloudwatch:DisableAlarmActions"
            ],
			"Resource": "*"
		},
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
       
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.iam_for_lambda.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

resource "aws_iam_policy" "iam_policy_for_eventbridg_cross_region" {
 name         = "eventbridge-sent-events"
 path         = "/"
 description  = "AWS IAM Policy for allowing access to eventbridge cross account"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
    {
            "Effect": "Allow",
            "Action": [
                "events:PutEvents"
            ],
            "Resource": [
                "arn:aws:events:ap-south-1:730335430970:event-bus/default"
            ]
        }
 ]
}
EOF
}
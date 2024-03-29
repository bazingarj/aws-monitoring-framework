module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"
  create_bus = false
  rules = {
    instance_activity = {
      description = "This rule triggers an action in response to EC2 StartInstances and StopInstances events"
      event_pattern = jsonencode({
        "source" : ["aws.ec2"],
        "detail-type": ["EC2 Instance State-change Notification"],
        "detail": {
          "state": ["running", "stopped", "terminated"]
        }
      })
    }
  }
  targets = {
    instance_activity = {
      instance_activity_target = {
        arn           = aws_sns_topic.trigger_lambda.arn
        name          = "send-ec2-events-to-sns-topic"
      }
    }
  }

  depends_on = [ aws_sns_topic.trigger_lambda ]
}


module "eventbridge_usea1" {
  source = "terraform-aws-modules/eventbridge/aws"
  create_bus = false
  attach_policy = true
  role_name = "eventbridge-role" 
  policy = aws_iam_policy.iam_policy_for_eventbridg_cross_region.arn
  rules = {
    all_events = {
      description = "This rule triggers an action in response to EC2 StartInstances and StopInstances events"
      event_pattern = jsonencode({
        "source": ["aws.ec2"]
        })
    }
  }
  targets = {
    all_events = {
       all_events_target = {
        arn           = "arn:aws:events:ap-south-1:730335430970:event-bus/default"
        name          = "send-events-to-another-region"
        attach_role_arn = true
      }
    }
  }

  depends_on = [ module.eventbridge ]
  providers = { aws = aws.usea1 }
}

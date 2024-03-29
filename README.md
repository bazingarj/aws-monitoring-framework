# AWS Automated Montoring Setup Framework
```
This Frameworks allows you to setup alert automatically on the basis of the event received on the even bus of eventbridge. We are using default event bus of eventbridge to achieve this.
```

# Architecture
Refer to Monitoring-framework.drawio.png


# Regions
```
Mumbai (Primary)
North Virginia 
```

# Alerts
```
EC2:
    CPU 
    Memory
```

# Alert Management States
```
EC2:
    Running (Setup the Alert)
    stopped (Disable the Alert)
    terminated (Deletes The Alert)
```

# Setting a New Region/Setting up a New Team
```
If you are setting up a new team or setting up resources for the team in different region, make sure to first create the SNS topic with the same name as team in sns.tf.

resource "aws_sns_topic" "TEAM_REGION_ALIAS " {
  name = "TEAM"
  provider = aws.REGION_ALIAS 
}

resource "aws_sns_topic_subscription" "TEAM_REGION_ALIAS " {
  topic_arn = aws_sns_topic.TEAM_REGION_ALIAS .arn
  protocol  = "email"
  endpoint  = var.email_address

  depends_on = [ aws_sns_topic.TEAM_REGION_ALIAS  ]
  provider = aws.REGION_ALIAS  
}

Note: TEAM must match the team tag on the resource
```

# How to send alert of a new resource to particular Team
```
Whenever setting a new resource e.g. in this case EC2, must add the tag "team" in the resource to route the alerts to that particular team name. SNS topic must be created beforehand for the team in the same region.
```


# Define custom threshold 
```
Whenever setting a new resource , below tags are supported to add custom threshold value
EC2:
    team
    cpu_threshold (0-100) (Default: 80)
    memory_threshold (0-100) (Default: 80)
```

# how to use
```
# create profile in ~/.aws/credentials named nn
terraform init
terraform plan
terraform apply
```
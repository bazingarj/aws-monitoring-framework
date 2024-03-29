import boto3, json


def getTags(client, instance_id):
    response = client.describe_tags(
        Filters=[
        {
            'Name': 'resource-id',
            'Values': [
                instance_id
            ],
        },
    ],
    )
    tags = {}
    if 'Tags' in response:
        for tag in response['Tags']:
            tags[tag['Key'].lower()] = tag['Value'].lower()
    return tags

def lambda_handler(event, context):
    # Specify the region where the EC2 instances reside

    #print(event)
    message = json.loads(event['Records'][0]['Sns']['Message'])
    account = message['account']
    region = message['region']
    instance_id = message['detail']['instance-id']
    
    
    ec2_client = boto3.client('ec2', region_name=region)
    
    tags = getTags(ec2_client, instance_id)

    # # Specify the tag key and value to filter the EC2 instances
    # tag_key = 'env'
    # tag_value = 'prod'


    # #Specify sns topic
    sns_arn = "arn:aws:sns:"+region+":"+account+":"+tags['team']

    sns = boto3.client('sns', region_name=region)
    try:
        sns_res = sns.get_topic_attributes(
            TopicArn=sns_arn
        )
    except:
        sns_arn = "arn:aws:sns:"+region+":"+account+":fallback"


    # # Specify the alarm thresholds for CPU and Memory utilization
    cpu_threshold = tags['cpu_threshold'] if 'cpu_threshold' in tags else 80.0
    memory_threshold = tags['memory_threshold'] if 'cpu_threshold' in tags else 80.0

    # # Create a CloudWatch client
    cloudwatch = boto3.client('cloudwatch', region_name=region)
    
    if message['detail']['state'] == "running":
        print('Setting up Alerts for ec2, cpu:',cpu_threshold,' memory:', memory_threshold)
        try:
            cloudwatch.put_metric_alarm(
                AlarmName=f'CPUUtilizationAlarm-{instance_id}',
                ComparisonOperator='GreaterThanOrEqualToThreshold',
                EvaluationPeriods=3,
                Threshold=cpu_threshold,
                Period=60,
                Namespace='AWS/EC2',
                MetricName='CPUUtilization',
                Statistic='Average',
                Dimensions=[
                    {
                        'Name': 'InstanceId',
                        'Value': instance_id
                    },
                ],
                AlarmActions=[
                    sns_arn # Specify your SNS topic ARN here to receive notifications
                ]
            )

            # Create Memory utilization alarm
            cloudwatch.put_metric_alarm(
                AlarmName=f'MemoryUtilizationAlarm-{instance_id}',
                ComparisonOperator='GreaterThanOrEqualToThreshold',
                EvaluationPeriods=3,
                Threshold=memory_threshold,
                Period=60,
                Namespace='CWAgent',
                MetricName='MemoryUtilization',
                Statistic='Average',
                Dimensions=[
                    {
                        'Name': 'InstanceId',
                        'Value': instance_id
                    },
                ],
                AlarmActions=[
                    sns_arn  # Specify your SNS topic ARN here to receive notifications
                ]
            )
        except Exception as e:
            print(e)
    elif message['detail']['state'] == "terminated":
        try:
            cloudwatch.delete_alarms( AlarmNames=[f'CPUUtilizationAlarm-{instance_id}', f'MemoryUtilizationAlarm-{instance_id}'] )
        except Exception as e:
            print('Could not delete Alarm')
            print(e)
    elif message['detail']['state'] == "stopped":
        try:
            cloudwatch.disable_alarm_actions( AlarmNames=[f'CPUUtilizationAlarm-{instance_id}', f'MemoryUtilizationAlarm-{instance_id}'] )
        except Exception as e:
            print('Could not delete Alarm')
            print(e)
    
    return {'statusCode': 200 }
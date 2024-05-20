import boto3 # type: ignore
import os

logs_client = boto3.client('logs')

def lambda_handler(event, context):
    log_events = event['awslogs']['data']
    log_group = os.environ['LOG_GROUP']

    response = logs_client.put_log_events(
        logGroupName=log_group,
        logStreamName='info-stream',
        logEvents=log_events
    )
    return f"Successfully processed {len(log_events)} log events."

import boto3 # type: ignore
import zlib
import json
import os
from datetime import datetime, timezone

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    payload = event['awslogs']['data']
    compressed_payload = zlib.decompress(payload.decode('base64'))
    log_data = json.loads(compressed_payload)
    log_events = log_data['logEvents']

    bucket_name = os.environ['BUCKET_NAME']
    key = f"debug-logs/{datetime.now(timezone.utc).isoformat()}.log"
    body = json.dumps(log_events)

    response = s3_client.put_object(
        Bucket=bucket_name,
        Key=key,
        Body=body
    )
    return f"Successfully processed {len(log_events)} log events."

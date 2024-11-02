#!/usr/bin/env python3
# 
import json
import os
import boto3
from datetime import datetime

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket_name = os.environ['BUCKET_NAME']
    base_prefix = os.environ['PATH_PREFIX']
    
    try:
        # Get current date for path partitioning
        now = datetime.utcnow()
        year = now.year
        month = str(now.month).zfill(2)
        day = str(now.day).zfill(2)
        hour = str(now.hour).zfill(2)
        timestamp = now.isoformat()

        # Create S3 key with partitioning
        key = f"{base_prefix}/year={year}/month={month}/day={day}/hour={hour}/{timestamp}-{event['id']}.json"
        
        # Add metadata to help with querying
        metadata = {
            'eventType': event.get('detail', {}).get('eventType', 'unknown'),
            'timestamp': timestamp,
            'source': event.get('source', 'unknown')
        }
        
        # Upload to S3
        s3.put_object(
            Bucket=bucket_name,
            Key=key,
            Body=json.dumps(event),
            ContentType='application/json',
            Metadata=metadata
        )
        
        print(f"Successfully stored event at s3://{bucket_name}/{key}")
        
        return {
            'statusCode': 200,
            'body': f"Event stored at s3://{bucket_name}/{key}"
        }
    
    except Exception as error:
        print('Error processing event:', error)
        raise

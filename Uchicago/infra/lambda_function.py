import json
import boto3
from datetime import datetime, timezone

# Initialize the DynamoDB client
dynamodb = boto3.client('dynamodb')

def lambda_handler(event, context):
    table_name = 'LambdaTriggerData'
    item_id = '1'  # Unique identifier for the item

    # Retrieve the current data from DynamoDB
    try:
        response = dynamodb.get_item(
            TableName=table_name,
            Key={'ID': {'S': item_id}}
        )
        item = response.get('Item', {})

        # Get current trigger count and last triggered time
        trigger_count = int(item.get('TriggerCount', {'N': '0'})['N'])
        last_triggered = item.get('LastTriggered', {'S': 'Never'})['S']

    except dynamodb.exceptions.ResourceNotFoundException:
        trigger_count = 0
        last_triggered = 'Never'

    # Increment trigger count
    trigger_count += 1
    current_time = datetime.now(timezone.utc).strftime('%m-%d-%Y %H:%M:%S %Z')

    # Update the item in DynamoDB
    dynamodb.put_item(
        TableName=table_name,
        Item={
            'ID': {'S': item_id},
            'TriggerCount': {'N': str(trigger_count)},
            'LastTriggered': {'S': current_time}
        }
    )

    # Create the HTML response
    html_content = f"""
        <html>
            <head>
                <title>D4CG Lambda Trigger Demo</title>
            </head>
            <body>
                <h1 style="color: DarkRed">D4CG Terraform Lambda Trigger Demo</h1>
                <h3 style="color: DarkRed">Written by Matt Springer for the Senior DevOps Engineer position </h3>
                <p style="color: DarkOrange">This web page is hosted by AWS API Gateway</p>
                <p style="color: DarkOrange">Refresh this page to see the latest statistics</p>
                <p>
                <br />
                </p>
                <h3>Lambda Trigger Count:                       {trigger_count}</h3>
                <h3>The current time is:                        {current_time}</h3>
                <h3>The Lambda function was last triggered at:  {last_triggered}</h3>
                <p>
                <br />
                </p>
                <p>The cron job is configured to trigger the Lambda function every 5 minutes.</p>
                <p>The Trigger Count is the number of times the Lambda function has been triggered by the cron job,<br />
                combined with the number of times that the browser was refreshed.</p>
                <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcReut_IyuhndXoJCr6d1vWYWeJ23w7L0CRDqQ&s" />
            </body>
        </html>
    """

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'text/html'
        },
        'body': html_content
    }

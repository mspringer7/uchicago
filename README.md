Senior DevOps Engineer position with Data for the Common Good at the University of Chicago

The objective of this exercise is to create a Terraform script that creates an AWS Lambda function triggered by a cron job, every 5 minutes.  The Lambda code and Terraform state file should be stored in S3.

I created Terraform scripts and a Lambda function that uses DynamoDB to store the count of triggers and the last trigger time. It is triggered every 5 minutes by a CloudWatch Event rule. It also generates a simple HTML page that displays the information stored in the DynamoDB table. 

The HTML page is accessible here: https://mz7zmc0hta.execute-api.us-east-1.amazonaws.com/prod/lambda

I believe that it is an AWS DevOps best practice to store the Terraform State file in a separate S3 Bucket that is not used for any other purpose.  Therefore, I created separate Buckets for the Terraform state and the Lambda function.

The steps I undertook to complete this exercise were to create the following AWS resources in Terraform.

1.	A S3 bucket that stores the Terraform state file.
2.	A S3 bucket that stores the Lambda function.
3.	A DynamoDB table that keeps a record of how many times the function was triggered as well as the most recent refresh time.
4.	An IAM role and policy for the Lambda function. The IAM role is configured to allow access to DynamoDB.
5.	The Lambda function (Python code and Terraform resource).
6.	A CloudWatch Event rule for the cron job
7.	An API Gateway with the necessary permissions to invoke the Lambda function.
8.	A CloudWatch Log Group that stores the API Gateway logs.


 Matthew Springer


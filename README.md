 ### Terraform Infrastructure for Okta Event Processing on AWS
 
 This is Terraform code to set up AWS resources to process Okta events. The main components are an S3 bucket to store Okta event logs, a Lambda function to process events, and an EventBridge rule to trigger the Lambda function upon receiving events. The file `index.js` was a prototype that didn't work out due to some dependencies. It can be ignored. The python script is used instead.
 
 ## Components
 
 - **S3 Bucket**: Stores Okta events with server-side encryption, SSL enforcement, and versioning support.
 - **Lambda Function**: Processes Okta events stored in the S3 bucket.
 - **EventBridge Rule**: Triggers the Lambda function based on Okta event patterns.
 - **IAM Roles and Policies**: Manages permissions for Lambda to interact with S3 and CloudWatch.
 - **CloudWatch Log Group**: Logs Lambda function output for monitoring and troubleshooting.
 
 ## Prerequisites
 
 - Terraform v0.12 or later
 - AWS credentials with sufficient permissions to create resources (S3, Lambda, IAM, CloudWatch, EventBridge)
 
 ## Usage

A Makefile is provided but is not necessarily needed. You can provision by hand using the terraform commands below. If you do use the Makefile, note that is is configured to use OpenTofu instead of Terraform. You will need to change the TF variable in the file and the AWS_PROFILE variable which will point to the config stanza in your `~/.aws/credentials` and `~/.aws/config`. 
 
 1. **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```
 
 2. **Initialize Terraform**:
    ```bash
    terraform init
    ```
 
 3. **Plan the Infrastructure**:
    ```bash
    terraform plan -var-file="dev.tfvars"
    ```
 
 4. **Apply the Infrastructure**:
    ```bash
    terraform apply -var-file="dev.tfvars"
    ```
 
 ## Resources Created
 
 - **S3 Bucket**: Stores Okta event logs with SSL enforcement and versioning.
 - **Lambda Function**: Processes Okta events.
 - **EventBridge Rule**: Triggers Lambda on Okta event patterns.
 - **IAM Role and Policy**: Grants permissions to Lambda.
 - **CloudWatch Log Group**: Manages logs for the Lambda function.
 
 ## Important Notes
 
 - The S3 bucket has public access disabled and SSL enforced for data security.
 - Modify `source` and `handler` fields in the Lambda function if using a different file structure or handler name.
 
 ## License
 
 This project is licensed under the MIT License.


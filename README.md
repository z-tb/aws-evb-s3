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
A Makefile is provided for convenience but is not required. You can use the Terraform commands directly as outlined below. If you choose to use the Makefile, note that it is set up to use OpenTofu rather than Terraform. To switch back to Terraform, modify the `TF` variable in the Makefile. You will also need to set the `AWS_PROFILE` variable, which specifies the AWS profile to use, corresponding to a profile configured in your `~/.aws/credentials` and `~/.aws/config` files. This is only recommended if you develop in a temporary environment (container launched with `--rm`) and/or you are using temporary credentialing. Otherwise, do not use the `~/.aws/credentials` file at all and simply export the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` into the environment. Terraform automatically checks for these environment variables to authenticate with AWS. If they?re set, Terraform uses them to access and manage your AWS resources [along with a few other vars you can use.](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## AWS Config Example
**~/.aws/credentials**
This file stores your AWS access key ID and secret access key. Replace `acloud` with the desired profile name.

```plaintext
[acloud]
aws_access_key_id = AKI...7QH4L
aws_secret_access_key = Wzq1h...cQB7pLfwt4w
```

**~/.aws/config**
This file specifies the default region and output format. Replace `[default]` with `[acloud]` if you want to configure this profile specifically.

```plaintext
[default]
region = us-east-1
output = json
```

## Using the Makefile or Terraform Commands

Follow the steps below to provision your infrastructure:

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

Makefile 
 1. **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```
 
 2. **Initialize Terraform**:
    ```bash
    make init
    ```
 
 3. **Plan the Infrastructure**:
    ```bash
    make plan
    ```
 
 4. **Apply the Infrastructure**:
    ```bash
    make apply
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


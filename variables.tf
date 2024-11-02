# variables.tf
variable "project" {
  description = "Project identifier used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket to store Okta events"
  type        = string
}

variable "enable_bucket_versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "s3_path_prefix" {
  description = "Base path prefix for S3 objects"
  type        = string
  default     = "okta-events"
}

variable "event_rule_name" {
  description = "Name of the EventBridge rule"
  type        = string
}

variable "event_rule_description" {
  description = "Description of the EventBridge rule"
  type        = string
  default     = "Route Okta events to S3 via Lambda"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
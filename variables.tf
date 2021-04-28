variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-2"
}

variable "bucket_name" {
  description = "AWS S3 Bucket Name"
  type        = string
}

variable "dynamo_name" {
  description = "AWS Dynamo Database Table Name"
  type        = string
}

variable "asset_tags" {
  description = "Default tags"
  type        = map
  default     = {
    Environment = "Production"
    IaC        = "True"
  }
}

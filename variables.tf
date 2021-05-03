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

variable "tf_role_name" {
  description = "Terraform S3 Role Policy for this bucket"
  type        = string
  default     = "TF-Admins"
}

variable "asset_tags" {
  description = "Default tags"
  type        = map(any)
  default = {
    Environment = "Production"
    IaC         = "True"
  }
}

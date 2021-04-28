![Validation Status](https://github.com/shrapk2/terraform-aws-s3-state-bootstrap/actions/workflows/default.yml/badge.svg)

# terraform-aws-s3-state-bootstrap

This project contains an "un-automated" bootstrap configuration for starting infrastructure as code. At present it contains the
Terraform code needed to create a shared state backend.

Along with prevent sensitive state data from residing within Git, it also allows for multiple administrators to manage Terraform's state and managed environments.

As a best practice, this Terraform state should remain disconnected from the overall infrastructure state, so this module should be executed once per account and not imported into the primary infrastructure state.

## Prerequisites

This code assumes the following:

- An AWS root account is already configured
- Appropriate access is given to create configuration contained within
- Basic familiarity with Terraform
- Terraform version >= v0.13

## Deployment

```bash
## You must specify the following environment variables
export AWS_ACCESS_KEY_ID="youraccesskey"
export AWS_SECRET_ACCESS_KEY="yoursecretkey"
export AWS_DEFAULT_REGION="us-awesome-1"

terraform init
terraform plan #validate changes
terraform apply

# confirm and watch it go crazy
```

## Artifacts

This Terraform configuration creates the following objects:

- S3 bucket for centralized state
  - This bucket cannot be deleted without policy modification
- DynamoDB for session locking
- S3 Generalized Hardening
- IAM policy to control the S3 bucket access

Upon execution of this code, you should add the following state arguments into any infrastructure Terraform modules:

#TODO: Clean these examples up:

```bash
export TF_VAR_

-backend-config="


bucket         = "terraform-aws-s3-state-bootstrap-tfstate"
key            = "core/terraform.tfstate"
region         = "us-east-2"
dynamodb_table = "terraform-aws-s3-state-bootstrap-tfstate-locks"
encrypt        = true

```

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

# Using Terraform to build a Private REST API with Amazon API Gateway
This project demonstrates how to use Terraform to build a private REST API with Amazon API Gateway that can only be accessed within a VPC

## Prerequisites
Before you begin, ensure you have the following:

- AWS account
- Terraform installed locally
- AWS CLI installed and configured with appropriate access credentials

## Architecture



## Project Structure
```bash
|- src/
	|- archives/
  |- events/
	|- handlers/
		|- libs/
			|- ddbDocClient.mjs
		|- create.mjs
		|- get.mjs
		|- update.mjs
		|- delete.mjs
|- locals.tf
|- provider.tf
|- terraform.tfvars.tf
|- variables.tf
|- api-vpc.tf
|- lambda.tf
|- security-groups.tf
|- apigw.tf
|- ec2.tf
|- client-vpc.tf
```

## Getting Started

1. Clone this repository:

   ```bash
   git clone https://github.com/FonNkwenti/tf-private-apigw.git
   ```
2. Navigate to the project directory:
   ```bash
   cd tf-private-apigw
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Review and modify `variables.tf` to customize your API configurations.
5. Create a `terraform.tfvars` file in the root directory and pass in values for `region`, `account_id`, `tag_environment` and `tag_project`

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

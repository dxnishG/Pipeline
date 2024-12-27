## Architecture

This project sets up a cloud infrastructure and CI/CD pipeline for a web application with two main components: Development and Batch Job.

### Development Components
- **CodeCommit**: Repository to store source code.
- **CodeBuild**: For building and packaging the application.
- **ECR**: To store and manage container images.

### Batch Job Components
- **S3 Buckets**: For storing input and output data.
- **Fargate**: For running batch jobs.

## Infrastructure

The infrastructure is provisioned using Terraform and includes:
- VPC with subnets
- IAM roles and policies for CodeBuild and Fargate
- S3 buckets for input and output data
- ECR repository
- Security measures (VPC security groups, IAM permissions)

## CI/CD Pipeline

The CI/CD pipeline is implemented using GitHub Actions and includes:
- Pulling the latest code from the repository
- Building and packaging the application using CodeBuild
- Pushing the resulting container image to ECR
- Integrating Sonarqube for code quality analysis
- Deploying the container image from ECR to Fargate for running batch jobs


## Usage

1. **Terraform Deployment**:
   - Trigger the `Terraform Deployment` workflow from GitHub Actions to provision the infrastructure.

2. **Application Deployment**:
   - Trigger the `Deploy to Amazon` workflow from GitHub Actions to deploy the application to ECS.

## Files

- `.aws/task-definition.json`: ECS task definition.
- `.github/workflows/aws.yml`: GitHub Actions workflow for deploying to Amazon ECS.
- `.github/workflows/terraform.yml`: GitHub Actions workflow for deploying infrastructure using Terraform.
- `Dockerfile`: Dockerfile for building the application image.
- `ecr.tf`: Terraform script for provisioning the infrastructure.
- `index.html`: Sample HTML file for the web application.

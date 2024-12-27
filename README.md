# Cloud Infrastructure & CI/CD Pipeline for Web Application

This project sets up a fully automated cloud infrastructure and CI/CD pipeline for a web application using **AWS** and **Terraform**. It leverages GitHub Actions to automate infrastructure provisioning and application deployment on AWS services.

---

## 🏗️ Infrastructure Setup

The infrastructure is provisioned using **Terraform** and includes the following components:

- **VPC** with multiple subnets
- **IAM Roles** and **Policies**
- **S3 Buckets** for storage
- **ECR Repository** for container images
- **ECS Cluster** and **Services** for container orchestration
- **Application Load Balancer** for routing traffic

---

## 🚀 CI/CD Pipeline

The CI/CD pipeline is implemented with **GitHub Actions** to automate the deployment process:

### Workflows:
1. **`terraform.yml`**: Automates the provisioning of cloud infrastructure using Terraform. The idea behind this is to manually trigger the Action.
2. **`aws.yml`**: Automatically deploys the web application to **ECS** whenever the repository receives a new push and sync.

---

## 🔧 Deployment Steps

Follow these steps to deploy the infrastructure and application:

### 1. **Provision Infrastructure with Terraform**
   - Trigger the `Terraform Deployment` workflow from **GitHub Actions** to provision the required AWS infrastructure.
   
### 2. **Deploy Application**
   - The `aws.yml` GitHub Actions workflow will automatically deploy the latest version of the application to ECS upon each code push.

---

## 📊 CI/CD History

You can view the complete history of CI/CD runs and check for any potential issues in the pipeline on the [GitHub Actions](https://github.com/dxnishG/Pipeline/actions) page.

---

## 📁 Project Files

Here are the key files in this project:

- **`.aws/task-definition.json`**: ECS task definition for the application container.
- **`.github/workflows/aws.yml`**: GitHub Actions workflow for deploying the application to ECS.
- **`.github/workflows/terraform.yml`**: GitHub Actions workflow for provisioning infrastructure with Terraform.
- **`Dockerfile`**: Dockerfile used to build the application image.
- **`ecr.tf`**: Terraform configuration for setting up the ECR repository and related resources.
- **`index.html`**: A sample HTML file representing the web application.

---

## 📞 Contact

If you have any questions or feedback, feel free to reach out!

- **Email**: [danishghani06@gmail.com](mailto:danishghani06@gmail.com)
- **GitHub**: [@dxnishG](https://github.com/dxnishG)
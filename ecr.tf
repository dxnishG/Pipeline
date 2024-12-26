# Variables
variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "repository_name" {
  description = "Name of the ECR repository"
  default     = "sample-repo6"
}

variable "ecs_service_name" {
  description = "ECS Service Name"
  default     = "my-ecs-service"
}

# Provider Configuration
provider "aws" {
  region = var.region
}

# Create VPC
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Create Internet Gateway for VPC
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "my-internet-gateway"
  }
}

# Create First Subnet (in AZ us-east-1a)
resource "aws_subnet" "example_1" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet-1"
  }
}

# Create Second Subnet (in AZ us-east-1b)
resource "aws_subnet" "example_2" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "my-subnet-2"
  }
}

# Create Security Group
resource "aws_security_group" "example" {
  name        = "ecs-service-sg"
  description = "Allow inbound HTTP traffic for ECS service"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow traffic from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# ECR Repository Resource
resource "aws_ecr_repository" "example" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = var.repository_name
    Environment = "Production"
  }
}

# ECS Cluster Resource
resource "aws_ecs_cluster" "example" {
  name = "my-ecs-cluster"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "example" {
  family                   = "my-ecs-task"
  execution_role_arn       = "arn:aws:iam::676206940164:role/ecs-task-execution-role"
  task_role_arn            = "arn:aws:iam::676206940164:role/ecs-task-execution-role"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = jsonencode([{
    name      = "my-container"
    image     = "${aws_ecr_repository.example.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }])

  tags = {
    Name = "my-ecs-task"
  }
}

# Create Application Load Balancer
resource "aws_lb" "example" {
  name               = "my-alb6"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.example.id]
  subnets            = [aws_subnet.example_1.id, aws_subnet.example_2.id]
  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "my-alb6"
  }
}

# Create Target Group with unique name (target type set to 'ip')
resource "aws_lb_target_group" "example" {
  name     = "my-target-group-${random_id.unique_id.hex}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.example.id
  
  # Set the target type to 'ip' for awsvpc network mode
  target_type = "ip"

  health_check {
    path = "/"
    interval = 30
    timeout  = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "my-target-group"
  }
}

# Create Listener for the Load Balancer
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # Add a rule to forward traffic to the target group
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

# ECS Service Resource
resource "aws_ecs_service" "example" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.example_1.id, aws_subnet.example_2.id]
    security_groups = [aws_security_group.example.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "my-container"
    container_port   = 80
  }

  depends_on = [aws_lb.example, aws_ecs_task_definition.example]
}

# Create S3 Buckets for input and output data
resource "aws_s3_bucket" "input_bucket" {
  bucket = "my-input-bucket"
  acl    = "private"

  tags = {
    Name = "my-input-bucket"
  }
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "my-output-bucket"
  acl    = "private"

  tags = {
    Name = "my-output-bucket"
  }
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "codebuild-role"
  }
}

# IAM Policy for CodeBuild
resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  description = "Policy for CodeBuild"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach IAM Policy to CodeBuild Role
resource "aws_iam_role_policy_attachment" "codebuild_role_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

# Output Repository URL
output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.example.repository_url
}

# Output ECS Cluster Name
output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.example.name
}

# Output Load Balancer DNS Name
output "load_balancer_dns" {
  description = "DNS Name of the load balancer"
  value       = aws_lb.example.dns_name
}

# Generate unique value for target group name
resource "random_id" "unique_id" {
  byte_length = 8
}

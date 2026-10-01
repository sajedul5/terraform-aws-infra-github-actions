# terraform-aws-infra-github-actions
Automate AWS Infrastructure Using Terraform &amp; GitHub Actions | Real-Time Project


# AWS Production Infrastructure - Demo Guide

## �️ Dedicated Infrastructure Repository

This repository follows the **Infrastructure as Code (IaC)** best practice of "Separation of Concerns". It is strictly dedicated to managing the AWS platform resources.

### 🔄 CI/CD Workflow (Infrastructure Only)
This repository uses a dedicated GitHub Actions workflow (`.github/workflows/terraform.yml`) that:
1.  **Plans** changes on Pull Requests (with Security & Linting checks).
2.  **Applies** changes to `dev`, `test`, or `prod` environments based on the branch.

### 🤝 Integration with Application Code
In a real-world scenario, this repository would interface with a separate **Application Repository**:
1.  **App Repo:** Builds the application and creates an AMI (Amazon Machine Image).
2.  **Infra Repo (This one):** Receives the new `ami_id` and performs a rolling update of the Auto Scaling Group.

*Note: For demonstration purposes, this repo currently uses a `user_data.sh` script to bootstrap Nginx, simulating the application layer.*

## �🎯 Overview

This demo guide walks you through deploying a production-grade 2-tier AWS infrastructure using Terraform. The infrastructure includes:

- **VPC** with public and private subnets across multiple AZs
- **Application Load Balancer** for traffic distribution
- **Auto Scaling Group** with dynamic scaling policies
- **NAT Gateway** for secure private subnet internet access
- **Security Groups** with proper network isolation
- **S3 Bucket** for static assets and logs
- **EC2 instances** running Nginx web servers

## 📋 Prerequisites

Before starting this demo, ensure you have:

1. **Terraform** (>= 1.0) installed
   ```bash
   terraform version
   ```

2. **AWS CLI** configured with credentials
   ```bash
   aws configure
   # Enter your AWS Access Key ID, Secret Access Key, and default region
   ```

3. **IAM Permissions** - Your AWS user needs permissions to create:
   - VPC, Subnets, Internet Gateway, NAT Gateway
   - EC2 instances, Auto Scaling Groups, Launch Templates
   - Application Load Balancer, Target Groups
   - Security Groups, Network ACLs
   - S3 Buckets
   - Elastic IPs

4. **AWS Account** with sufficient service quotas for the region

## 🏗️ Architecture Components

### Network Layer
- **VPC**: `10.0.0.0/16` CIDR block
- **Public Subnets**: `10.0.1.0/24`, `10.0.2.0/24` (AZ-a, AZ-b)
- **Private Subnets**: `10.0.11.0/24`, `10.0.12.0/24` (AZ-a, AZ-b)
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound internet access

### Compute Layer
- **Auto Scaling Group**: 2-6 instances based on CPU utilization
- **Launch Template**: Ubuntu-based EC2 instances with Nginx
- **Instance Type**: t2.micro (configurable)

### Load Balancing
- **Application Load Balancer**: Distributes traffic across healthy instances
- **Target Group**: Health checks on port 80
- **Listener**: HTTP on port 80

### Storage
- **S3 Bucket**: For application assets and ALB logs

## 🚀 Step-by-Step Demo

### Step 1: Clone and Navigate

```bash
# If not already in the 
git cloen https://github.com/sajedul5/terraform-aws-infra-github-actions.git
cd terraform-aws-infra-github-actions
```

### Step 2: Review Configuration Files

```bash
# View the main configuration
cat main.tf

# Check variables and their default values
cat variables.tf

# See what outputs will be displayed
cat outputs.tf
```

### Step 3: (Optional) Customize Variables

Create a `terraform.tfvars` file to override defaults:

```bash
cat > terraform.tfvars << EOF
region      = "us-east-1"
environment = "demo"
instance_type = "t2.micro"
min_size    = 2
max_size    = 4
desired_capacity = 2
EOF
```

### Step 4: Initialize Terraform

```bash
terraform init
```

**Expected Output:**
- Downloads AWS and Random providers
- Initializes backend
- Shows "Terraform has been successfully initialized!"

### Step 5: Validate Configuration

```bash
terraform validate
```

**Expected Output:** `Success! The configuration is valid.`

### Step 6: Plan the Deployment

```bash
terraform plan -out=tfplan
```

**What to Look For:**
- Total resources to be created (~30-35 resources)
- VPC, subnets, and networking components
- Security groups and rules
- Load balancer and target group
- Auto Scaling Group and launch template
- S3 bucket configuration

### Step 7: Apply the Configuration

```bash
terraform apply tfplan
```

**Duration:** Approximately 5-7 minutes

**What's Happening:**
1. VPC and networking setup (1 min)
2. Security groups creation (30 sec)
3. NAT Gateway allocation (2 min)
4. Load balancer provisioning (2 min)
5. Auto Scaling Group launch (1-2 min)
6. S3 bucket creation (10 sec)

### Step 8: Verify Outputs

After successful apply, you'll see:

```
Outputs:

load_balancer_dns = "app-lb-123456789.us-east-1.elb.amazonaws.com"
s3_bucket_name = "my-app-bucket-xxxxx"
vpc_id = "vpc-xxxxxxxxxxxxx"
public_subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]
private_subnet_ids = ["subnet-zzzzz", "subnet-aaaaa"]
```

### Step 9: Test the Application

```bash
# Get the load balancer DNS
ALB_DNS=$(terraform output -raw load_balancer_dns)

# Wait for instances to become healthy (2-3 minutes)
echo "Waiting for instances to be ready..."
sleep 180

# Test the application
curl http://$ALB_DNS
```

**Expected Output:**
```html
<h1>Welcome to the AWS Infrastructure Project - Proper 2-Tier Architecture (Ubuntu)</h1>
```

### Step 10: Test in Browser

```bash
echo "Access your application at: http://$ALB_DNS"
```


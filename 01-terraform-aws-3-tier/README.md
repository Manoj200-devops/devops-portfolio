# Secure and Scalable 3-Tier AWS Infrastructure with Terraform

## Project Overview

This project demonstrates how to build a secure and scalable 3-tier application infrastructure on AWS using Terraform.

The infrastructure is divided into three logical layers:

* **Public Layer** - Application Load Balancer
* **Application Layer** - EC2 application servers in private subnets
* **Database Layer** - PostgreSQL RDS in private subnets

Terraform is used to provision and manage the complete infrastructure using Infrastructure as Code (IaC).

## Architecture

```text
                           Internet
                              |
                              | HTTP :80
                              v
                    +---------------------+
                    | Application Load    |
                    | Balancer (ALB)      |
                    | Public Subnets      |
                    +----------+----------+
                               |
                    +----------+----------+
                    |                     |
                    v                     v
             +-------------+       +-------------+
             | EC2 App 1   |       | EC2 App 2   |
             | Private     |       | Private     |
             | Subnet      |       | Subnet      |
             +------+------+       +------+------+
                    |                     |
                    +----------+----------+
                               |
                        PostgreSQL :5432
                               |
                               v
                    +---------------------+
                    | PostgreSQL RDS       |
                    | Private DB Subnets  |
                    +---------------------+


                    Outbound Internet
                    from App Tier
                           |
                           v
                     NAT Gateway
                           |
                           v
                        Internet
```

## AWS Region

* **Region:** `ap-south-1` (Mumbai)
* **Availability Zones:**

  * `ap-south-1a`
  * `ap-south-1b`

## AWS Services Used

* Amazon VPC
* Amazon EC2
* Application Load Balancer (ALB)
* Amazon RDS for PostgreSQL
* Internet Gateway
* NAT Gateway
* Elastic IP
* Route Tables
* Security Groups
* AWS Systems Manager Parameter Store
* Terraform

## Network Design

The VPC uses the CIDR block `10.0.0.0/16` and is distributed across two Availability Zones for improved availability.

### Subnet Structure

| Tier        | Subnet          | CIDR           | Availability Zone | Internet Access           |
| ----------- | --------------- | -------------- | ----------------- | ------------------------- |
| Public      | Public Subnet 1 | `10.0.1.0/24`  | `ap-south-1a`     | Internet Gateway          |
| Public      | Public Subnet 2 | `10.0.2.0/24`  | `ap-south-1b`     | Internet Gateway          |
| Application | App Subnet 1    | `10.0.11.0/24` | `ap-south-1a`     | NAT Gateway               |
| Application | App Subnet 2    | `10.0.12.0/24` | `ap-south-1b`     | NAT Gateway               |
| Database    | DB Subnet 1     | `10.0.21.0/24` | `ap-south-1a`     | No direct internet access |
| Database    | DB Subnet 2     | `10.0.22.0/24` | `ap-south-1b`     | No direct internet access |

### Routing Design

* Public subnets use the Internet Gateway for internet connectivity.
* Application subnets use the NAT Gateway for outbound internet access.
* Database subnets do not have a default route to the internet.
* The Application Load Balancer is deployed in the public subnets.
* EC2 application servers are deployed in private application subnets.
* PostgreSQL RDS is deployed in private database subnets.

This design prevents the application servers and database from being directly accessible from the public internet.

## Security Design

Security is implemented using AWS Security Groups to control communication between the different tiers.

### Application Load Balancer Security Group

* Allows HTTP traffic on port `80` from the internet.
* Allows outbound traffic.

### Application Server Security Group

* Allows HTTP traffic on port `80` only from the ALB security group.
* Does not allow direct HTTP access from the internet.
* Allows outbound traffic for application requirements.

### Database Security Group

* Allows PostgreSQL traffic on port `5432` only from the application server security group.
* Does not allow direct database access from the internet.
* Allows outbound traffic.

### Security Flow

```text
Internet
   |
   | HTTP :80
   v
ALB Security Group
   |
   | HTTP :80
   v
Application Security Group
   |
   | PostgreSQL :5432
   v
Database Security Group
```

This follows the principle of least privilege by allowing each tier to communicate only with the required tier.

## Compute Layer

Two Amazon Linux EC2 instances are deployed across the private application subnets.

### Application Servers

| Server       | Subnet       | Instance Type |
| ------------ | ------------ | ------------- |
| App Server 1 | App Subnet 1 | `t3.micro`    |
| App Server 2 | App Subnet 2 | `t3.micro`    |

The EC2 instances run Apache HTTP Server and serve a simple application page.

The instances do not have public IP addresses and receive application traffic through the Application Load Balancer.

## Application Load Balancer

An internet-facing Application Load Balancer is deployed across the two public subnets.

### Configuration

* **Load Balancer:** `dev-alb`
* **Protocol:** HTTP
* **Port:** `80`
* **Scheme:** Internet-facing
* **Target Group:** `dev-app-tg`
* **Health Check:** HTTP `/`
* **Target Port:** `80`

The ALB distributes incoming requests across the two application servers and performs health checks to ensure traffic is sent only to healthy targets.

## Database Layer

Amazon RDS for PostgreSQL is deployed in the private database subnets.

### Configuration

* **Engine:** PostgreSQL
* **Engine Version:** `17`
* **Instance Class:** `db.t3.micro`
* **Storage:** `20 GB GP3`
* **Storage Encryption:** Enabled
* **Public Access:** Disabled
* **Database Port:** `5432`
* **Database Name:** `appdb`

The database is protected by a security group that allows PostgreSQL traffic only from the application server security group.

## NAT Gateway

A NAT Gateway is deployed in a public subnet.

It provides outbound internet connectivity to the private application subnets while preventing unsolicited inbound internet connections to the private EC2 instances.

The application route table contains:

```text
0.0.0.0/0 -> NAT Gateway
```

The NAT Gateway uses an Elastic IP address and is deployed in the public subnet.

## Terraform Project Structure

```text
three-tier-terraform/
│
├── main.tf
├── providers.tf
├── variables.tf
├── terraform.tfvars
├── versions.tf
├── outputs.tf
├── .gitignore
├── .terraform.lock.hcl
└── README.md
```

### File Responsibilities

| File                  | Purpose                                                     |
| --------------------- | ----------------------------------------------------------- |
| `main.tf`             | Defines AWS infrastructure resources                        |
| `providers.tf`        | Configures the AWS provider and default tags                |
| `variables.tf`        | Defines reusable Terraform variables                        |
| `terraform.tfvars`    | Provides environment-specific variable values               |
| `versions.tf`         | Defines Terraform and provider version requirements         |
| `outputs.tf`          | Exposes important infrastructure information                |
| `.gitignore`          | Prevents sensitive and generated files from being committed |
| `.terraform.lock.hcl` | Locks provider versions for consistent deployments          |
| `README.md`           | Project documentation                                       |

## Infrastructure Managed by Terraform

Terraform provisions and manages:

* VPC
* Public subnets
* Private application subnets
* Private database subnets
* Internet Gateway
* NAT Gateway
* Elastic IP
* Route tables
* Route table associations
* Security Groups
* Application Load Balancer
* ALB Target Group
* ALB Listener
* EC2 application servers
* RDS subnet group
* PostgreSQL RDS instance

## Deployment Process

### 1. Initialize Terraform

```bash
terraform init
```

Initializes the Terraform working directory and downloads the required providers.

### 2. Format the Configuration

```bash
terraform fmt
```

Formats Terraform configuration files according to the standard Terraform style.

### 3. Validate the Configuration

```bash
terraform validate
```

Checks whether the Terraform configuration is syntactically valid and internally consistent.

### 4. Review the Infrastructure Plan

```bash
terraform plan
```

Creates an execution plan showing which AWS resources Terraform will create, modify, or destroy.

### 5. Deploy the Infrastructure

```bash
terraform apply
```

Creates or updates the AWS infrastructure according to the Terraform configuration.

### 6. View Infrastructure Outputs

```bash
terraform output
```

Displays important infrastructure information such as:

* ALB DNS name
* EC2 instance IDs
* EC2 private IP addresses
* RDS endpoint
* RDS port
* VPC ID

### 7. Verify Infrastructure State

```bash
terraform plan
```

After deployment, Terraform should report:

```text
No changes. Your infrastructure matches the configuration.
```

This confirms that the deployed AWS infrastructure matches the Terraform configuration.

## Validation

The infrastructure was successfully validated through:

* Terraform configuration validation
* Terraform execution plan
* AWS Console verification
* ALB application access
* ALB target health checks
* RDS availability check
* Final Terraform drift check

The ALB successfully routes HTTP traffic to the healthy EC2 application servers.

The PostgreSQL RDS instance is deployed privately and is not publicly accessible.

## Key DevOps Concepts Demonstrated

This project demonstrates practical experience with:

* Infrastructure as Code
* Terraform
* AWS networking
* VPC design
* Public and private subnets
* Availability Zones
* Route tables
* Internet Gateway
* NAT Gateway
* Security Groups
* Load balancing
* EC2
* Amazon RDS
* High availability concepts
* Least-privilege network access
* Terraform state management
* Terraform variables and outputs
* Infrastructure validation
* Infrastructure drift detection

## Security Considerations

Sensitive information should not be committed to Git.

The following files and generated Terraform data are excluded using `.gitignore`:

```text
.terraform/
*.tfstate
*.tfstate.*
crash.log
terraform.tfvars
```

The database password is stored as a sensitive Terraform variable and is not exposed through Terraform outputs.

For production environments, secrets should be managed using a dedicated secrets-management solution such as AWS Secrets Manager rather than storing passwords in local variable files.

## Cleanup

This project uses AWS resources that may incur charges.

When the infrastructure is no longer required, it can be removed using:

```bash
terraform destroy
```

Review the Terraform destroy plan carefully before confirming the operation.

## Project Outcome

The project successfully provisions a complete 3-tier AWS architecture using Terraform.

The final environment provides:

* Public access through an Application Load Balancer
* Two private EC2 application servers
* Outbound internet access from the application tier through NAT Gateway
* A private PostgreSQL RDS database
* Network isolation between application and database tiers
* Security Group-based traffic control
* Infrastructure fully managed through Terraform

## Interview Explanation

### Project Summary

> I built a secure and scalable 3-tier AWS infrastructure using Terraform. I designed a VPC across two Availability Zones with public subnets for the Application Load Balancer, private application subnets for two EC2 instances, and private database subnets for PostgreSQL RDS. The ALB receives HTTP traffic from the internet and distributes it to the private EC2 instances. The application servers use a NAT Gateway for outbound internet access, while the RDS database is isolated from the internet and only accepts PostgreSQL traffic from the application security group. I used Terraform to provision, manage, validate, and track the entire infrastructure as Infrastructure as Code.

### Key Challenges Solved

* Designed public and private subnet architecture.
* Configured routing between public, application, and database tiers.
* Implemented NAT Gateway for private subnet outbound connectivity.
* Restricted application traffic using Security Groups.
* Configured an internet-facing ALB with healthy private EC2 targets.
* Deployed PostgreSQL RDS in private subnets.
* Used Terraform state to manage the complete infrastructure.
* Verified the final infrastructure using `terraform plan` and achieved a clean state with no configuration drift.

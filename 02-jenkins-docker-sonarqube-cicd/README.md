# Jenkins + Docker + SonarQube End-to-End CI/CD Pipeline

## Project Overview

This project demonstrates an **end-to-end automated CI/CD pipeline** using Jenkins, GitHub, SonarQube, Docker, Docker Hub, and AWS EC2.

The goal of the project is to automate the complete application delivery process:

```text
Developer
    |
    | git push
    v
GitHub
    |
    | Webhook
    v
Jenkins Controller
    |
    v
Jenkins Agent
    |
    +---- Test
    |
    +---- SonarQube Analysis
    |
    +---- Docker Build
    |
    +---- Docker Push
    |
    v
Docker Hub
    |
    v
Deployment Server
    |
    v
Docker Container
    |
    v
Web Application
```

The project demonstrates practical DevOps concepts including:

* Continuous Integration
* Continuous Delivery / Deployment
* Jenkins Controller and Agent architecture
* Pipeline as Code
* GitHub Webhooks
* Automated testing
* Static code analysis
* SonarQube
* Docker containerization
* Docker image management
* Docker Hub
* SSH-based deployment
* AWS EC2
* AWS Security Groups
* Jenkins credentials
* Infrastructure and application troubleshooting
* Security-focused container configuration

---

# Project Status

**Status: Completed and Successfully Validated**

The complete CI/CD workflow was implemented and tested.

A real application change was pushed to GitHub and automatically triggered Jenkins through a GitHub Webhook.

The pipeline successfully:

1. Checked out the source code.
2. Executed the application test.
3. Performed SonarQube analysis.
4. Built the Docker image.
5. Pushed the image to Docker Hub.
6. Connected to the deployment server through SSH.
7. Pulled the updated Docker image.
8. Recreated the application container.
9. Served the updated application through the deployment server.

The automatic deployment was validated by updating the application from version 2 to version 3 and confirming the updated version through the browser.

---

# Architecture

```text
                         Developer
                             |
                             | git push
                             v
                    +------------------+
                    |     GitHub       |
                    | Source Repository|
                    +------------------+
                             |
                             | Webhook
                             v
                    +------------------+
                    | Jenkins          |
                    | Controller       |
                    |                  |
                    | Pipeline Control  |
                    +------------------+
                             |
                             | SSH
                             v
                    +------------------+
                    | Jenkins Agent    |
                    |                  |
                    | Build            |
                    | Test             |
                    | SonarQube Scan   |
                    | Docker Build     |
                    | Docker Push      |
                    +------------------+
                       |           |
                       |           |
                       |           v
                       |    +---------------+
                       |    |  SonarQube    |
                       |    | Code Analysis |
                       |    +---------------+
                       |
                       v
                +------------------+
                |   Docker Hub     |
                | Container Image  |
                +------------------+
                       |
                       | docker pull
                       v
                +------------------+
                | Deployment       |
                | Server           |
                |                  |
                | Docker Container |
                +------------------+
                       |
                       | HTTP : 80
                       v
                    Browser
```

---

# AWS Infrastructure

The project uses multiple AWS EC2 instances.

| Server             | Purpose                               |
| ------------------ | ------------------------------------- |
| Jenkins Controller | Pipeline orchestration and Jenkins UI |
| Jenkins Agent      | Executes CI/CD workloads              |
| SonarQube Server   | Static code analysis                  |
| Deployment Server  | Runs the deployed Docker application  |

The servers communicate using private IP addresses where appropriate.

---

# Components Used

| Technology          | Purpose                            |
| ------------------- | ---------------------------------- |
| Git                 | Version control                    |
| GitHub              | Source code repository             |
| GitHub Webhook      | Automatically triggers Jenkins     |
| Jenkins             | CI/CD automation                   |
| Jenkins Controller  | Pipeline orchestration             |
| Jenkins Agent       | Pipeline execution                 |
| SonarQube           | Static code analysis               |
| Docker              | Application containerization       |
| Docker Hub          | Container image registry           |
| AWS EC2             | Hosts CI/CD infrastructure         |
| AWS Security Groups | Network access control             |
| SSH                 | Secure server-to-server deployment |
| Linux               | Server operating system            |

---

# Application

The project contains a simple HTML application.

The application is intentionally lightweight because the primary purpose of this project is to demonstrate the **CI/CD process rather than application development**.

Application structure:

```text
application/
│
├── Dockerfile
├── index.html
├── sonar-project.properties
└── test.sh
```

---

# Application Structure

## index.html

Contains the web application.

The page displays information about the CI/CD pipeline.

Example:

```text
DevOps CI/CD Demo Application - v3

This application is deployed using Jenkins, Docker and AWS.


GitHub → Jenkins → SonarQube → Docker → Deployment
```

---

# test.sh

A simple automated test is included in the project.

```bash
#!/bin/bash

if grep -q "DevOps CI/CD Demo Application" index.html; then

    echo "Test passed: Application title found."
    exit 0
else
    echo "Test failed: Application title not found."
    exit 1
fi
```

The script verifies that the expected application title exists in `index.html`.

If the title exists:

```text
exit 0
```

The Jenkins pipeline continues.

If the title is missing:

```text
exit 1
```

The pipeline fails.

This demonstrates how automated testing can act as a quality gate before further CI/CD stages.

---

# Dockerfile

The application is packaged using Docker.

The Dockerfile uses:

```dockerfile
FROM nginx:alpine
```

The application is served using Nginx.

The container is configured to run Nginx as a **non-root user**.

The container listens on:

```text
8080
```

instead of the default privileged HTTP port 80.

The application container exposes:

```dockerfile
EXPOSE 8080
```

---

# Why Run the Container as a Non-Root User?

During SonarQube analysis, the original Docker configuration generated a security finding because the Nginx container used the root user by default.

The Dockerfile was therefore modified to run as:

```dockerfile
USER nginx
```

Nginx configuration and required directories were adjusted so that the non-root user could run the service correctly.

The container also uses:

```text
PID file: /tmp/nginx.pid
```

This avoids requiring root privileges for the PID file.

This demonstrates an important container-security principle:

> Applications inside containers should run with the minimum privileges required.

---

# Docker Port Mapping

The deployment server runs the container using:

```bash
docker run -d \
    --name devops-cicd-demo \
    -p 80:8080 \
    mgmanoj2000/devops-cicd-demo:latest
```

The mapping:

```text
80:8080
```

means:

```text
Deployment Server Port 80
          |
          v
Container Port 8080
          |
          v
Nginx
```

Therefore users can access the application through:

```text
http://<deployment-server-public-ip>
```

while Nginx continues running as the non-root user on port 8080 inside the container.

---

# SonarQube

SonarQube is used to perform static code analysis.

It helps identify potential:

* Bugs
* Vulnerabilities
* Code smells
* Maintainability issues
* Security issues

The Jenkins pipeline integrates with SonarQube using the Jenkins SonarQube Scanner integration.

The configured SonarQube server is:

```text
http://<sonarqube-private-ip>:9000
```

The SonarQube project used for this application is:

```text
Project Name: DevOps CI/CD Demo
Project Key: devops-cicd-demo
```

---

# SonarQube Configuration

The application contains:

```text
sonar-project.properties
```

Configuration:

```properties
sonar.projectKey=devops-cicd-demo
sonar.projectName=DevOps CI/CD Demo
sonar.sources=.
sonar.sourceEncoding=UTF-8
```

This tells the SonarQube scanner which project to analyze and where the source code is located.

---

# Docker Hub

Docker Hub is used as the container image registry.

The Jenkins pipeline pushes the application image to:

```text
mgmanoj2000/devops-cicd-demo
```

The image is tagged:

```text
latest
```

The pipeline performs:

```text
Docker Build
      |
      v
Docker Tag
      |
      v
Docker Login
      |
      v
Docker Push
      |
      v
Docker Hub
```

---

# Jenkins Architecture

The project uses a dedicated Jenkins Controller and Jenkins Agent.

## Jenkins Controller

The Controller is responsible for:

* Jenkins web interface
* Pipeline orchestration
* Job management
* Scheduling
* Credentials management
* Plugin management
* Pipeline configuration

The Controller coordinates the pipeline but does not perform the main application build workload.

---

# Jenkins Agent

The Jenkins Agent performs the actual CI/CD workload.

The Agent is configured with:

```text
Label: docker-agent
Executors: 1
Remote root: /home/ubuntu/jenkins
```

The Agent has:

* Java
* Docker
* Jenkins connectivity
* Required build tools

The Jenkins pipeline uses:

```groovy
agent {
    label 'docker-agent'
}
```

Therefore all pipeline stages execute on the Jenkins Agent.

---

# Why Use a Jenkins Agent?

Separating the Controller and Agent provides a cleaner architecture.

```text
Controller
     |
     | Orchestrates
     v
Agent
     |
     +---- Build
     +---- Test
     +---- Scan
     +---- Docker
```

This prevents the Jenkins Controller from becoming the main workload execution server.

In larger environments, additional agents can be added for different workloads.

---

# Jenkins Pipeline

The pipeline is defined using a Jenkinsfile.

Project location:

```text
02-jenkins-docker-sonarqube-cicd/
│
├── Jenkinsfile
└── application/
```

The Jenkinsfile uses Jenkins Declarative Pipeline syntax.

---

# Pipeline Stages

The pipeline contains the following stages:

```text
Checkout
   ↓
Test
   ↓
SonarQube Analysis
   ↓
Docker Build
   ↓
Docker Push
   ↓
Deploy
```

---

# Stage 1 — Checkout

```groovy
stage('Checkout') {
    steps {
        checkout scm
    }
}
```

This stage retrieves the source code from GitHub.

The Jenkins job is configured to use the portfolio repository:

```text
https://github.com/Manoj200-devops/devops-portfolio.git
```

The Jenkinsfile is located at:

```text
02-jenkins-docker-sonarqube-cicd/Jenkinsfile
```

---

# Stage 2 — Test

```groovy
stage('Test') {
    steps {
        sh '''
            cd 02-jenkins-docker-sonarqube-cicd/application
            ./test.sh
        '''
    }
}
```

The test script checks whether the expected application title exists.

If the test fails, Jenkins stops the pipeline.

This prevents a failed application from proceeding to later stages.

---

# Stage 3 — SonarQube Analysis

The pipeline integrates with SonarQube:

```groovy
withSonarQubeEnv('sonarqube')
```

The Jenkins SonarScanner installation is then used:

```groovy
def scannerHome = tool 'SonarScanner'
```

The scanner analyzes the application source code.

The results are sent to the configured SonarQube project.

---

# Stage 4 — Docker Build

The application Docker image is created using:

```bash
docker build -t devops-cicd-demo:latest .
```

The Docker build process:

```text
Dockerfile
     +
Application Source
     |
     v
Docker Image
```

The resulting image is:

```text
devops-cicd-demo:latest
```

---

# Stage 5 — Docker Push

Jenkins retrieves the Docker Hub credentials from Jenkins Credentials.

The credentials are not hard-coded in the Jenkinsfile.

The pipeline uses:

```groovy
withCredentials([
    usernamePassword(
        credentialsId: 'dockerhub-credentials',
        usernameVariable: 'DOCKER_USERNAME',
        passwordVariable: 'DOCKER_PASSWORD'
    )
])
```

The image is then tagged:

```bash
docker tag devops-cicd-demo:latest \
    $DOCKER_USERNAME/devops-cicd-demo:latest
```

And pushed:

```bash
docker push \
    $DOCKER_USERNAME/devops-cicd-demo:latest
```

---

# Stage 6 — Deploy

The final stage automatically deploys the image to the deployment server.

Jenkins uses the SSH Agent plugin and the credential:

```text
jenkins-deployment-ssh
```

The pipeline connects to the deployment server and executes:

```bash
docker pull mgmanoj2000/devops-cicd-demo:latest
```

The previous container is stopped:

```bash
docker stop devops-cicd-demo
```

Then removed:

```bash
docker rm devops-cicd-demo
```

The new container is started:

```bash
docker run -d \
    --name devops-cicd-demo \
    -p 80:8080 \
    mgmanoj2000/devops-cicd-demo:latest
```

Therefore the deployment is fully automated.

---

# GitHub Webhook

GitHub Webhooks are used to automatically trigger the Jenkins pipeline when code is pushed.

The webhook endpoint is:

```text
http://<jenkins-public-ip>:8080/github-webhook/
```

Jenkins is configured with:

```text
GitHub hook trigger for GITScm polling
```

The GitHub webhook is configured to trigger on:

```text
Push events
```

---

# Automated Trigger Flow

Without a webhook, the pipeline would require:

```text
Developer
    |
    v
GitHub
    |
    v
Jenkins
    |
    v
Build Now
```

With the webhook:

```text
Developer
    |
    | git push
    v
GitHub
    |
    | webhook
    v
Jenkins
    |
    v
Pipeline automatically starts
```

This removes the need to manually select **Build Now** after every code change.

---

# Jenkins Credentials

Sensitive credentials are stored in Jenkins Credentials instead of being placed directly in the Jenkinsfile.

Credentials used in the project include:

```text
dockerhub-credentials
sonarqube-token
jenkins-deployment-ssh
jenkins-agent-ssh
```

Examples include:

* Docker Hub access token
* SonarQube token
* SSH private key for deployment
* SSH private key for Jenkins Agent connectivity

Sensitive values should never be committed to GitHub.

---

# AWS Security Groups

Security Groups control communication between the EC2 servers.

The required communication paths include:

```text
Developer
    |
    | HTTP : 8080
    v
Jenkins Controller

Jenkins Controller
    |
    | SSH : 22
    v
Jenkins Agent

Jenkins Agent
    |
    | HTTP : 9000
    v
SonarQube

Jenkins Agent
    |
    | SSH : 22
    v
Deployment Server

Internet
    |
    | HTTP : 80
    v
Deployment Server
```

The Deployment Server allows SSH from the Jenkins Agent Security Group so that automated deployments can connect securely through the private network.

---

# Deployment Process

## 1. Developer changes the application

Example:

```html
<h1>DevOps CI/CD Demo Application - v3</h1>
```

---

## 2. Commit the change

```bash
git add application/index.html
```

Then:

```bash
git commit -m "Update application to version 3"
```

---

## 3. Push to GitHub

```bash
git push origin master
```

---

## 4. GitHub sends webhook

GitHub sends a webhook notification to Jenkins.

```text
GitHub
   |
   | Push Event
   v
Jenkins
```

---

## 5. Jenkins starts the pipeline

The Jenkins pipeline automatically begins.

```text
Checkout
   ↓
Test
   ↓
SonarQube
   ↓
Docker Build
   ↓
Docker Push
   ↓
Deploy
```

---

## 6. Docker image is pushed

The image is pushed to:

```text
mgmanoj2000/devops-cicd-demo:latest
```

---

## 7. Deployment server pulls the image

```bash
docker pull mgmanoj2000/devops-cicd-demo:latest
```

---

## 8. Existing container is replaced

The existing container is stopped and removed.

A new container is started from the updated image.

---

## 9. Application is verified

The application is accessed through:

```text
http://<deployment-server-public-ip>
```

The updated version should be displayed.

---

# Validation

The project was validated at multiple levels.

## GitHub

Verified:

* Source code available
* Jenkinsfile available
* Application files available
* Git commits pushed successfully

---

## Jenkins

Verified:

* Controller online
* Agent online
* Pipeline executes successfully
* All stages complete successfully
* GitHub webhook triggers builds automatically

---

## SonarQube

Verified:

* Project created
* Jenkins integration working
* Source analysis completed
* Findings visible in SonarQube

A security finding related to the Nginx container running as root was identified and addressed by modifying the Dockerfile to run Nginx as a non-root user.

---

## Docker

Verified:

```bash
docker build
docker run
docker ps
```

The application container was successfully built and executed.

---

## Docker Hub

Verified:

```text
mgmanoj2000/devops-cicd-demo
```

The pipeline successfully pushed the image to Docker Hub.

---

## Deployment Server

Verified:

```bash
docker pull
docker stop
docker rm
docker run
```

The application was accessible through HTTP port 80.

---

## End-to-End Validation

A real application change was made and pushed to GitHub.

The webhook automatically triggered Jenkins.

The updated application successfully travelled through:

```text
GitHub
   ↓
Webhook
   ↓
Jenkins
   ↓
Test
   ↓
SonarQube
   ↓
Docker Build
   ↓
Docker Hub
   ↓
Deployment Server
   ↓
Updated Application
```

This confirmed that the complete automated CI/CD workflow was functioning.

---

# Problems Encountered and Solutions

## Problem 1 — Jenkins /tmp Space

Jenkins initially encountered a small `/tmp` filesystem.

The `/tmp` filesystem was approximately:

```text
953 MB
```

This affected Jenkins operation.

The `/tmp` mount was increased to approximately:

```text
2 GB
```

After restarting the server, Jenkins operated correctly.

---

# Problem 2 — Docker Container Running as Root

SonarQube identified a security issue because the Nginx Docker image ran with root as the default container user.

The Dockerfile was modified to:

```dockerfile
USER nginx
```

Nginx was also moved to port:

```text
8080
```

and required directories were given appropriate ownership.

This allowed Nginx to run successfully without root privileges.

---

# Problem 3 — Test Script Permission

The Jenkins pipeline initially failed because:

```text
./test.sh: Permission denied
```

The file did not have the executable permission in Git.

The Git file mode was updated using:

```bash
git update-index --chmod=+x application/test.sh
```

The file was then committed with executable permissions.

The pipeline subsequently executed the test successfully.

---

# Problem 4 — Docker Hub Authentication

Docker Hub authentication was initially performed manually to verify connectivity.

A Docker Hub access token was then created and stored in Jenkins Credentials.

The Jenkins pipeline uses the stored credential to authenticate securely.

This removed the need to manually log in during every deployment.

---

# Problem 5 — Jenkins Deployment SSH

A dedicated SSH key was created for Jenkins deployment.

The public key was added to the Deployment Server:

```text
~/.ssh/authorized_keys
```

The private key was stored securely in Jenkins Credentials.

This allowed Jenkins to execute Docker commands remotely without requiring manual SSH login.

---

# Problem 6 — GitHub Webhook Connection

The GitHub webhook initially failed to connect to Jenkins.

The Jenkins Controller Security Group allowed port 8080 only from the developer's IP address.

GitHub's webhook servers therefore could not reach Jenkins.

The Jenkins Security Group was updated to allow:

```text
TCP 8080
Source: 0.0.0.0/0
```

The webhook was then successfully delivered.

---

# Security Considerations

The project incorporates several security practices:

* Jenkins credentials are stored in Jenkins Credentials.
* Docker Hub uses an access token rather than a password.
* Deployment uses a dedicated SSH key.
* The Docker container runs Nginx as a non-root user.
* SonarQube is used for security/code analysis.
* Deployment Server SSH access is restricted to the Jenkins Agent Security Group.
* AWS Security Groups control network communication.
* Sensitive credentials are not committed to GitHub.

For a production environment, additional controls should be considered.

---

# Production Improvements

The project is intentionally designed as a learning and portfolio implementation.

A production implementation could improve the architecture by adding:

### HTTPS

Use:

```text
GitHub
   |
 HTTPS
   |
Load Balancer / Reverse Proxy
   |
Jenkins
```

instead of exposing Jenkins through plain HTTP.

---

### Secure Webhook Access

Instead of broadly exposing Jenkins port 8080, use:

* Reverse proxy
* HTTPS
* Access control
* Webhook secret
* Restricted network architecture

---

### Immutable Docker Tags

Instead of using:

```text
latest
```

production pipelines should preferably use immutable tags such as:

```text
devops-cicd-demo:<git-commit-sha>
```

This makes deployments traceable and allows easier rollback.

---

### Remote Terraform State

The AWS infrastructure for this project could also be managed through Terraform using:

* S3 backend
* State locking
* IAM controls

---

### Secrets Management

Instead of storing application secrets directly in configuration, production environments can use:

```text
AWS Secrets Manager
```

or another approved secrets-management platform.

---

### Jenkins High Availability

For larger environments, Jenkins infrastructure can be designed with:

* Multiple agents
* Dedicated build nodes
* Externalized configuration
* Monitoring
* Backup and recovery

---

### Container Orchestration

The deployment server can eventually be replaced with:

```text
Amazon ECS
```

or:

```text
Amazon EKS
```

for scalable container orchestration.

---

# Terraform Integration Opportunity

The AWS EC2 infrastructure used in this project can be provisioned using Terraform.

A future version could automate:

```text
Terraform
   |
   +---- Jenkins Controller
   |
   +---- Jenkins Agent
   |
   +---- SonarQube Server
   |
   +---- Deployment Server
   |
   +---- Security Groups
   |
   +---- Networking
```

This would combine Infrastructure as Code with CI/CD automation.

---

# Repository Structure

The portfolio repository contains the project under:

```text
devops-portfolio/
│
└── 02-jenkins-docker-sonarqube-cicd/
    │
    ├── Jenkinsfile
    │
    ├── README.md
    │
    └── application/
        │
        ├── Dockerfile
        ├── index.html
        ├── sonar-project.properties
        └── test.sh
```

---

# Technologies Learned

This project provided practical experience with:

### Jenkins

* Controller and Agent architecture
* Jobs
* Pipelines
* Declarative Pipeline syntax
* Jenkinsfile
* Plugins
* Credentials
* Build triggers
* SSH Agent

### GitHub

* Git repository management
* Branches
* Commits
* Push operations
* GitHub Webhooks

### SonarQube

* Static code analysis
* Security findings
* Code quality analysis
* Jenkins integration

### Docker

* Dockerfiles
* Images
* Containers
* Port mapping
* Docker Hub
* Non-root containers
* Container deployment

### AWS

* EC2
* Security Groups
* Private networking
* Server-to-server communication

### Linux

* SSH
* File permissions
* System services
* Docker administration
* Filesystem configuration

---

# CI/CD Concepts Demonstrated

## Continuous Integration

Every code change can trigger an automated pipeline.

```text
Code Change
    ↓
Git Push
    ↓
Webhook
    ↓
Jenkins
    ↓
Test
    ↓
Code Analysis
```

---

## Continuous Delivery / Deployment

The pipeline continues beyond testing and automatically deploys the application.

```text
Test
 ↓
SonarQube
 ↓
Docker Build
 ↓
Docker Push
 ↓
Deploy
```

---

## Pipeline as Code

The CI/CD process is stored in:

```text
Jenkinsfile
```

This means the pipeline configuration is version controlled alongside the application source code.

---

## Automation

The project removes several manual steps.

Without automation:

```text
Build manually
     ↓
Push manually
     ↓
SSH manually
     ↓
Pull image manually
     ↓
Restart container manually
```

With the pipeline:

```text
git push
   ↓
Everything happens automatically
```

---

# Project Outcome

This project demonstrates how a source-code change can move through a complete automated software delivery pipeline.

The final workflow is:

```text
                 ┌──────────────┐
                 │   Developer  │
                 └──────┬───────┘
                        │
                     git push
                        │
                        ▼
                 ┌──────────────┐
                 │    GitHub    │
                 └──────┬───────┘
                        │
                     Webhook
                        │
                        ▼
              ┌────────────────────┐
              │ Jenkins Controller  │
              └─────────┬──────────┘
                        │
                        ▼
              ┌────────────────────┐
              │   Jenkins Agent    │
              └─────────┬──────────┘
                        │
          ┌─────────────┼──────────────┐
          │             │              │
          ▼             ▼              ▼
       Testing      SonarQube      Docker Build
                                        │
                                        ▼
                                  Docker Push
                                        │
                                        ▼
                                  Docker Hub
                                        │
                                        ▼
                              Deployment Server
                                        │
                                        ▼
                                Docker Container
                                        │
                                        ▼
                                   Application
```

The project successfully demonstrates a complete **GitHub → Jenkins → SonarQube → Docker → Docker Hub → Deployment** workflow with automatic GitHub Webhook triggering and automated deployment.


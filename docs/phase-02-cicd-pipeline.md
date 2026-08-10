Phase 2 – Continuous Integration and Continuous Deployment (CI/CD)

================================================================================================================================================

Objective

The objective of this phase is to automate the complete software delivery lifecycle.

Whenever a developer pushes code to GitHub, Jenkins automatically builds the application, performs code quality and security checks, builds a Docker image, pushes the image to Amazon ECR, and deploys the latest version into the Amazon EKS cluster.

This eliminates manual deployment and provides a repeatable, reliable, and production-like CI/CD workflow.

================================================================================================================================================

Files Used
------------

Jenkinsfile

Purpose:
Defines the complete CI/CD pipeline.

Pipeline Stages

Clone Source Code
Compile Application
Run Unit Tests
SonarQube Code Analysis
Sonar Quality Gate
OWASP Dependency Check
Build Docker Image
Trivy Image Scan
Push Docker Image to Amazon ECR
Update Kubernetes Deployment Manifest
Deploy Application to Amazon EKS

Why this file exists

The Jenkinsfile automates the entire application delivery process and ensures every deployment follows the same validated workflow.

================================================================================================================================================

application/Dockerfile

Purpose

Builds the Docker image for the Spring Boot application.

Why this file exists

Packages the application together with its runtime environment so it can run consistently across different environments.

================================================================================================================================================

kubernetes/namespace.yaml

Purpose

Creates the Kubernetes namespace.

Resources Created

application Namespace

Why this file exists

Keeps application resources isolated from monitoring and system components.

================================================================================================================================================

kubernetes/configmap.yaml

Purpose

Creates the application's ConfigMap.

Resources Created

ConfigMap

Why this file exists

Stores non-sensitive configuration separately from the application image, allowing configuration changes without rebuilding Docker images.

================================================================================================================================================

kubernetes/secret.yaml

Purpose

Creates Kubernetes Secrets.

Resources Created

Secret

Why this file exists

Stores sensitive application values securely instead of embedding them inside source code.

================================================================================================================================================

kubernetes/deployment.yaml

Purpose

Deploys the application into Amazon EKS.

Resources Created

Deployment
ReplicaSet
Pods

Why this file exists

Defines how the application should run inside Kubernetes, including:

Number of replicas
Docker image
Resource limits
Environment variables
Rolling update strategy

================================================================================================================================================

kubernetes/service.yaml

Purpose

Creates the Kubernetes Service.

Resources Created

ClusterIP Service

Why this file exists

Provides a stable internal endpoint that allows other Kubernetes resources to communicate with the application Pods.

================================================================================================================================================

kubernetes/ingress.yaml

Purpose

Creates the Kubernetes Ingress.

Resources Created

AWS Application Load Balancer (through AWS Load Balancer Controller)

Why this file exists

Exposes the application to the Internet and routes incoming traffic to the Kubernetes Service.

================================================================================================================================================

Tools Used During the Pipeline
GitHub

Purpose

Stores the application source code.

Why this tool exists

Acts as the source code repository and triggers the Jenkins pipeline whenever new code is pushed.

================================================================================================================================================

Jenkins

Purpose

CI/CD automation server.

Why this tool exists

Automates the complete build, test, security scan, Docker build, image push, and deployment process.

================================================================================================================================================

Maven

Purpose

Build automation tool.

Why this tool exists

Compiles the Java application, resolves dependencies, and packages the application.

================================================================================================================================================

SonarQube

Purpose

Static code analysis.

Why this tool exists

Identifies code smells, bugs, vulnerabilities, and ensures the project meets quality standards.

================================================================================================================================================

OWASP Dependency Check

Purpose

Dependency vulnerability scanning.

Why this tool exists

Detects known vulnerabilities in third-party libraries used by the application.

================================================================================================================================================

Docker

Purpose

Containerizes the application.

Why this tool exists

Ensures the application runs consistently regardless of the deployment environment.

================================================================================================================================================

Trivy

Purpose

Container image vulnerability scanning.

Why this tool exists

Scans Docker images for operating system and package vulnerabilities before deployment.

================================================================================================================================================

Amazon Elastic Container Registry (ECR)

Purpose

Stores Docker images.

Why this tool exists

Acts as the central image repository from which Kubernetes pulls application images.

================================================================================================================================================

Amazon EKS

Purpose

Runs the containerized application.

Why this tool exists

Provides a managed Kubernetes platform for highly available container orchestration.

================================================================================================================================================

Pipeline Workflow

Developer Pushes Code

↓

GitHub Repository

↓

Jenkins Pipeline Starts

↓

Clone Repository

↓

Maven Build

↓

Unit Tests

↓

SonarQube Analysis

↓

Quality Gate

↓

OWASP Dependency Check

↓

Docker Build

↓

Trivy Image Scan

↓

Push Image to Amazon ECR

↓

Update Kubernetes Deployment

↓

Deploy to Amazon EKS

↓

Rolling Update of Application Pods

================================================================================================================================================

Resources Created

At the end of this phase, the following Kubernetes resources are created:

Namespace
ConfigMap
Secret
Deployment
ReplicaSet
Application Pods
ClusterIP Service
AWS Application Load Balancer
Kubernetes Ingress

================================================================================================================================================

Commands Executed
kubectl apply -f kubernetes/namespace.yaml

kubectl apply -f kubernetes/configmap.yaml

kubectl apply -f kubernetes/secret.yaml

kubectl apply -f kubernetes/deployment.yaml

kubectl apply -f kubernetes/service.yaml

kubectl apply -f kubernetes/ingress.yaml

Jenkins automatically executes the remaining build, scan, image push, and deployment steps through the Jenkins pipeline.

================================================================================================================================================

Verification

The CI/CD pipeline was verified by checking:

Jenkins pipeline completed successfully.
Maven build completed successfully.
SonarQube Quality Gate passed.
OWASP Dependency Check completed.
Docker image was built successfully.
Trivy vulnerability scan completed successfully.
Docker image was pushed to Amazon ECR.
Kubernetes Deployment was updated successfully.
Application Pods reached the Running state.
Kubernetes Service was created successfully.
AWS Application Load Balancer was provisioned automatically.
The application was accessible through the ALB Ingress URL.

================================================================================================================================================

Outcome

At the end of this phase:

A fully automated CI/CD pipeline was established.
Every code change could be built, tested, scanned, containerized, and deployed automatically.
The application was successfully deployed to Amazon EKS with zero manual deployment steps.
The deployment process became repeatable, secure, and production-ready.
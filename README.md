Multi-Cloud DevSecOps Platform

A multi-cloud DevSecOps project using one parameterized Jenkins pipeline to build, test, analyze, scan, containerize, and deploy a Spring Boot application to Amazon EKS or Google Kubernetes Engine (GKE).

The target cloud is selected using the Jenkins parameter:

CLOUD_PROVIDER = AWS

or:

CLOUD_PROVIDER = GCP

Monitoring note: The current application does not expose the Prometheus HTTP server request metric http_server_requests_seconds_count. Therefore, the custom Application Overview dashboard focuses on application workload CPU and memory usage rather than HTTP request rate or response time.

-------------------------------------------------------------

Project Highlights

• One parameterized Jenkins pipeline
• CLOUD_PROVIDER=AWS or CLOUD_PROVIDER=GCP
• Terraform-based AWS and GCP infrastructure
• Maven application build and testing
• Trivy FileSystem scanning
• OWASP Dependency-Check dependency vulnerability scanning
• SonarQube source-code analysis
• Docker container image creation
• Trivy container-image scanning
• Amazon ECR integration
• Google Artifact Registry integration
• Amazon EKS deployment
• GKE deployment
• Helm-based Kubernetes deployment
• Prometheus monitoring
• Grafana dashboards
• Cloud-specific deployment paths within a shared CI/CD pipeline

-------------------------------------------------------------

Technology Stack

Area                           Technology
Source Control	                Git,GitHub
CI/CD		         	          Jenkins
Build		         	          Maven
Application		                Java / Spring Boot
Containerization		          Docker
Infrastructure as Code		    Terraform
AWS		 	                   VPC, ECR, EKS, IAM, S3, AWS Load Balancer Controller
GCP		         	          VPC, GKE, Artifact Registry, IAM, Cloud NAT
Kubernetes		                Kubernetes
Deployment		                Helm
Code Quality		             SonarQube
Dependency Security		       OWASP Dependency-Check
Container Security		       Trivy
Monitoring		                Prometheus, Grafana

-------------------------------------------------------------

CI/CD Flow

The pipeline has common stages followed by a cloud-specific deployment path.

Shared stages
• Checkout
• Maven build
• Tests
• Trivy FileSystem Scan
• OWASP Dependency-Check
• SonarQube analysis
• Docker image build
• Trivy container-image scan

AWS path
• Authenticate with Amazon ECR
• Push image to ECR
• Configure EKS access
• Deploy with Helm
• Verify Kubernetes resources

Jenkins
   |
   v
Docker Build
   |
   v
Trivy Scan
   |
   v
Amazon ECR
   |
   v
Amazon EKS
   |
   v
Helm
   |
   v
Application

GCP path
• Authenticate with Google Cloud
• Push image to Artifact Registry
• Configure GKE access
• Deploy with Helm
• Verify Kubernetes resources

Jenkins
   |
   v
Docker Build
   |
   v
Trivy Scan
   |
   v
Artifact Registry
   |
   v
GKE
   |
   v
Helm
   |
   v
Application

-------------------------------------------------------------

Jenkins Parameter

The pipeline uses a single cloud-selection parameter:

parameters {

    choice(
        name: 'CLOUD_PROVIDER',
        choices: ['AWS', 'GCP'],
        description: 'Select the cloud provider to deploy to'
    )
}

This parameter determines which cloud-specific deployment path is executed.

The build and security stages remain common.

-------------------------------------------------------------

Infrastructure

AWS

Terraform provisions the AWS infrastructure required by the platform, including:

• VPC
• Public and private subnets
• Internet Gateway
• NAT Gateway
• Route tables
• Security groups
• Jenkins infrastructure
• Amazon ECR
• Amazon EKS
• Managed node group
• IAM/OIDC configuration
• EBS CSI support
• AWS Load Balancer Controller
• Supporting S3 resources

High-level deployment:

Terraform
   |
   +--> AWS Networking
   |
   +--> Jenkins
   |
   +--> ECR
   |
   +--> EKS
   |
   +--> IAM/OIDC
   |
   +--> Supporting AWS resources

GCP

Terraform provisions the GCP infrastructure required by the platform, including:

• VPC
• Jenkins VM
• GKE subnet
• GKE secondary IP ranges
• Zonal GKE cluster
• GKE node pool
• Artifact Registry
• Service accounts
• IAM
• Cloud NAT
• Supporting networking components

The current GKE deployment uses a zonal cluster in:

us-east1-d

-------------------------------------------------------------

Security

Security checks are performed before deployment:

Maven Build/Test
       |
       v
  Trivy FileSystem Scan
       |
       v
OWASP Dependency-Check
       |
       v
   SonarQube
       |
       v
   Docker Build
       |
       v
    Trivy
       |
       v
    Registry
       |
       v
 Kubernetes

OWASP Dependency-Check
Identifies known vulnerabilities in third-party application dependencies.

SonarQube
Provides source-code and static analysis.

Trivy
Scans the complete FileSystem and Docker container image for known vulnerabilities before it is pushed to the selected cloud registry.

Jenkins Credentials
Sensitive values such as SonarQube tokens and NVD API keys are stored in Jenkins Credentials rather than committed to source control.

IAM and RBAC
Cloud IAM and Kubernetes RBAC control access to cloud and Kubernetes resources.

-------------------------------------------------------------

Monitoring

The project uses:

• Prometheus
• Grafana
• kube-prometheus-stack
• Node Exporter
• Kubernetes metrics
• Custom Grafana dashboards

The monitoring stack is deployed in the:
monitoring namespace

Custom dashboards

Application Overview
Displays application workload resource usage, including:
Application pod CPU
Application pod memory

Kubernetes Cluster Overview
Displays Kubernetes cluster/node resource information, including:
Node CPU

Kubernetes Pods Overview
Displays pod/workload resource information, including:
Pod CPU
Node Exporter / Nodes

Provides node-level infrastructure metrics exposed by Node Exporter.

-------------------------------------------------------------

Verified Prometheus Metrics

The project uses metrics such as:
node_cpu_seconds_total
container_cpu_usage_seconds_total
container_memory_working_set_bytes

These metrics provide visibility into Kubernetes nodes, pods, and application workload resource usage.

-------------------------------------------------------------

Monitoring Limitation

The current application does not expose:
http_server_requests_seconds_count

Therefore, this project does not claim to provide:
HTTP request rate
HTTP response time
HTTP request duration
Endpoint-level HTTP performance monitoring

Instead, the Application Overview dashboard focuses on:
Application Pod CPU
Application Pod Memory

This keeps the monitoring documentation aligned with the metrics actually available from the current application.

-------------------------------------------------------------

Kubernetes Verification:
kubectl get nodes
kubectl get nodes -o wide
kubectl get pods -A
kubectl get namespaces
kubectl get svc -A
kubectl get ingress -A
kubectl get deployments -A

Application:
kubectl get pods -n application
kubectl get svc -n application
kubectl get ingress -n application

Monitoring:
kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl get pvc -n monitoring
kubectl get ingress -n monitoring

-------------------------------------------------------------

Helm Verification
helm list -A

Application:
helm list -n application
helm status <RELEASE_NAME> -n application

Monitoring:
helm list -n monitoring
helm status kube-prometheus-stack -n monitoring

-------------------------------------------------------------

GCP Notes

The GCP deployment uses a zonal GKE cluster.

Use:
gcloud container clusters get-credentials \
  multicloud-devsecops-gke \
  --zone us-east1-d \
  --project="$PROJECT_ID"

Do not replace --zone with --region unless the cluster is actually regional.

A restricted GCP sandbox may also prevent the active cloud user from modifying project IAM policies.

For example:
resourcemanager.projects.setIamPolicy
may be unavailable to the active sandbox identity.

In such cases, the required IAM permissions must be granted by an authorized sandbox administrator.

A Kubernetes RBAC binding does not necessarily grant missing Google Cloud IAM permissions.

-------------------------------------------------------------

Required GCP APIs

The current infrastructure requires APIs including:

gcloud services enable \
  compute.googleapis.com \
  container.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  cloudresourcemanager.googleapis.com \
  serviceusage.googleapis.com \
  storage.googleapis.com \
  artifactregistry.googleapis.com \
  servicenetworking.googleapis.com

-------------------------------------------------------------

Troubleshooting

Jenkins cannot access Docker:
groups jenkins
sudo -u jenkins docker ps
sudo systemctl status docker --no-pager

If necessary:
sudo usermod -aG docker jenkins
Restart Jenkins after changing the group membership.

Wrong Kubernetes context:
kubectl config current-context
kubectl config view --minify
kubectl get nodes

GKE container.nodes.list error
Verify:
• Jenkins identity
• Google Cloud IAM roles
• required GKE permissions
• Kubernetes RBAC configuration

A Kubernetes ClusterRoleBinding alone may not fix a GKE IAM authorization error.

Artifact Registry upload denied
Verify that the Jenkins service account has the appropriate Artifact Registry Writer permission.

AWS EKS AccessDenied
Verify that the IAM role used by Jenkins has the required EKS permissions.

Use the narrowest practical permissions rather than broad administrative permissions.

-------------------------------------------------------------

Security and Secrets

The following must not be committed to GitHub:

• SonarQube tokens
• NVD API keys
• Cloud credentials
• Private keys
• Passwords
• Service-account private key files
• Other authentication secrets

Use Jenkins Credentials, cloud IAM, workload identities, or appropriate managed secret stores instead.

Before pushing the repository, verify that no secrets are present in:

Jenkinsfile
Terraform files
YAML files
Helm values
README.md
documentation
shell scripts

-------------------------------------------------------------

Final Validation Checklist

Infrastructure:
• AWS Terraform infrastructure provisioned
• GCP Terraform infrastructure provisioned
• Jenkins available
• ECR available
• Artifact Registry available
• EKS available
• GKE available

Jenkins:
• Jenkins running
• Docker accessible by Jenkins
• Maven available
• Kubectl available
• Helm available
• Trivy available
• SonarQube configured
• Dependency-Check configured
• Required credentials configured

CI/CD:
• Checkout succeeds
• Maven build succeeds
• Tests succeed
• Trivy FileSystem Scan
• OWASP Dependency-Check succeeds
• SonarQube analysis succeeds
• Docker image builds
• Trivy scan executes

AWS:
• Image pushed to ECR
• EKS credentials configured
• Application deployed to EKS
• Application pods Ready
• Application Service available
• Application Ingress available

GCP:
• Image pushed to Artifact Registry
• GKE credentials configured
• Application deployed to GKE
• Application pods Ready
• Application Service available
• Application Ingress available

Monitoring:
• Prometheus Ready
• Grafana Ready
• Monitoring services available
• Monitoring ingress available
• Application dashboard available
• Kubernetes cluster dashboard available
• Kubernetes pods dashboard available
• Node-level metrics available

Helm:
• Application Helm release healthy
• Monitoring Helm release healthy

-------------------------------------------------------------

Production Recommendations

For production environments:
• Use least-privilege IAM.
• Use least-privilege Kubernetes RBAC.
• Use separate service identities for each environment.
• Rotate credentials and tokens.
• Store secrets in managed secret-management systems.
• Avoid cluster-admin access for Jenkins.
• Prefer repository-level Artifact Registry permissions.
• Keep cloud-specific project IDs out of reusable documentation.
• Pin important Terraform provider versions.
• Pin important Helm chart versions.
• Define resource requests and limits.
• Configure monitoring retention.
• Implement backup and recovery policies.
• Use separate environments for development, staging, and production.
• Protect production credentials and deployment branches.

-------------------------------------------------------------

Conclusion

The Multi-Cloud DevSecOps Platform demonstrates an end-to-end DevSecOps workflow using a single parameterized Jenkins pipeline.

The same pipeline can deploy the application to either:

AWS → ECR → EKS → Helm

or:

GCP → Artifact Registry → GKE → Helm

while sharing the common:

Git
 ↓
Jenkins
 ↓
Maven
 ↓
Trivy FileSystem Scan
 ↓
OWASP Dependency-Check
 ↓
SonarQube
 ↓
Docker
 ↓
Trivy
 ↓
Cloud Registry
 ↓
Kubernetes
 ↓
Helm
 ↓
Prometheus / Grafana

The project demonstrates Infrastructure as Code, CI/CD automation, containerization, Kubernetes deployment, security scanning, cloud-specific deployment, and observability across AWS and Google Cloud.

The monitoring documentation intentionally reflects the metrics exposed by the current application and does not claim HTTP request-rate or response-time monitoring that is not currently available.
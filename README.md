# Multi-Cloud DevSecOps Platform

A multi-cloud DevSecOps project using one parameterized Jenkins pipeline
to build, test, scan, containerize, and deploy a Spring Boot application
to **AWS EKS** or **GKE**.

> **Monitoring note:** The current application does not expose
> `http_server_requests_seconds_count`, so the custom Application
> Overview dashboard reports **application workload CPU and memory
> usage** rather than HTTP request rate or response time.

## Architecture

``` text
GitHub
   |
   v
Jenkins
   |
   +--> Build/Test --> SonarQube --> OWASP Dependency-Check --> Trivy --> Docker
   |
   +---------------------------- AWS ---------------------------+
   |                                                            |
   |                                                           ECR
   |                                                            |
   |                                                           EKS
   |                                                            |
   |                                                           Helm
   |                                                            |
   +---------------------------- GCP ---------------------------+
                                                                |
                                                          Artifact Registry
                                                                |
                                                               GKE
                                                                |
                                                               Helm

                         Kubernetes
                             |
                        Prometheus
                             |
                          Grafana
```

## Project Highlights

-   One Jenkins pipeline controlled by `CLOUD_PROVIDER=AWS` or `GCP`
-   Terraform-based AWS and GCP infrastructure
-   Maven build and tests
-   SonarQube code-quality analysis
-   OWASP Dependency-Check dependency scanning
-   Trivy container-image scanning
-   Docker image build
-   AWS ECR and GCP Artifact Registry
-   AWS EKS and GKE deployment
-   Helm-based Kubernetes deployment
-   Prometheus and Grafana monitoring

## Technology Stack

  Area                  Technology
  --------------------- ---------------------------------------------
  Source Control        Git, GitHub
  CI/CD                 Jenkins
  Build                 Maven
  Application           Java / Spring Boot
  Containerization      Docker
  IaC                   Terraform
  AWS                   VPC, ECR, EKS, IAM, S3, ALB Controller
  GCP                   VPC, GKE, Artifact Registry, IAM, Cloud NAT
  Kubernetes            Kubernetes
  Deployment            Helm
  Code Quality          SonarQube
  Dependency Security   OWASP Dependency-Check
  Container Security    Trivy
  Monitoring            Prometheus, Grafana

## Repository Structure

``` text
multicloud-devsecops-platform/
├── application/
├── helm/
│   └── multicloud-devsecops/
├── kubernetes/
├── monitoring/
│   ├── namespace.yaml
│   └── grafana/
│       ├── dashboard-configmap.yaml
│       └── dashboards/
│           ├── application.json
│           ├── kubernetes-cluster.json
│           ├── kubernetes-pods.json
│           └── node-exporter.json
├── sonarqube/
├── terraform/
│   ├── aws/
│   └── gcp/
├── docs/
│   ├── screenshots/
│   ├── PROJECT-INTERVIEW-GUIDE.md
│   └── SCREENSHOT-GUIDE.md
├── Jenkinsfile
└── README.md
```

## CI/CD Flow

### Shared stages

1.  Checkout
2.  Maven build
3.  Tests
4.  SonarQube
5.  OWASP Dependency-Check
6.  Trivy
7.  Docker build

### AWS path

1.  Push image to ECR
2.  Configure EKS
3.  Deploy with Helm
4.  Verify Kubernetes resources

### GCP path

1.  Push image to Artifact Registry
2.  Configure GKE
3.  Deploy with Helm
4.  Verify Kubernetes resources

## Infrastructure

### AWS

Terraform provisions the VPC/networking, public/private subnets,
Internet Gateway, NAT Gateway, route tables, security groups, Jenkins
infrastructure, ECR, EKS, managed node group, IAM/OIDC, EBS CSI support,
AWS Load Balancer Controller and supporting S3 resources.

### GCP

Terraform provisions the VPC, Jenkins and GKE subnets, GKE secondary
ranges, zonal GKE cluster/node pool, Jenkins VM/load-balancing
components, Artifact Registry, service accounts/IAM and Cloud
NAT/networking.

## Security

The pipeline applies security checks before deployment:

``` text
Build/Test
   |
SonarQube
   |
OWASP Dependency-Check
   |
Trivy
   |
Docker Image
   |
Registry
   |
Kubernetes
```

SonarQube provides source-code analysis, Dependency-Check identifies
vulnerable dependencies, and Trivy scans the container image.

## Monitoring

Custom dashboards:

-   **Application Overview** --- application pod CPU and memory
-   **Kubernetes Cluster Overview** --- node CPU
-   **Kubernetes Pods Overview** --- pod CPU
-   **Node Exporter / Nodes** --- node-level infrastructure metrics

Verified metrics:

``` promql
node_cpu_seconds_total
container_cpu_usage_seconds_total
container_memory_working_set_bytes
```

The application does not currently expose:

``` promql
http_server_requests_seconds_count
```

Therefore the project does not claim HTTP request-rate or response-time
monitoring.

## Interview Explanation

### 30 seconds

> I built a multi-cloud DevSecOps platform using Terraform, Jenkins,
> Docker, Kubernetes and Helm. A single parameterized Jenkins pipeline
> can deploy a Spring Boot application to either AWS EKS or GKE. The
> pipeline performs Maven build and testing, SonarQube analysis, OWASP
> Dependency-Check, Trivy scanning and Docker image creation, then
> pushes the image to ECR or Artifact Registry and deploys it with Helm.
> Prometheus and Grafana provide Kubernetes and application workload
> monitoring.

### 2 minutes

> The goal was to create one reusable CI/CD workflow instead of
> maintaining separate pipelines for AWS and GCP. Terraform provisions
> the cloud infrastructure. Jenkins uses a `CLOUD_PROVIDER` parameter to
> select AWS or GCP. The common stages handle checkout, Maven
> build/test, SonarQube, Dependency-Check, Trivy and Docker. The AWS
> path pushes to ECR and deploys to EKS, while the GCP path pushes to
> Artifact Registry and deploys to GKE. Helm keeps the Kubernetes
> deployment reusable with cloud-specific values. Prometheus and Grafana
> provide monitoring. The Application Overview dashboard intentionally
> monitors application workload CPU and memory because the current
> application does not expose the `http_server_requests_*` metrics
> needed for HTTP traffic panels.

## Honest Interview Positioning

Say:

> Application workload resource monitoring --- CPU and memory
> consumption of application pods.

Do **not** say:

> We monitor HTTP request rate and response time.

Also avoid claiming zero vulnerabilities, full production readiness, or
high availability unless the implemented architecture actually proves
it.

## Evidence

Screenshots are stored under:

``` text
docs/screenshots/
```

The recommended evidence set is:

1.  `01-architecture.png`
2.  `02-github-repository.png`
3.  `03-jenkins-pipeline-aws.png`
4.  `04-jenkins-pipeline-gcp.png`
5.  `05-security-scanning.png`
6.  `06-aws-ecr.png`
7.  `07-eks-cluster.png`
8.  `08-gcp-artifact-registry.png`
9.  `09-gke-cluster.png`
10. `10-application.png`
11. `11-grafana-application.png`
12. `12-grafana-kubernetes.png`

Only the strongest 5--6 should normally be embedded in this README.

## Interview Preparation

See [`docs/PROJECT-INTERVIEW-GUIDE.md`](docs/PROJECT-INTERVIEW-GUIDE.md)
for project explanation, tool-by-tool questions, troubleshooting
scenarios, security questions, monitoring questions, and resume-ready
wording.

See [`docs/SCREENSHOT-GUIDE.md`](docs/SCREENSHOT-GUIDE.md) for exactly
what each screenshot should prove and how to organize them.

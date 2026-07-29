#!/bin/bash

# ============================================================
# Jenkins EC2 User Data
# Installs:
# Java 21
# Git
# Docker
# AWS CLI v2
# Jenkins
# kubectl
# Helm
# Trivy
# ============================================================

set -e

# Send all output to cloud-init logs
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# Non-interactive package installation
export DEBIAN_FRONTEND=noninteractive

echo "============================================================"
echo "Starting Jenkins EC2 Bootstrap"
echo "============================================================"


# ============================================================
# 1. System Update & Base Packages
# ============================================================

echo "Installing base packages..."

apt-get update -y

apt-get install -y \
    fontconfig \
    openjdk-21-jre \
    git \
    ca-certificates \
    curl \
    unzip \
    wget \
    gnupg \
    software-properties-common \
    apt-transport-https \
    lsb-release

echo "Base packages installed successfully."


# ============================================================
# 2. Verify Java
# ============================================================

echo "Checking Java..."

java -version


# ============================================================
# 3. Install Docker
# ============================================================

echo "Installing Docker..."

# Create Docker keyring directory
install -m 0755 -d /etc/apt/keyrings

# Download Docker GPG key
curl -fsSL \
    https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Update package index
apt-get update -y

# Install Docker
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker

echo "Docker installed successfully."

docker --version


# ============================================================
# 4. Install AWS CLI v2
# ============================================================

echo "Installing AWS CLI v2..."

curl -fsSL \
    "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o "/tmp/awscliv2.zip"

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install

# Cleanup
rm -rf /tmp/aws
rm -f /tmp/awscliv2.zip

echo "AWS CLI installed successfully."

aws --version


# ============================================================
# 5. Install Jenkins
# ============================================================

echo "Installing Jenkins..."

# Create keyring directory
install -m 0755 -d /etc/apt/keyrings

# Download Jenkins GPG key
wget -O \
    /etc/apt/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

# Add Jenkins repository
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update repository
apt-get update -y

# Install Jenkins
apt-get install -y jenkins

# Add Jenkins user to Docker group
usermod -aG docker jenkins

# Enable Jenkins
systemctl enable jenkins

# Start Jenkins
systemctl start jenkins

echo "Jenkins installed successfully."

systemctl is-active jenkins


# ============================================================
# 6. Install kubectl
# ============================================================

echo "Installing kubectl..."

# Get latest stable Kubernetes version
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

echo "Installing kubectl version: ${KUBECTL_VERSION}"

# Download kubectl
curl -LO \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

# Download kubectl checksum
curl -LO \
    "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

# Verify checksum
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Cleanup
rm -f kubectl
rm -f kubectl.sha256

echo "kubectl installed successfully."

kubectl version --client


# ============================================================
# 7. Install Helm
# ============================================================

echo "Installing Helm..."

# Download official Helm installation script
curl -fsSL \
    https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    -o /tmp/get_helm.sh

chmod 700 /tmp/get_helm.sh

# Install Helm
/tmp/get_helm.sh

# Cleanup
rm -f /tmp/get_helm.sh

echo "Helm installed successfully."

helm version --short


# ============================================================
# 8. Install Trivy
# ============================================================

echo "Installing Trivy..."

# Download latest Trivy release version
TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest \
    | grep '"tag_name":' \
    | cut -d '"' -f 4 \
    | sed 's/^v//')

echo "Installing Trivy version: ${TRIVY_VERSION}"

# Download Trivy
curl -L \
    "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
    -o /tmp/trivy.tar.gz

# Create temporary directory
mkdir -p /tmp/trivy

# Extract
tar -xzf /tmp/trivy.tar.gz -C /tmp/trivy

# Install binary
install -m 0755 \
    /tmp/trivy/trivy \
    /usr/local/bin/trivy

# Cleanup
rm -rf /tmp/trivy
rm -f /tmp/trivy.tar.gz

echo "Trivy installed successfully."

trivy --version


# ============================================================
# 9. Refresh Jenkins Docker Group
# ============================================================

echo "Refreshing Jenkins Docker permissions..."

# Restart Jenkins so the service picks up Docker group membership
systemctl restart jenkins

sleep 10


# ============================================================
# 10. Final Verification
# ============================================================

echo ""
echo "============================================================"
echo "VERIFICATION SUMMARY"
echo "============================================================"

echo ""
echo "Java:"
java -version 2>&1

echo ""
echo "Git:"
git --version

echo ""
echo "Docker:"
docker --version

echo ""
echo "Docker Service:"
systemctl is-active docker

echo ""
echo "AWS CLI:"
aws --version

echo ""
echo "kubectl:"
kubectl version --client

echo ""
echo "Helm:"
helm version --short

echo ""
echo "Trivy:"
trivy --version

echo ""
echo "Jenkins Service:"
systemctl is-active jenkins

echo ""
echo "Port 8080:"
ss -lntp | grep 8080 || echo "Port 8080 is not binding yet."

echo ""
echo "Jenkins Initial Admin Password:"
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "Password file not available yet."
fi

echo ""
echo "============================================================"
echo "Jenkins EC2 Bootstrap Completed"
echo "============================================================"
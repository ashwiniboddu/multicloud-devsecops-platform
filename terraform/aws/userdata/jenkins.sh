#!/bin/sh

# ============================================================
# Jenkins EC2 User Data (POSIX sh compatible)
# ============================================================

set -e

echo "Waiting for apt/dpkg locks to release..."
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
    sleep 2
done

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
    openjdk-21-jdk \
    git \
    maven \
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
mvn --version

# ============================================================
# 3. Install Docker
# ============================================================
echo "Installing Docker..."

install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Use standard variable substitution for sh compatibility
UBUNTU_CODENAME=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
ARCH=$(dpkg --print-architecture)

cat <<EOF > /etc/apt/sources.list.d/docker.sources
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update -y

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable docker
systemctl start docker

echo "Docker installed successfully."
docker --version

# ============================================================
# 4. Install AWS CLI v2
# ============================================================
echo "Installing AWS CLI v2..."

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

rm -rf /tmp/aws
rm -f /tmp/awscliv2.zip

echo "AWS CLI installed successfully."
aws --version

# ============================================================
# 5. Install Jenkins
# ============================================================
echo "Installing Jenkins..."

install -m 0755 -d /etc/apt/keyrings

wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
    > /etc/apt/sources.list.d/jenkins.list

apt-get update -y
apt-get install -y jenkins

usermod -aG docker jenkins

systemctl enable jenkins
systemctl start jenkins

echo "Jenkins installed successfully."
systemctl is-active jenkins

# ============================================================
# 6. Install kubectl
# ============================================================
echo "Installing kubectl..."

KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
echo "Installing kubectl version: ${KUBECTL_VERSION}"

curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check --status || {
    echo "kubectl checksum verification failed!"
    exit 1
}

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm -f kubectl kubectl.sha256

echo "kubectl installed successfully."
kubectl version --client

# ============================================================
# 7. Install Helm
# ============================================================
echo "Installing Helm..."

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o /tmp/get_helm.sh
chmod 700 /tmp/get_helm.sh
/tmp/get_helm.sh
rm -f /tmp/get_helm.sh

echo "Helm installed successfully."
helm version --short

# ============================================================
# 8. Install Trivy
# ============================================================
echo "Installing Trivy..."

TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest \
    | grep '"tag_name":' \
    | cut -d '"' -f 4 \
    | sed 's/^v//')

echo "Installing Trivy version: ${TRIVY_VERSION}"

curl -L "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz" \
    -o /tmp/trivy.tar.gz

mkdir -p /tmp/trivy
tar -xzf /tmp/trivy.tar.gz -C /tmp/trivy

install -m 0755 /tmp/trivy/trivy /usr/local/bin/trivy

rm -rf /tmp/trivy
rm -f /tmp/trivy.tar.gz

echo "Trivy installed successfully."
trivy --version

# ============================================================
# 9. Install Sonar Scanner
# ============================================================
echo "Installing Sonar Scanner..."

cd /opt
rm -f sonar-scanner.zip
wget -O sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-8.1.0.6389-linux-x64.zip
unzip -o sonar-scanner.zip

rm -rf /opt/sonar-scanner
mv sonar-scanner-8.1.0.6389-linux-x64 /opt/sonar-scanner
rm -f sonar-scanner.zip

chmod +x /opt/sonar-scanner/bin/sonar-scanner
ln -sf /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

echo "Sonar Scanner installed successfully."
sonar-scanner --version

# ============================================================
# 10. Refresh Jenkins Docker Group
# ============================================================
echo "Refreshing Jenkins Docker permissions..."
systemctl restart jenkins
sleep 10

# ============================================================
# 11. Final Verification
# ============================================================
echo ""
echo "============================================================"
echo "VERIFICATION SUMMARY"
echo "============================================================"

echo "Java:" && java -version 2>&1
echo "Git:" && git --version
echo "Docker:" && docker --version
echo "Docker Service:" && systemctl is-active docker
echo "AWS CLI:" && aws --version
echo "kubectl:" && kubectl version --client
echo "Helm:" && helm version --short
echo "Trivy:" && trivy --version
echo "Sonar Scanner:" && sonar-scanner --version
echo "Jenkins Service:" && systemctl is-active jenkins

echo ""
echo "Jenkins Initial Admin Password:"
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "Password file not available yet."
fi

echo "============================================================"
echo "Jenkins EC2 Bootstrap Completed"
echo "============================================================"
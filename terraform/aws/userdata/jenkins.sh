#!/bin/bash
# Send all output to cloud-init logs for easy debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Set frontend to non-interactive to block popup configurations
export DEBIAN_FRONTEND=noninteractive

#==================================================================================
# System Update & Base Utilities
#==================================================================================
apt-get update -y
apt-get install -y fontconfig openjdk-21-jre git ca-certificates curl unzip

# Verify Java installation
java -version

#==================================================================================
# Installation of Docker
#==================================================================================
# Setup Docker repository keyring safely
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker Apt repository entry
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

# Install Docker packages
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Configure Docker daemon
systemctl enable docker
systemctl start docker

#==================================================================================
# Installation of AWS CLI
#==================================================================================
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

#==================================================================================
# Installation of Jenkins
#==================================================================================
# Fetch and save the Jenkins repository key
wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

# Register Jenkins repository list entry
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Final update and Jenkins setup
apt-get update -y
apt-get install -y jenkins

# Permission adjustment for the Jenkins daemon
usermod -aG docker jenkins

# Boot the Jenkins engine
systemctl enable jenkins
systemctl start jenkins

#==================================================================================
# Final Summary Output (Logged to /var/log/user-data.log)
#==================================================================================
echo "=== VERIFICATION SUMMARY ==="
echo "Java version:"    && java -version 2>&1
echo "Git version:"     && git --version
echo "Docker version:"  && docker --version
echo "AWS CLI version:" && aws --version
echo "Jenkins Status:"  && systemctl is-active jenkins
echo "Active Port 8080 bindings:" && ss -lntp | grep 8080 || echo "Port 8080 not binding yet."

#!/bin/bash
set -e

cd /opt

# 1. Download and extract cleanly
sudo rm -f sonar-scanner.zip
sudo wget -O sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-8.1.0.6389-linux-x64.zip
sudo apt-get install -y unzip
sudo unzip -o sonar-scanner.zip

# 2. Safely remove old directory and move the newly extracted folder to /opt/sonar-scanner
sudo rm -rf /opt/sonar-scanner
sudo mv sonar-scanner-8.1.0.6389-linux-x64 /opt/sonar-scanner
sudo rm -f sonar-scanner.zip

# 3. Grant execute permissions to the binary
sudo chmod +x /opt/sonar-scanner/bin/sonar-scanner

# 4. Create a global symbolic link
sudo ln -sf /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# 5. Verify installation
sonar-scanner --version
#!/bin/bash
set -e

# Redirect logs
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting API deployment script..."

# Update system
yum update -y
yum install -y jq

# Create app directory
APP_DIR="/var/app/omikuji-api"
mkdir -p "$APP_DIR"
chown ec2-user:ec2-user "$APP_DIR"

# Download artifact (Getting latest release)
# IMPORTANT: This assumes a public repo or valid GITHUB_TOKEN environment variable/parameter
REPO="mizhm/omikuji"
echo "Downloading backend artifact..."

# Try to get latest release URL using GitHub API
LATEST_RELEASE_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.assets[] | select(.name == "backend-artifact.tar.gz") | .browser_download_url')

if [ -z "$LATEST_RELEASE_URL" ] || [ "$LATEST_RELEASE_URL" == "null" ]; then
    echo "Could not find artifact URL via API. URL: $LATEST_RELEASE_URL"
    exit 1
fi

echo "Artifact URL: $LATEST_RELEASE_URL"

# Download as ec2-user
su - ec2-user -c "curl -L -o $APP_DIR/backend-artifact.tar.gz '$LATEST_RELEASE_URL'"

# Setup application
cd "$APP_DIR"
su - ec2-user -c "cd $APP_DIR && tar -xzvf backend-artifact.tar.gz"
# Ensure the binary is executable
su - ec2-user -c "chmod +x $APP_DIR/server"

# Create systemd service
cat <<EOF > /etc/systemd/system/omikuji-api.service
[Unit]
Description=Omikuji API
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/server
Restart=always
Environment=PORT=8080
# Add other env vars here (e.g., DB_DSN)

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable --now omikuji-api

echo "API Deployment finished successfully."

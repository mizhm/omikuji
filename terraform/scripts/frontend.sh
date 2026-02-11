#!/bin/bash
set -e

# Redirect logs
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting deployment script..."

# Update system
yum update -y
yum install -y unzip jq

# Install Bun
export BUN_INSTALL="/home/ec2-user/.bun"
curl -fsSL https://bun.sh/install | bash
export PATH="$BUN_INSTALL/bin:$PATH"

# Ensure ec2-user owns bun directory
chown -R ec2-user:ec2-user /home/ec2-user/.bun

# Create app directory
APP_DIR="/var/www/omikuji-ui"
mkdir -p "$APP_DIR"
chown ec2-user:ec2-user "$APP_DIR"

# Download artifact (Getting latest release)
# IMPORTANT: This assumes a public repo or valid GITHUB_TOKEN environment variable/parameter
# If repo is private, GITHUB_TOKEN must be provided.
REPO="mizhm/omikuji"
# Fallback to manual download if API fails or token missing for private repos
echo "Downloading artifact..."

# Try to get latest release URL using GitHub API (needs public access or token)
# If this fails, you might need to hardcode a version or provide a token.
# For now, using a direct download link pattern which often works if public.
# Or better, let's use the API to find the asset URL.
LATEST_RELEASE_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.assets[] | select(.name == "frontend-artifact.tar.gz") | .browser_download_url')

if [ -z "$LATEST_RELEASE_URL" ] || [ "$LATEST_RELEASE_URL" == "null" ]; then
    echo "Could not find artifact URL via API. URL: $LATEST_RELEASE_URL"
    # Fallback or exit? Let's try a hard reset to a known pattern or exit.
    # echo "Attempting fallback..."
    exit 1
fi

echo "Artifact URL: $LATEST_RELEASE_URL"

# Download as ec2-user
su - ec2-user -c "curl -L -o $APP_DIR/frontend-artifact.tar.gz '$LATEST_RELEASE_URL'"

# Setup application
cd "$APP_DIR"
su - ec2-user -c "cd $APP_DIR && tar -xzvf frontend-artifact.tar.gz"

# Install dependencies strictly (using bun)
# We need to make sure we use the bun we just installed
su - ec2-user -c "export PATH=$BUN_INSTALL/bin:\$PATH && cd $APP_DIR && bun install --production"

# Create systemd service
cat <<EOF > /etc/systemd/system/omikuji-ui.service
[Unit]
Description=Omikuji UI
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=$APP_DIR
ExecStart=$BUN_INSTALL/bin/bun start
Restart=always
Environment=NODE_ENV=production
Environment=INTERNAL_API_URL=${api_url}

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable --now omikuji-ui

echo "Deployment finished successfully."
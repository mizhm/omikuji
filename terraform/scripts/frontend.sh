#!/bin/bash
set -e

# Redirect logs
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting deployment script for Standalone mode..."

# Update system
yum update -y
yum install -y unzip jq nodejs # Cài Node.js thay vì Bun (hoặc giữ cả hai tùy ý)

# Create app directory
APP_DIR="/var/www/omikuji-ui"
mkdir -p "$APP_DIR"
chown ec2-user:ec2-user "$APP_DIR"

# Download artifact
REPO="mizhm/omikuji"
LATEST_RELEASE_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | jq -r '.assets[] | select(.name == "frontend-artifact.tar.gz") | .browser_download_url')

if [ -z "$LATEST_RELEASE_URL" ] || [ "$LATEST_RELEASE_URL" == "null" ]; then
    echo "Could not find artifact URL."
    exit 1
fi

# Download và giải nén trực tiếp vào APP_DIR
su - ec2-user -c "curl -L -o /tmp/frontend-artifact.tar.gz '$LATEST_RELEASE_URL'"
su - ec2-user -c "tar -xzvf /tmp/frontend-artifact.tar.gz -C $APP_DIR"

# Create systemd service
cat <<EOF > /etc/systemd/system/omikuji-ui.service
[Unit]
Description=Omikuji UI (Standalone Mode)
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=$APP_DIR
# Dùng node để chạy file server.js đã được build sẵn
ExecStart=/usr/bin/node server.js
Restart=always
Environment=NODE_ENV=production
Environment=PORT=3000
Environment=INTERNAL_API_URL=${api_url}
# Nếu app cần tìm node_modules cục bộ trong standalone
Environment=NODE_PATH=$APP_DIR/node_modules

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
systemctl daemon-reload
systemctl enable --now omikuji-ui

echo "Deployment finished successfully."
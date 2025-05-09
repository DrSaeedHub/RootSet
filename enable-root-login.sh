#!/bin/bash


# ASCII Art Header
echo -e "\033[0;32m"
echo "  _____          _____                     _ "
echo " |  __ \        / ____|                   | |"
echo " | |  | |_ __  | (___   __ _  ___  ___  __| |"
echo " | |  | | '__|  \___ \ / _ |/ _ \/ _ \/ _ |"
echo " | |__| | |     ____) | (_| |  __/  __/ (_| |"
echo " |_____/|_|    |_____/ \__,_|\___|\___|\__,_|"
echo -e "\033[0m"

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use: sudo bash enable-root-login.sh"
  exit 1
fi

# Prompt the user for a root password
echo "Enter the new root password:"
read -s ROOT_PASSWORD
echo "Confirm the root password:"
read -s ROOT_PASSWORD_CONFIRM

# Check if passwords match
if [ "$ROOT_PASSWORD" != "$ROOT_PASSWORD_CONFIRM" ]; then
  echo "Passwords do not match. Exiting."
  exit 1
fi

# Update SSH configuration to permit root login with password
echo "Configuring SSH to allow root login with password..."
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Handle cloud-init SSH configuration file if present
CLOUD_SSH_CONFIG="/etc/ssh/sshd_config.d/60-cloudimg-settings.conf"
if [ -f "$CLOUD_SSH_CONFIG" ]; then
  sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' "$CLOUD_SSH_CONFIG"
fi

# Restart SSH service
echo "Restarting SSH service..."
if systemctl restart sshd; then
  echo "SSH service restarted successfully."
else
  echo "Failed to restart SSH service. Exiting."
  exit 1
fi

# Set the root password
echo "Setting the root password..."
echo "root:$ROOT_PASSWORD" | chpasswd

echo "Root login with password is enabled."
echo "You can now connect as root using with the password you set."

exit 0

#!/bin/bash
set -euo pipefail

# ASCII Art Header
echo -e "\033[0;32m"
cat <<'EOF'
  _____          _____                     _ 
 |  __ \        / ____|                   | |
 | |  | |_ __  | (___   __ _  ___  ___  __| |
 | |  | | '__|  \___ \ / _` |/ _ \/ _ \/ _` |
 | |__| | |     ____) | (_| |  __/  __/ (_| |
 |_____/|_|    |_____/ \__,_|\___|\___|\__,_|
EOF
echo -e "\033[0m"

# Ensure the script is run as root
if (( EUID != 0 )); then
  echo "This script must be run as root."
  echo "Usage: sudo bash $0"
  exit 1
fi

# Prompt for new root password
read -rsp "Enter the new root password: " ROOT_PASSWORD
echo
read -rsp "Confirm the root password: " ROOT_PASSWORD_CONFIRM
echo
if [[ "$ROOT_PASSWORD" != "$ROOT_PASSWORD_CONFIRM" ]]; then
  echo "Error: passwords do not match."
  exit 1
fi

# Function to update or add a config directive
update_config() {
  local file="$1" directive="$2" value="$3"
  if grep -qE "^\s*#?\s*${directive}\b" "$file"; then
    sed -i -r "s|^\s*#?\s*(${directive}\b).*|\1 $value|" "$file"
  else
    echo -e "\n# Enabled by enable-root-login.sh\nt${directive} $value" >> "$file"
  fi
}

echo "Updating SSH configuration..."

# Main sshd_config
SSHD_MAIN="/etc/ssh/sshd_config"
update_config "$SSHD_MAIN" "PermitRootLogin" "yes"
update_config "$SSHD_MAIN" "PasswordAuthentication" "yes"

# Any conf.d snippets
for DIR in /etc/ssh/sshd_config.d /etc/ssh/ssh_config.d; do
  if [[ -d "$DIR" ]]; then
    for CFG in "$DIR"/*.conf; do
      [[ -e "$CFG" ]] || continue
      update_config "$CFG" "PermitRootLogin" "yes"
      update_config "$CFG" "PasswordAuthentication" "yes"
    done
  fi
done

# Cloud-init overrides (older & newer paths)
for CLOUD in \
  /etc/ssh/sshd_config.d/60-cloudimg-settings.conf \
  /etc/cloud/cloud.cfg.d/99_disable_root.cfg; do
  if [[ -f "$CLOUD" ]]; then
    update_config "$CLOUD" "PermitRootLogin" "yes"
    update_config "$CLOUD" "PasswordAuthentication" "yes"
  fi
done

# Restart SSH service (systemd or service)
echo "Restarting SSH service..."
if command -v systemctl &>/dev/null; then
  # Try common service names
  for SVC in sshd ssh; do
    if systemctl list-units --full -all | grep -qE "^${SVC}\.service"; then
      systemctl restart "${SVC}.service"
      echo "Restarted ${SVC}.service"
      break
    fi
  done
else
  # Fallback to service command
  service ssh restart || service sshd restart
  echo "Restarted SSH via service command"
fi

# Apply the new root password
echo "root:${ROOT_PASSWORD}" | chpasswd

echo "✅ Root login via SSH with password is now enabled."
echo "You can now ssh in as root with the password you set."

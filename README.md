
# RootLogin - Enable Root SSH Login with Password

A simple bash script to enable SSH root login with a password on Ubuntu servers. This script modifies SSH configuration and sets a root password, allowing secure root access via SSH.

---

## ✅ **Features:**
- Enables SSH root login with a password.
- Prompts user to set a custom root password.
- Automatically updates SSH configuration.
- Compatible with cloud-init SSH configuration (`60-cloudimg-settings.conf`).

---

## 🚀 **Usage**

1. **Connect to your server:**

Ensure you are connected to your server as a user with `sudo` privileges.

2. **Run the Script:**

Execute the script directly from the repository:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/DrSaeedHub/RootSet/main/enable-root-login.sh)
```

3. **Follow the Prompts:**

- Enter the new root password when prompted.
- Confirm the root password.
- The script will automatically restart the SSH service and apply the changes.

---

## 🔐 **Security Considerations**

- This script modifies the SSH configuration to allow root login with a password. 
- It is recommended to disable root login after performing necessary operations for better security:

```bash
nano /etc/ssh/sshd_config
```

Set the following values:

```
PermitRootLogin no
PasswordAuthentication no
```

Restart the SSH service:

```bash
sudo systemctl restart sshd
```

---

## 📦 **Files:**

- `enable-root-login.sh` - Main script to enable root login.

---

## ❓ **Troubleshooting**

- If you encounter `Permission denied (publickey)` after running the script, ensure that SSH service is properly restarted:

  ```bash
  sudo systemctl restart sshd
  ```

- Verify the SSH configuration:

  ```bash
  sudo sshd -t
  ```

---

## 🤝 **Contributing**

Feel free to fork the repository, make improvements, and submit a pull request. Contributions are welcome!

---

## 🛠️ **Author**

Created by [DrSaeedHub](https://github.com/DrSaeedHub).

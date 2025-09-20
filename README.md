# Aztec Sequencer 🚀 One-Click Installer & Manager

Welcome! This script is designed to make installing and managing an Aztec Sequencer node incredibly simple. With a single command, you can access a user-friendly menu to install, run, update, and uninstall your node.



---

## ✨ Features

* **One-Command Setup**: Get started with just a single line of code.
* **Menu-Driven**: Easy-to-use menu for Install, Run, Update, and Uninstall functions.
* **Fully Automated**: Automatically handles dependencies, Docker, and firewall configuration.
* **Background Process**: The node runs in a `screen` session, so it stays online even if you disconnect.
* **Beginner-Friendly**: Every step is explained in simple, clear language.

---

## 🛠️ Installation & Usage

### Step 1: Connect to Your Server

First, connect to your Linux (Ubuntu) server using SSH.

### Step 2: Run the One-Command Installer

Copy the entire command below, paste it into your server's terminal, and press **Enter**. This command will instantly download and run the script, launching the management menu.

```bash
curl -sL [https://raw.githubusercontent.com/hamad0786/aztec-installer/main/install.sh](https://raw.githubusercontent.com/hamad0786/aztec-installer/main/install.sh) | bash

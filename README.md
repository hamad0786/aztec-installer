# Aztec Sequencer 🚀 One-Click Installer & Manager

Welcome! Yeh script Aztec Sequencer node ko install aur manage karne ke process ko bohot aasan banane ke liye design ki gayi hai. Ek single command ke zariye, aap ek user-friendly menu access kar sakte hain jisse aap node ko install, run, update, aur uninstall kar sakte hain.



---

## ✨ Features

* **One-Command Setup**: Sirf ek line ki command se shuruaat karein.
* **Menu-Driven**: Install, Run, Update, Uninstall karne ke liye aasan menu.
* **Fully Automated**: Dependencies, Docker, aur firewall configuration sab kuch automatically ho jata hai.
* **Background Process**: Node `screen` session mein chalta hai, isliye aapke disconnect hone par bhi chalta rehta hai.
* **Beginner-Friendly**: Har step ko aasan zabaan mein samjhaya gaya hai.

---

## 🛠️ Installation & Usage

### Step 1: Apne Server se Connect Karein

Sab se pehle, apne Linux (Ubuntu) server par SSH ke zariye connect ho jaayein.

### Step 2: One-Command Installer Chalayein

Neeche di gayi poori command ko copy karein, apne server ke terminal mein paste karein, aur **Enter** dabayein. Yeh command sab kuch download karke tayyar kar degi aur aapke saamne management menu le aayegi.

```bash
wget -O install.sh [https://raw.githubusercontent.com/hamad0786/aztec-installer/main/install.sh](https://raw.githubusercontent.com/hamad0786/aztec-installer/main/install.sh) && chmod +x install.sh && sed -i 's/\r$//' install.sh && ./install.sh

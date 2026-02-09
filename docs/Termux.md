# 📱 Running on Android (Termux)

You can run this entire stack on your Android phone using **Termux**. This is perfect for using an old phone as a low-power home server or seedbox.

## 🚀 The "Zero-Config" Way

We've automated the setup to make it as easy as a VPS.

1. Install **Termux** from [F-Droid](https://f-droid.org/en/packages/com.termux/) (The Play Store version is outdated).
2. Open Termux and clone this repo.
3. Run the startup script:
   ```bash
   chmod +x scripts/termux-up.sh
   ./scripts/termux-up.sh
   ```

### What this script does:

- Installs all native dependencies (Node.js, etc.).
- Sets up **PM2** to manage processes in the background.
- Starts all your apps in `apps/` automatically (including core apps like qBittorrent and Filebrowser, but **only if their folders exist**).

---

## 🛠️ Management Commands

Since we don't use Docker on Android (requires root), we use **PM2** for process management:

| Action            | Command           |
| :---------------- | :---------------- |
| **Check Status**  | `pm2 list`        |
| **View Logs**     | `pm2 logs`        |
| **Stop Stack**    | `pm2 stop all`    |
| **Restart Stack** | `pm2 restart all` |

---

## ➕ Adding Apps (The "Termux Way")

Since we don't use Docker, adding apps is slightly different but still easy.

1.  **Create a folder** in `apps/` (e.g., `apps/myapp`).
2.  **Add your app code:**
    - **Node.js:** Add `package.json` (and `index.js`).
    - **Python:** Add `requirements.txt` (and `main.py` or `bot.py`).
3.  **Restart the stack:**
    ```bash
    pm2 delete all
    ./scripts/termux-up.sh
    ```
4.  **That's it!** The script auto-detects your new app and adds it to PM2.

> [!TIP]
> You can create a local `.env` file in your app folder (`apps/myapp/.env`) to override global settings.

---

## 🛠️ Utility Scripts

We've adapted the helper scripts to work natively on Termux:

| Script                    | Description                                    |
| :------------------------ | :--------------------------------------------- |
| `update` (alias)          | Runs `pkg update && pkg upgrade` safely.       |
| `scripts/cloud_backup.sh` | Backs up your `apps/` and DBs to Google Drive. |
| `scripts/run_once.sh`     | Targeted `update` alias creation.              |

To enable the `update` shortcut:

```bash
./scripts/run_once.sh
source ~/.bashrc
```

---

## 🔋 Battery & Background Performance

Android is aggressive about killing background apps. To keep your server alive:

1. **Acquire Wakelock:** Pull down notification shade -> Termux notification -> **Acquire Wakelock**.
2. **Battery Unrestricted:** Android Settings -> Apps -> Termux -> Battery -> **Unrestricted**.

---

## 🐳 Need "Real" Docker?

If you absolutely need Docker (e.g., for apps that don't have native Termux versions), you can run a Virtual Machine.
See [Docker-VM.md](./Docker-VM.md) for instructions.

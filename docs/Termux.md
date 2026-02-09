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

## 🔋 Battery & Background Performance

Android is aggressive about killing background apps. To keep your server alive:

1. **Acquire Wakelock:** Pull down notification shade -> Termux notification -> **Acquire Wakelock**.
2. **Battery Unrestricted:** Android Settings -> Apps -> Termux -> Battery -> **Unrestricted**.

---

## 🐳 Need "Real" Docker?

If you absolutely need Docker (e.g., for apps that don't have native Termux versions), you can run a Virtual Machine.
See [Docker-VM.md](./Docker-VM.md) for instructions.

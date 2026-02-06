const {
  default: makeWASocket,
  useMultiFileAuthState,
  DisconnectReason,
} = require("@whiskeysockets/baileys");
const pino = require("pino");
const qrcode = require("qrcode-terminal");

// ✅ YOUR GROUP ID (Set via ALLOWED_GROUP_ID environment variable)
const ALLOWED_GROUP_ID = process.env.ALLOWED_GROUP_ID;
if (!ALLOWED_GROUP_ID) {
  console.error("❌ ALLOWED_GROUP_ID environment variable is required");
  process.exit(1);
}

// Command help menu (DRY: single source of truth)
const HELP_MENU = `📜 *Commands:*
.ping - Check connection
.time - Check India time
.start - Check status
.help - Show this menu`;

// Helper to send messages with error handling
async function safeSend(sock, jid, content) {
  try {
    await sock.sendMessage(jid, content);
  } catch (err) {
    console.error(`❌ Failed to send message to ${jid}:`, err.message);
  }
}

async function connectToWhatsApp() {
  const { state, saveCreds } = await useMultiFileAuthState("auth_info_baileys");

  const sock = makeWASocket({
    logger: pino({ level: "silent" }),
    printQRInTerminal: false,
    auth: state,
    markOnlineOnConnect: false,
    syncFullHistory: false,
  });

  sock.ev.on("connection.update", async (update) => {
    const { connection, lastDisconnect, qr } = update;

    if (qr) {
      console.log("Scan this:");
      qrcode.generate(qr, { small: true });
    }

    if (connection === "close") {
      const shouldReconnect =
        lastDisconnect?.error?.output?.statusCode !==
        DisconnectReason.loggedOut;
      if (shouldReconnect) connectToWhatsApp();
    } else if (connection === "open") {
      console.log(`✅ System Online. Listening in: ${ALLOWED_GROUP_ID}`);
      // Send startup notification to group
      await safeSend(sock, ALLOWED_GROUP_ID, {
        text: "🤖 Bot is Active & Listening",
      });
      await safeSend(sock, ALLOWED_GROUP_ID, { text: HELP_MENU });
    }
  });

  sock.ev.on("creds.update", saveCreds);

  sock.ev.on("messages.upsert", async ({ messages }) => {
    const msg = messages[0];
    if (!msg.message || !msg.key.remoteJid) return;

    const remoteJid = msg.key.remoteJid;
    const text =
      msg.message.conversation || msg.message.extendedTextMessage?.text || "";

    // --- FILTER ---
    if (remoteJid !== ALLOWED_GROUP_ID) return;
    if (!text.startsWith(".")) return;

    const command = text.slice(1).trim().toLowerCase();
    if (!command) return; // Ignore lone "."
    console.log(`[CMD] ${command}`);

    switch (command) {
      case "ping":
        await safeSend(sock, remoteJid, { text: "Pong! 🏓" });
        break;

      case "start":
        await safeSend(sock, remoteJid, {
          text: "🤖 Bot is Active & Listening",
        });
        break;

      case "time":
        const now = new Date().toLocaleString("en-IN", {
          timeZone: "Asia/Kolkata",
        });
        await safeSend(sock, remoteJid, { text: `🕒 ${now}` });
        break;

      case "help":
        await safeSend(sock, remoteJid, { text: HELP_MENU });
        break;

      default:
        await safeSend(sock, remoteJid, {
          text: `❓ Unknown command: .${command}\nType .help for available commands.`,
        });
    }
  });
}

connectToWhatsApp();

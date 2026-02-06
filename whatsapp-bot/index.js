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
      const menu = `📜 *Commands:*\n.ping - Check connection\n.time - Check India time\n.start - Check status\n.help - Show this menu`;
      await sock.sendMessage(ALLOWED_GROUP_ID, {
        text: "🤖 Bot is Active & Listening",
      });
      await sock.sendMessage(ALLOWED_GROUP_ID, { text: menu });
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
    console.log(`[CMD] ${command}`);

    switch (command) {
      case "ping":
        await sock.sendMessage(remoteJid, { text: "Pong! 🏓" });
        break;

      case "start":
        await sock.sendMessage(remoteJid, {
          text: "🤖 Bot is Active & Listening",
        });
        break;

      case "time":
        const now = new Date().toLocaleString("en-IN", {
          timeZone: "Asia/Kolkata",
        });
        await sock.sendMessage(remoteJid, { text: `🕒 ${now}` });
        break;

      case "help":
        const menu = `📜 *Commands:*\n.ping - Check connection\n.time - Check India time\n.start - Check status\n.help - Show this menu`;
        await sock.sendMessage(remoteJid, { text: menu });
        break;
    }
  });
}

connectToWhatsApp();

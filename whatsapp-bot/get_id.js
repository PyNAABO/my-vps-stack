const {
  default: makeWASocket,
  useMultiFileAuthState,
} = require("@whiskeysockets/baileys");
const pino = require("pino");

const MAX_MESSAGES = 5;
const TIMEOUT_MS = 60000; // 60 seconds

async function connect() {
  let messageCount = 0;
  const { state, saveCreds } = await useMultiFileAuthState("auth_info_baileys");
  const sock = makeWASocket({
    logger: pino({ level: "silent" }),
    printQRInTerminal: true,
    auth: state,
  });

  // Auto-exit after timeout
  const timer = setTimeout(() => {
    console.log("\n⏱️ Timeout reached. Exiting...");
    process.exit(0);
  }, TIMEOUT_MS);

  sock.ev.on("creds.update", saveCreds);
  sock.ev.on("messages.upsert", ({ messages }) => {
    const msg = messages[0];
    if (!msg.message) return;
    messageCount++;
    console.log("------------------------------------------------");
    console.log("💬 GROUP ID:", msg.key.remoteJid);
    console.log(`   (${messageCount}/${MAX_MESSAGES} messages captured)`);
    console.log("------------------------------------------------");

    if (messageCount >= MAX_MESSAGES) {
      console.log("\n✅ Captured enough messages. Exiting...");
      clearTimeout(timer);
      process.exit(0);
    }
  });
}
connect();

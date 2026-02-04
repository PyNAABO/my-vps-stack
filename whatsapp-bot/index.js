const { default: makeWASocket, useMultiFileAuthState, DisconnectReason } = require('@whiskeysockets/baileys');
const pino = require('pino');
const qrcode = require('qrcode-terminal');

// ✅ YOUR GROUP ID
const ALLOWED_GROUP_ID = "120363407989591305@g.us"; 

async function connectToWhatsApp() {
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');

    const sock = makeWASocket({
        logger: pino({ level: 'silent' }),
        printQRInTerminal: false,
        auth: state,
        markOnlineOnConnect: false,
        syncFullHistory: false
    });

    sock.ev.on('connection.update', (update) => {
        const { connection, lastDisconnect, qr } = update;
        
        if (qr) {
            console.log("Scan this:");
            qrcode.generate(qr, { small: true });
        }

        if (connection === 'close') {
            const shouldReconnect = (lastDisconnect.error)?.output?.statusCode !== DisconnectReason.loggedOut;
            if (shouldReconnect) connectToWhatsApp();
        } else if (connection === 'open') {
            console.log(`✅ System Online. Listening in: ${ALLOWED_GROUP_ID}`);
        }
    });

    sock.ev.on('creds.update', saveCreds);

    sock.ev.on('messages.upsert', async ({ messages }) => {
        const msg = messages[0];
        if (!msg.message || !msg.key.remoteJid) return;
        
        const remoteJid = msg.key.remoteJid;
        const text = msg.message.conversation || msg.message.extendedTextMessage?.text || "";

        // --- FILTER ---
        if (remoteJid !== ALLOWED_GROUP_ID) return;
        if (!text.startsWith('.')) return;

        const command = text.slice(1).trim().toLowerCase();
        console.log(`[CMD] ${command}`);

        switch (command) {
            case 'ping':
                await sock.sendMessage(remoteJid, { text: 'Pong! 🏓' });
                break;

            case 'start':
                await sock.sendMessage(remoteJid, { text: '🤖 Bot is Active & Listening' });
                break;

            case 'time':
                const now = new Date().toLocaleString("en-IN", { timeZone: "Asia/Kolkata" });
                await sock.sendMessage(remoteJid, { text: `🕒 ${now}` });
                break;

            case 'help':
                const menu = `📜 *Commands:*\n.ping - Check connection\n.time - Check India time\n.start - Check status`;
                await sock.sendMessage(remoteJid, { text: menu });
                break;
        }
    });
}

connectToWhatsApp();

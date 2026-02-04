const { default: makeWASocket, useMultiFileAuthState } = require('@whiskeysockets/baileys');
const pino = require('pino');

async function connect() {
    const { state, saveCreds } = await useMultiFileAuthState('auth_info_baileys');
    const sock = makeWASocket({
        logger: pino({ level: 'silent' }),
        printQRInTerminal: true,
        auth: state
    });

    sock.ev.on('creds.update', saveCreds);
    sock.ev.on('messages.upsert', ({ messages }) => {
        const msg = messages[0];
        if (!msg.message) return;
        console.log("------------------------------------------------");
        console.log("💬 GROUP ID:", msg.key.remoteJid);
        console.log("------------------------------------------------");
    });
}
connect();

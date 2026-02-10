# Stirling-PDF

**PDF Manipulation Tools**

A locally hosted web-based PDF manipulation tool. Merge, split, rotate, convert, compress, and sign PDFs without uploading to third-party services.

## 🚀 Usage

- **URL:** `https://pdf.your-domain.com`
- **Default Credentials:** None (security disabled by default).

## 💾 Volumes

- `../../config/stirling-pdf/trainingData`: OCR training data (Tessdata).
- `../../config/stirling-pdf/extraConfigs`: Custom configuration files.
- `../../config/stirling-pdf/logs`: Application logs.

## 📝 Notes

- Host port is `8082` (internal `8080`) to avoid conflict with qBittorrent (`8080`) and FileBrowser (`8081`).
- Set `DOCKER_ENABLE_SECURITY=true` to enable login authentication.

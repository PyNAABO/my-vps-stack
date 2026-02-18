# FileBrowser

**Web-based File Manager**

A file management interface which can be used to upload, delete, preview, rename and edit your files within your web browser.

## 🚀 Usage

- **URL:** `https://drive.your-domain.com`
- **Default Credentials:** Randomized on first startup. Check logs:
  ```bash
  docker logs filebrowser
  ```

## 💾 Volumes

- `config/fb`: Configuration directory (Database & Settings).
- `/srv`: Mapped to `../vps-data` (shared data directory, sibling to repo).

# Dashboard

**Auto-generated App Launcher**

A simple, static HTML dashboard that links to all your deployed services.

## 🛠️ How it Works

The `index.html` is **auto-generated** during deployment by `generate.sh`.

1.  **Scans Apps:** The script looks for `ingress.yml` files in every `apps/` subfolder.
2.  **Extracts Info:** It reads the `hostname` and determining the `app_name`.
3.  **Injects Tiles:** It replaces the `<!-- TILES -->` placeholder in `template.html` with a grid of links.

## 🎨 Customization

- **Template:** Edit `template.html` to change the layout, CSS, or static headers.
- **Icons:** Edit `generate.sh` (`get_icon` function) to add emojis for new apps.

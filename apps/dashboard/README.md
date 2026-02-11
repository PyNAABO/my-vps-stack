# Dashboard

**Auto-generated App Launcher**

A modern, responsive dashboard that displays your apps in a premium, glassmorphic grid.

## ✨ Features

- **Responsive Grid**: Automatically arranges apps in a responsive grid that works on all screen sizes
- **Premium Aesthetics**: Deep, rich color palette with glassmorphism and subtle animations
- **Interactive UI**: Hover effects, 3D tilt interactions, and smooth transitions
- **Mesh Background**: Dynamic, animated background for a modern look
- **Auto-Generated**: Automatically builds from your deployed apps

## 🛠️ How it Works

The `index.html` is **auto-generated** during deployment by `generate.sh`.

1.  **Scans Apps:** The script looks for `ingress.yml` files in every `apps/` subfolder.
2.  **Extracts Info:** It reads the `hostname` and determining the `app_name`.
3.  **Injects Tiles:** It replaces the `<!-- TILES -->` placeholder in `template.html` with a grid of links.
4.  **Responsive Layout:** CSS Grid handles the layout automatically based on available space.

## 🎨 Customization

- **Template:** Edit `template.html` to change the layout, CSS, or static headers.
- **Icons:** Edit `icons.conf` to add or modify emoji icons for apps.

### Adding Custom Icons

Edit `icons.conf` and add entries in the format:

```
app_name=emoji
```

Example:

```
my-custom-app=🚀
database=🗄️
ai-service=🧠
```

## 📐 Layout Behavior

- **Square Tiles**: Tiles maintain a roughly square aspect ratio.
- **Responsive Columns**: The number of columns adjusts automatically (auto-fit).
- **Mobile Friendly**: optimized padding and sizing for smaller screens.

## 🎯 Technical Details

- Uses modern **CSS Grid** (`repeat(auto-fit, minmax(...))`)
- **Glassmorphism** with backdrop-filter
- **Performance Optimized** animations (transform/opacity)
- **No heavy JS dependencies** (Micro-interactions use lightweight vanilla JS)

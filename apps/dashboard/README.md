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
- **Icons:** Edit `icons.conf` to add or modify icons for apps.

### Adding Custom Icons

Edit `icons.conf` and add entries in the format:

```
app_name=fa-solid fa-icon-name
```

Example:

```
my-custom-app=fa-solid fa-rocket
database=fa-solid fa-database
ai-service=fa-solid fa-brain
```

Icons use [FontAwesome 6](https://fontawesome.com/icons) classes. Emoji icons are also supported as a fallback.

## 📐 Layout Behavior

- **3-Column Grid**: Desktop uses a `1fr 1.6fr 1fr` layout with a prominent center column.
- **Featured Tile**: The last-used app is automatically promoted to a large featured tile in the center.
- **Responsive**: Collapses to a 2-column grid on mobile (≤900px).
- **Mobile Friendly**: Optimized padding and sizing for smaller screens.

## 🎯 Technical Details

- Uses modern **CSS Grid** with a fixed 3-column layout
- **Glassmorphism** with backdrop-filter and animated mesh background
- **3D Tilt** interactions on hover (perspective-based transforms)
- **"Last Used" memory** via `localStorage` for the featured tile
- **Light/Dark mode** via `prefers-color-scheme` media query
- **No heavy JS dependencies** (Micro-interactions use lightweight vanilla JS)

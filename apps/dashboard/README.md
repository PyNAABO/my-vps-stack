# Dashboard

**Auto-generated App Launcher**

A modern, responsive dashboard that automatically adapts to fill your entire screen. All apps are displayed in a dynamic grid that resizes to fit any number of services without scrolling.

## ✨ Features

- **Full-Screen Adaptive Grid**: Automatically calculates optimal layout based on viewport size and app count
- **No Scrollbars**: All tiles fit within the viewport regardless of how many apps you have
- **Dynamic Resizing**: Tiles shrink to make room as you add more apps
- **Glassmorphism Design**: Modern translucent UI with backdrop blur effects
- **Smooth Animations**: Elegant transitions when resizing or hovering
- **Responsive**: Works seamlessly on desktop, tablet, and mobile devices
- **Dark/Light Mode**: Automatic theme switching based on system preferences

## 🛠️ How it Works

The `index.html` is **auto-generated** during deployment by `generate.sh`.

1.  **Scans Apps:** The script looks for `ingress.yml` files in every `apps/` subfolder.
2.  **Extracts Info:** It reads the `hostname` and determining the `app_name`.
3.  **Injects Tiles:** It replaces the `<!-- TILES -->` placeholder in `template.html` with a grid of links.
4.  **Dynamic Layout:** JavaScript calculates the optimal grid dimensions and tile sizes to fill the entire screen.

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

- **Square Tiles**: All tiles maintain a 1:1 aspect ratio
- **Optimal Grid**: Calculates columns/rows to approximate a square-ish layout
- **Gap Spacing**: Fixed gaps between tiles that scale slightly with viewport
- **Font Scaling**: Text and icons scale proportionally with tile size
- **No Minimum Size**: Tiles can become arbitrarily small as more apps are added (use browser zoom if needed)

## 🎯 Technical Details

- Uses CSS Grid with JavaScript-calculated dimensions
- CSS Custom Properties for dynamic values
- ResizeObserver for real-time responsive adjustments
- Hardware-accelerated animations
- Supports unlimited number of apps

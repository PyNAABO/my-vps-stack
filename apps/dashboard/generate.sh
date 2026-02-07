#!/bin/bash
# Generate dashboard HTML from ingress.yml files
# Usage: ./generate_dashboard.sh <domain>

DOMAIN="$1"
OUTPUT_DIR="config/dashboard"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

mkdir -p "$OUTPUT_DIR"

# HTML Header
cat > "$OUTPUT_FILE" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VPS Dashboard</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding: 2rem;
    }
    h1 { color: #fff; font-size: 2rem; margin-bottom: 2rem; text-shadow: 0 2px 10px rgba(0,0,0,0.3); }
    .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 1.5rem; max-width: 900px; width: 100%; }
    .tile {
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      border: 1px solid rgba(255,255,255,0.2);
      border-radius: 16px;
      padding: 1.5rem;
      text-align: center;
      text-decoration: none;
      color: #fff;
      transition: all 0.3s ease;
    }
    .tile:hover { transform: translateY(-5px); background: rgba(255,255,255,0.2); box-shadow: 0 10px 30px rgba(0,0,0,0.3); }
    .tile-icon { font-size: 2.5rem; margin-bottom: 0.75rem; }
    .tile-name { font-weight: 600; font-size: 1.1rem; }
    .footer { margin-top: 2rem; color: rgba(255,255,255,0.5); font-size: 0.85rem; }
  </style>
</head>
<body>
  <h1>🚀 VPS Dashboard</h1>
  <div class="grid">
EOF

# Icon mapping
get_icon() {
  case "$1" in
    portainer) echo "🐳" ;;
    dozzle) echo "📜" ;;
    filebrowser) echo "📁" ;;
    qbittorrent) echo "⬇️" ;;
    uptime-kuma) echo "📊" ;;
    telegram-bot) echo "🤖" ;;
    whatsapp-bot) echo "💬" ;;
    *) echo "🔗" ;;
  esac
}

# Generate tiles from ingress files
for ingress_file in apps/*/ingress.yml; do
  [ -f "$ingress_file" ] || continue
  
  app_name=$(basename "$(dirname "$ingress_file")")
  [ "$app_name" = "dashboard" ] && continue
  
  if command -v yq &>/dev/null; then
    hostname=$(yq '.hostname' "$ingress_file")
  else
    hostname=$(grep "^hostname:" "$ingress_file" | awk '{print $2}')
  fi
  
  icon=$(get_icon "$app_name")
  display_name=$(echo "$app_name" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g')
  
  cat >> "$OUTPUT_FILE" << TILE
    <a href="https://${hostname}.${DOMAIN}" class="tile" target="_blank">
      <div class="tile-icon">${icon}</div>
      <div class="tile-name">${display_name}</div>
    </a>
TILE
done

# HTML Footer
cat >> "$OUTPUT_FILE" << 'EOF'
  </div>
  <p class="footer">Auto-generated on deploy</p>
</body>
</html>
EOF

echo "✅ Dashboard generated: $OUTPUT_FILE"

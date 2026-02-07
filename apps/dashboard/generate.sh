#!/bin/bash
# Generate dashboard HTML from template + ingress.yml files
# Usage: ./generate.sh <domain>

DOMAIN="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$SCRIPT_DIR/template.html"
OUTPUT_DIR="config/dashboard"
OUTPUT_FILE="$OUTPUT_DIR/index.html"

mkdir -p "$OUTPUT_DIR"

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

# Build tiles HTML
TILES=""
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
  
  TILES+="    <a href=\"https://${hostname}.${DOMAIN}\" class=\"tile\" target=\"_blank\">
      <div class=\"tile-icon\">${icon}</div>
      <div class=\"tile-name\">${display_name}</div>
    </a>
"
done

# Inject tiles into template
sed "s|<!-- TILES -->|${TILES}|" "$TEMPLATE" > "$OUTPUT_FILE"

echo "✅ Dashboard generated: $OUTPUT_FILE"

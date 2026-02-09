#!/bin/bash
# Generate dashboard HTML from template + ingress.yml files
# Usage: ./generate.sh <domain>

DOMAIN="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$SCRIPT_DIR/template.html"
ICON_CONF="$SCRIPT_DIR/icons.conf"
OUTPUT_DIR="config/dashboard"
OUTPUT_FILE="$OUTPUT_DIR/index.html"
TILES_FILE="/tmp/dashboard_tiles.html"

mkdir -p "$OUTPUT_DIR"

# Load icon from config file
get_icon() {
  local app_name="$1"
  local icon=""
  
  # Read from config file
  if [ -f "$ICON_CONF" ]; then
    icon=$(grep "^${app_name}=" "$ICON_CONF" | cut -d'=' -f2)
  fi
  
  # Fallback to default if not found
  if [ -z "$icon" ]; then
    icon=$(grep "^__default__=" "$ICON_CONF" | cut -d'=' -f2)
    # Ultimate fallback if config is broken
    [ -z "$icon" ] && icon="🔗"
  fi
  
  echo "$icon"
}

# Build tiles HTML to temp file
> "$TILES_FILE"
for ingress_file in apps/*/ingress.yml; do
  [ -f "$ingress_file" ] || continue
  
  app_name=$(basename "$(dirname "$ingress_file")")
  [ "$app_name" = "dashboard" ] && continue
  [ "$app_name" = "_template" ] && continue
  
  if command -v yq &>/dev/null; then
    hostname=$(yq '.hostname' "$ingress_file")
  else
    hostname=$(grep "^hostname:" "$ingress_file" | awk '{print $2}')
  fi
  
  # Sanitize inputs for HTML (XSS prevention)
  hostname=$(echo "$hostname" | sed 's/[<>&"'"'"']//g')
  
  icon=$(get_icon "$app_name")
  display_name=$(echo "$app_name" | sed 's/-/ /g' | sed 's/\b\(.\)/\u\1/g' | sed 's/[<>&"'"'"']//g')
  
  cat >> "$TILES_FILE" << TILE
    <a href="https://${hostname}.${DOMAIN}" class="tile" target="_blank">
      <div class="tile-icon">${icon}</div>
      <div class="tile-name">${display_name}</div>
    </a>
TILE
done

# Inject tiles into template using awk (handles multi-line)
awk -v tiles="$(cat "$TILES_FILE")" '{gsub(/<!-- TILES -->/, tiles); print}' "$TEMPLATE" > "$OUTPUT_FILE"

rm -f "$TILES_FILE"
echo "✅ Dashboard generated: $OUTPUT_FILE"

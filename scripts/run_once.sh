#!/bin/bash

# Get the directory where this script resides
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "⚙️  Setting up 'update' alias..."

# 1. Check if update.sh exists
if [ ! -f "$SCRIPT_DIR/update.sh" ]; then
    echo "❌ Error: update.sh not found in $SCRIPT_DIR"
    echo "   Please create update.sh or remove this script."
    exit 1
fi

# 2. Make the update script executable
chmod +x "$SCRIPT_DIR/update.sh"

# 3. Check if alias already exists to avoid duplicates
if grep -q "# Custom VPS Update Shortcut" ~/.bashrc; then
    echo "⚠️  Update shortcut already exists in .bashrc. Skipping."
else
    # 3. Add the alias to .bashrc
    echo "" >> ~/.bashrc
    echo "# Custom VPS Update Shortcut" >> ~/.bashrc
    echo "alias update='$SCRIPT_DIR/update.sh'" >> ~/.bashrc
    echo "✅ Alias added: Type 'update' to upgrade your server."
fi

# 4. Remind user to source the file (since a script cannot reload the parent shell)
echo "---------------------------------------------------"
echo "🎉 Setup Complete!"
echo "👉 Run this command now to activate the shortcut:"
echo "   source ~/.bashrc"
echo "---------------------------------------------------"

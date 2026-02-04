#!/bin/bash

# Get the current directory where this script is running
CURRENT_DIR=$(pwd)

echo "⚙️  Setting up 'update' alias..."

# 1. Make the update script executable
chmod +x "$CURRENT_DIR/update.sh"

# 2. Check if alias already exists to avoid duplicates
if grep -q "alias update=" ~/.bashrc; then
    echo "⚠️  Alias 'update' already exists in .bashrc. Skipping."
else
    # 3. Add the alias to .bashrc
    echo "" >> ~/.bashrc
    echo "# Custom VPS Update Shortcut" >> ~/.bashrc
    echo "alias update='$CURRENT_DIR/update.sh'" >> ~/.bashrc
    echo "✅ Alias added: Type 'update' to upgrade your server."
fi

# 4. Remind user to source the file (since a script cannot reload the parent shell)
echo "---------------------------------------------------"
echo "🎉 Setup Complete!"
echo "👉 Run this command now to activate the shortcut:"
echo "   source ~/.bashrc"
echo "---------------------------------------------------"

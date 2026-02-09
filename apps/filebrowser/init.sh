#!/bin/bash
# FileBrowser first-time setup

mkdir -p config/fb

# Generate settings.json
cat <<EOF > config/fb/settings.json
{
  "port": 80,
  "address": "",
  "database": "/database.db",
  "root": "/srv"
}
EOF

# Initialize FileBrowser DB if missing
if [ ! -s config/fb/filebrowser.db ]; then
  touch config/fb/filebrowser.db
  chmod 644 config/fb/filebrowser.db
  docker run --rm \
    -v $(pwd)/config/fb/filebrowser.db:/database.db \
    -v $(pwd)/config/fb/settings.json:/config/settings.json \
    filebrowser/filebrowser config init
  docker run --rm \
    -v $(pwd)/config/fb/filebrowser.db:/database.db \
    -v $(pwd)/config/fb/settings.json:/config/settings.json \
    filebrowser/filebrowser users add admin adminadmin1234 --perm.admin
  echo "✅ FileBrowser DB initialized with admin user"
  echo "⚠️  WARNING: Default credentials are 'admin' / 'adminadmin1234'. Change them immediately!"
fi

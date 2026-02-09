#!/bin/bash
# Dozzle first-time setup

mkdir -p config/dozzle

if [ ! -s config/dozzle/users.yml ] || ! grep -q "admin" config/dozzle/users.yml; then
  echo "🔑 Generating Dozzle users.yml..."
  cat <<EOF > config/dozzle/users.yml
users:
  admin:
    password: \$2b\$10\$ySjC8IQdII482vNmny9QZeNcJBQe/xJeqAZYFk/gcz3fe2cyrRlAG
    name: Admin User
    email: admin@example.com
EOF
  chmod 644 config/dozzle/users.yml
  echo "✅ Dozzle users.yml generated"
else
  echo "✅ Dozzle users.yml already exists and is valid"
fi

#!/bin/bash
# Dozzle first-time setup

mkdir -p config/dozzle

if [ ! -s config/dozzle/users.yml ]; then
  echo "🔑 Generating Dozzle users.yml..."
  # Generate admin user with password adminadmin1234
  docker run --rm amir20/dozzle:latest generate --user admin --password adminadmin1234 > config/dozzle/users.yml
  chmod 644 config/dozzle/users.yml
  echo "✅ Dozzle users.yml generated"
fi

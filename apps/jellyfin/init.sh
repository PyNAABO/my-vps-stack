#!/bin/bash
mkdir -p "$(dirname "$0")/../../config/jellyfin"
chown -R 1000:1000 "$(dirname "$0")/../../config/jellyfin"

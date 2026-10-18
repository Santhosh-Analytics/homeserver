#!/usr/bin/env bash
set -euo pipefail
source /root/.config/restic/env

# System recipe: package list + system config
mkdir -p /home/san/server_data/_system
dpkg --get-selections > /home/san/server_data/_system/packages.txt
tar -czf /home/san/server_data/_system/etc.tar.gz -C / etc 2>/dev/null || true

# Stop HA briefly so its SQLite database is consistent
docker stop homeassistant
trap 'docker start homeassistant' EXIT

restic backup \
  /home/san/server_data \
  /home/san/server_infra \
  /home/san/.config \
  /var/lib/alsa \
  --exclude-caches \
  --exclude '/home/san/server_data/piper' \
  --exclude '/home/san/server_data/whisper' \
  --exclude '/home/san/server_data/*/.cache' \
  --tag nightly

docker start homeassistant
trap - EXIT

restic forget --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

#!/bin/bash
set -e

# --- Validate required env ---
if [ -z "$DB9_API_KEY" ]; then
  echo "ERROR: DB9_API_KEY is required" >&2
  exit 1
fi
# --- Authenticate ---
echo "[db9] Logging in..."
db9 login --api-key "$DB9_API_KEY"

# --- Resolve or create database ---
if [ -z "$DB9_DBNAME" ]; then
  echo "[db9] No DB9_DBNAME provided, creating a new database..."
  CREATE_OUTPUT=$(db9 --json create)
  DB9_DBNAME=$(echo "$CREATE_OUTPUT" | jq -r '.name')
  echo "[db9] Created database: $DB9_DBNAME"
else
  echo "[db9] Using database: $DB9_DBNAME"
fi

# --- Ensure mount point exists ---
mkdir -p /mnt/db9fs

# --- Mount via FUSE (background) ---
echo "[db9] Mounting $DB9_DBNAME at /mnt/db9fs ..."
db9 fs mount "$DB9_DBNAME" /mnt/db9fs &
MOUNT_PID=$!

# Wait until the mount point is ready
for i in $(seq 1 30); do
  mountpoint -q /mnt/db9fs && break
  sleep 0.5
done
mountpoint -q /mnt/db9fs || { echo "ERROR: mount timed out" >&2; exit 1; }
echo "[db9] Mounted. PID=$MOUNT_PID"

# --- Launch Claude Code in /mnt/db9fs ---
cd /mnt/db9fs
exec claude --dangerously-skip-permissions

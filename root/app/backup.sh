#!/bin/sh

PRE_BACKUP_SCRIPT=/scripts/pre-backup.sh
POST_BACKUP_SCRIPT=/scripts/post-backup.sh

[[ -f "/data/.duplicacy/preferences" ]] || {
  echo "Duplicacy preference not found"
  exit 1
}

do_backup() {
  status=0

  if [[ -f "$PRE_BACKUP_SCRIPT" ]]; then
    echo "Running pre-backup script"
    sh "$PRE_BACKUP_SCRIPT" 2>&1 | tee /tmp/backup.log
    status="$?"
  fi

  if [[ "$status" != 0 ]]; then
    echo "Pre-backup script exited with status code $status. Not performing backup." >&2
    return
  fi

  echo "Backing up"
  duplicacy backup $DUPLICACY_BACKUP_OPTIONS 2>&1 | tee -a /tmp/backup.log
  status="$?"

  if [[ -f "$POST_BACKUP_SCRIPT" ]]; then
    echo "Running post-backup script"
    sh "$POST_BACKUP_SCRIPT" "$status" | tee -a /tmp/backup.log
    status="$?"
    echo "Post-backup script exited with status $status"
  fi
}

do_prune() {
  if [[ ! -z "$DUPLICACY_PRUNE_OPTIONS" ]]; then
    echo "Prunning"
    duplicacy -log prune $DUPLICACY_PRUNE_OPTIONS
  fi
}

case "$1" in
  backup)
    do_backup
    ;;
  prune)
    do_prune
    ;;
  *)
    echo "Invalid command, usage: $0 <backup|prune> "
esac

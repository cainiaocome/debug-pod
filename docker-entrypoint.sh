#!/usr/bin/env bash

set -Eeuo pipefail

if [[ ${DEBUG_HERE_ROOT:-0} == 1 ]]; then
  exec "$@"
fi

debug_uid=${DEBUG_UID:-0}
debug_gid=${DEBUG_GID:-0}
preferred_user=${DEBUG_USER:-debug}
preferred_group=${DEBUG_GROUP:-$preferred_user}

if [[ ! $debug_uid =~ ^[0-9]+$ || ! $debug_gid =~ ^[0-9]+$ ]]; then
  echo 'docker-entrypoint: DEBUG_UID and DEBUG_GID must be numeric' >&2
  exit 2
fi

if [[ $debug_uid == 0 ]]; then
  exec "$@"
fi

passwd_entry=$(getent passwd "$debug_uid" || true)

if [[ -n $passwd_entry ]]; then
  debug_user=${passwd_entry%%:*}
  debug_home=$(cut -d: -f6 <<<"$passwd_entry")
else
  group_entry=$(getent group "$debug_gid" || true)

  if [[ -n $group_entry ]]; then
    debug_group=${group_entry%%:*}
  else
    debug_group=$preferred_group
    if getent group "$debug_group" >/dev/null; then
      debug_group="debug-$debug_gid"
    fi
    groupadd --gid "$debug_gid" "$debug_group"
  fi

  debug_user=$preferred_user
  if getent passwd "$debug_user" >/dev/null; then
    debug_user="debug-$debug_uid"
  fi

  debug_home="/home/$debug_user"
  useradd \
    --uid "$debug_uid" \
    --gid "$debug_group" \
    --create-home \
    --home-dir "$debug_home" \
    --shell /bin/bash \
    "$debug_user"
fi

# Existing image users retain their established home directories. For an
# unusual account without one, provide an ephemeral writable home in /tmp.
if [[ -z $debug_home || $debug_home == /nonexistent ]]; then
  debug_home="/tmp/debug-home-$debug_uid"
fi
if [[ ! -d $debug_home ]]; then
  install -d -m 0755 -o "$debug_uid" -g "$debug_gid" "$debug_home"
fi

export HOME=$debug_home
export USER=$debug_user
export LOGNAME=$debug_user

exec gosu "$debug_uid:$debug_gid" "$@"

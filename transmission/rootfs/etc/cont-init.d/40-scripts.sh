#!/usr/bin/with-contenv bashio
# ==============================================================================
# Move the scripts to the correct location
# ==============================================================================
exec mkdir -p /data/scripts/
exec cp /scripts/* /data/scripts/ 2>/dev/null || true
# shopt -s nullglob dotglob

# scripts=(/scripts/*)
# if ((${#scripts[@]})); then
# 	mv -- "${scripts[@]}" /data/scripts/
# fi

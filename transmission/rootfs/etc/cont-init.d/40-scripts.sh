#!/usr/bin/with-contenv bashio
# ==============================================================================
# Move the scripts to the correct location
# ==============================================================================
mkdir -p /config/scripts/
shopt -s nullglob dotglob
scripts=(/scripts/*)
if ((${#scripts[@]})); then
	mv -- "${scripts[@]}" /data/scripts/
fi

#!/usr/bin/env bash

source "$(dirname "$0")/utils/logger.sh"
source "$(dirname "$0")/utils/config.sh"
source "$(dirname "$0")/utils/path.sh"
source "$(dirname "$0")/utils/pack.sh"

check_dependencies
setup_config_properties

log "Update resource packs...\n"
update_packs "$RESOURCE_PACKS_PATH" "$RESOURCE_PACKS_FILE" "$RESOURCE_PACK_HISTORY_FILE" "$RESOURCE_PACK_PATHS" ".mcpack"

log "Update behaviour packs...\n"
update_packs "$BEHAVIOR_PACKS_PATH" "$BEHAVIOR_PACKS_FILE" "$BEHAVIOR_PACK_HISTORY_FILE" "$BEHAVIOR_PACK_PATHS" ".mcaddon"
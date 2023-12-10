#!/usr/bin/env bash

source "$(dirname "$0")/utils/logger.sh"
source "$(dirname "$0")/utils/config.sh"
source "$(dirname "$0")/utils/path.sh"
source "$(dirname "$0")/utils/pack.sh"

check_config_file

check_config_value ".mc_world_path" && MC_WORLD_PATH=$(get_config_value ".mc_world_path")

check_path "$MC_WORLD_PATH" && log "info" "The Minecraft world path is: $MC_WORLD_PATH \n"


RESOURCE_PACKS_PATH="$MC_WORLD_PATH/resource_packs"
RESOURCE_PACKS_FILE="$MC_WORLD_PATH/world_resource_packs.json"
RESOURCE_PACK_HISTORY_FILE="$MC_WORLD_PATH/world_resource_pack_history.json"
RESOURCE_PACK_PATHS="$(get_config_value "try .resource_paths // empty | .[]")"

log "info" "Update resource packs...\n"
update_packs "$RESOURCE_PACKS_PATH" "$RESOURCE_PACKS_FILE" "$RESOURCE_PACK_HISTORY_FILE" "$RESOURCE_PACK_PATHS"

BEHAVIOR_PACKS_PATH="$MC_WORLD_PATH/behavior_packs"
BEHAVIOR_PACKS_FILE="$MC_WORLD_PATH/world_behavior_packs.json"
BEHAVIOR_PACK_HISTORY_FILE="$MC_WORLD_PATH/world_behavior_pack_history.json"
BEHAVIOR_PACK_PATHS="$(get_config_value "try .behavior_paths // empty | .[]")"

log "info" "Update behaviour packs...\n"
update_packs "$BEHAVIOR_PACKS_PATH" "$BEHAVIOR_PACKS_FILE" "$BEHAVIOR_PACK_HISTORY_FILE" "$BEHAVIOR_PACK_PATHS"
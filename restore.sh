#!/usr/bin/env bash

source "$(dirname "$0")/utils/logger.sh"
source "$(dirname "$0")/utils/config.sh"
source "$(dirname "$0")/utils/path.sh"
source "$(dirname "$0")/utils/pack.sh"
source "$(dirname "$0")/utils/props.sh"

type=$1
uuid=$2
version=$3

check_dependencies
setup_config_properties

check_property "type" "$type"
check_property "uuid" "$uuid"
check_property "version" "$version"

log "info" "Downgrade to $version for $uuid"

if [ "$type" == "resource" ]; then
    restore_pack "$uuid" "$version" "$RESOURCE_PACKS_PATH" "$RESOURCE_PACKS_FILE" "$RESOURCE_PACK_HISTORY_FILE"
    exit 0
fi

if [ "$type" == "mod" ]; then
    restore_pack "$uuid" "$version" "$BEHAVIOR_PACKS_PATH" "$BEHAVIOR_PACKS_FILE" "$BEHAVIOR_PACK_HISTORY_FILE"
    exit 0
fi

log "error" "The type doesn't have the accepted values (resource, mod)"

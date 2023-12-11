CONFIG_FILE="config.json"

check_config_file() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log "error" "The $CONFIG_FILE file does not exist"
        exit 1
    fi
}

get_config_value() {
    local config_term=$1

   jq -r "$config_term" "$CONFIG_FILE"

}

check_config_value() {
    local config_term=$1
    config_value=$(jq -r "$config_term" "$CONFIG_FILE")

    if [ "$config_value" == null ]; then
        log "error" "The variable $config_term is not defined in the $CONFIG_FILE file"
        exit 1
    fi
}

check_dependencies() {
    local missing_dependencies=()

    if ! command -v rsync &> /dev/null; then
        missing_dependencies+=("rsync")
    fi

    if ! command -v jq &> /dev/null; then
        missing_dependencies+=("jq")
    fi

    if [ ! ${#missing_dependencies[@]} -eq 0 ]; then
        echo "Missing dependencies: ${missing_dependencies[*]}"
        exit 1
    fi
}

setup_config_properties() {
    check_config_file

    check_config_value ".mc_world_path" && MC_WORLD_PATH=$(get_config_value ".mc_world_path")

    check_path "$MC_WORLD_PATH" && log "info" "The Minecraft world path is: $MC_WORLD_PATH \n"

    export RESOURCE_PACKS_PATH="$MC_WORLD_PATH/resource_packs"
    export RESOURCE_PACKS_FILE="$MC_WORLD_PATH/world_resource_packs.json"
    export RESOURCE_PACK_HISTORY_FILE="$MC_WORLD_PATH/world_resource_pack_history.json"
    RESOURCE_PACK_PATHS=$(get_config_value "try .resource_paths // empty | .[]")
    export RESOURCE_PACK_PATHS

    export BEHAVIOR_PACKS_PATH="$MC_WORLD_PATH/behavior_packs"
    export BEHAVIOR_PACKS_FILE="$MC_WORLD_PATH/world_behavior_packs.json"
    export BEHAVIOR_PACK_HISTORY_FILE="$MC_WORLD_PATH/world_behavior_pack_history.json"
    BEHAVIOR_PACK_PATHS="$(get_config_value "try .behavior_paths // empty | .[]")"
    export BEHAVIOR_PACK_PATHS

}
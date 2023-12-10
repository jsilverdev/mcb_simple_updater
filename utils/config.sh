CONFIG_FILE="config.json"

check_config_file() {
    if [ ! -f "$CONFIG_FILE" ]; then
        log "error" "The $CONFIG_FILE file does not exist"
        exit 1
    fi
}

get_config_value() {
    local config_term=$1

    config_value=$(jq -r "$config_term" "$CONFIG_FILE")

    echo "$config_value"
}

check_config_value() {
    local config_term=$1
    config_value=$(jq -r "$config_term" "$CONFIG_FILE")

    if [ "$config_value" == null ]; then
        log "error" "The variable $config_term is not defined in the $CONFIG_FILE file"
        exit 1
    fi
}
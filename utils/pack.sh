
update_version_in_packs_file() {

    local uuid=$1
    local current_version=$2
    local packs_file=$3
    local tmp_file="/tmp/${uuid}_tmp.json"

    if [ -f "$packs_file" ]; then
        uuid_found=$(jq -r --arg uuid "$uuid" '.[] | select(.pack_id == $uuid) | .pack_id' "$packs_file")
        if [ "$uuid_found" == "$uuid" ]; then
            jq --arg current_version "$current_version" --arg uuid "$uuid" 'map(if .pack_id == $uuid then .version = ($current_version | split(".") | map(tonumber)) else . end)' "$packs_file" > "$tmp_file"
            mv "$tmp_file" "$packs_file"
            log "success" "The version in $packs_file has been updated"
        else
            log "alert" "No matching UUID found ($uuid) in $packs_file"
        fi
    fi
}

update_version_in_pack_history_file() {

    local uuid=$1
    local current_version=$2
    local pack_history_file=$3
    local tmp_file="/tmp/${uuid}_tmp.json"

    if [ -f "$pack_history_file" ]; then
        uuid_found=$(jq -r --arg uuid "$uuid" '.packs[] | select(.uuid == $uuid) | .uuid' "$pack_history_file")
        if [ "$uuid_found" == "$uuid" ]; then
            jq --arg current_version "$current_version" --arg uuid "$uuid" '(.packs[] | select(.uuid == $uuid)).version = ($current_version | split(".") | map(tonumber))' "$pack_history_file" > "$tmp_file"
            mv "$tmp_file" "$pack_history_file"
            log "success" "The version in $pack_history_file has been updated"
        else
            log "alert" "No matching UUID found in $pack_history_file"
        fi
    fi
}

get_version_of_pack() {
    local pack_path=$1

   jq -r '.header.version | map(tostring) | join(".")' "$pack_path/manifest.json"
}

get_uuid_of_pack() {
    local pack_path=$1

    jq -r '.header.uuid' "$pack_path/manifest.json"
}

get_name_of_pack() {
    local pack_path=$1
    jq -r '.header.name' "$pack_path/manifest.json"
}

get_latest_version() {
    current_version=$1
    new_version=$2

    printf '%s\n' "$new_version" "$current_version" | tr '-' '~' | sort -V | tail -n1 | tr '~' '-'
}


update_packs() {
    local WORLD_PACKS_PATH=$1
    local WORLD_PACKS_FILE=$2
    local WORLD_PACK_HISTORY_FILE=$3
    local WORLD_PACK_PATHS=$4

    if [ -d "$WORLD_PACKS_PATH" ] && [ -n "$WORLD_PACK_PATHS" ]; then

        while IFS= read -r pack_folder_path; do

                pack_folder_uuid=$(get_uuid_of_pack "$pack_folder_path")
                pack_folder_version=$(get_version_of_pack "$pack_folder_path")

                log "info" "name: $(get_name_of_pack "$pack_folder_path")"
                log "info" "uuid: $pack_folder_uuid"
                log "info" "version: $pack_folder_version"

                while IFS= read -r path; do

                        # If not exists omit
                        [ ! -d "$path" ] && continue

                        uuid=$(get_uuid_of_pack "$path")
                        version=$(get_version_of_pack "$path")

                        [ "$uuid" != "$pack_folder_uuid" ] && continue
                        [ "$(get_latest_version "$pack_folder_version" "$version")" == "$pack_folder_version" ] && continue
                        log "version to update: $version"

                        rm -rf "$pack_folder_path" && mkdir "$pack_folder_path"
                        cp -r "$path/." "$pack_folder_path/."
                        log "success" "The files in $pack_folder_path has been updated"

                        update_version_in_packs_file "$uuid" "$version" "$WORLD_PACKS_FILE"
                        update_version_in_pack_history_file "$uuid" "$version" "$WORLD_PACK_HISTORY_FILE"

                done <<< "$WORLD_PACK_PATHS"
                log "\n"

        done < <(find "$WORLD_PACKS_PATH" -mindepth 1 -maxdepth 1 -type d)

    else
        log "alert" "No resource packs path exists or resources packs not defined"
    fi
}
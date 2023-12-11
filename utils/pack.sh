
update_version_in_packs_file() {

    local uuid=$1
    local current_version=$2
    local packs_file=$3
    local tmp_file="${uuid}_tmp.json"

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
    local tmp_file="${uuid}_tmp.json"

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

BACKUPS_PATH="backups"
update_packs() {
    local world_packs_path=$1
    local world_packs_file=$2
    local world_pack_history_file=$3
    local world_pack_paths=$4
    local world_pack_extension=$5

    if [ -d "$world_packs_path" ] && [ -n "$world_pack_paths" ]; then

        while IFS= read -r pack_folder_path; do

                pack_folder_uuid=$(get_uuid_of_pack "$pack_folder_path")
                pack_folder_version=$(get_version_of_pack "$pack_folder_path")

                log "info" "name: $(get_name_of_pack "$pack_folder_path")"
                log "info" "uuid: $pack_folder_uuid"
                log "info" "version: $pack_folder_version"

                while IFS= read -r path; do

                        # If not exists omit
                        [ ! -e "$path" ] && continue

                        if [ -f "$path" ] && [[ "$path" == *"$world_pack_extension" ]]; then

                            # Check if is a zip file
                            ! file -b --mime-type "$path" | grep -q "zip" && continue

                            temp_dir=$(mktemp -d)
                            unzip -q "$path" -d "$temp_dir"
                            top_level_dir=$(find "$temp_dir" -mindepth 1 -maxdepth 1 -type d -printf '%P\n')
                            path="$temp_dir/$top_level_dir"
                        fi

                        if [ ! -d "$path" ]; then
                            delete_folder_if_exists "$temp_dir"
                            continue
                        fi

                        uuid=$(get_uuid_of_pack "$path")
                        version=$(get_version_of_pack "$path")

                        if [ "$uuid" != "$pack_folder_uuid" ]; then
                            delete_folder_if_exists "$temp_dir"
                            continue
                        fi

                        if [ "$(get_latest_version "$pack_folder_version" "$version")" == "$pack_folder_version" ]; then
                            delete_folder_if_exists "$temp_dir"
                            continue
                        fi

                        log "alert" "version to update: $version"

                        [ ! -d "$BACKUPS_PATH" ] && mkdir -p "$BACKUPS_PATH"

                        path_to_backup="$BACKUPS_PATH/${pack_folder_uuid} - ${pack_folder_version}"

                        if [ -d "$path_to_backup" ]; then
                            log "alert" "This current version is alerady in backups folder"
                            rm -rf "$pack_folder_path"
                        else
                            mv "$pack_folder_path" "$path_to_backup"
                        fi
                        mkdir "$pack_folder_path"
                        rsync -a --exclude='.git' "$path/" "$pack_folder_path/"
                        log "success" "The files in $pack_folder_path has been updated"
                        delete_folder_if_exists "$temp_dir"

                        update_version_in_packs_file "$uuid" "$version" "$world_packs_file"
                        update_version_in_pack_history_file "$uuid" "$version" "$world_pack_history_file"

                done <<< "$world_pack_paths"
                log ""

        done < <(find "$world_packs_path" -mindepth 1 -maxdepth 1 -type d)

    else
        log "alert" "No world packs path exists or world packs not defined"
    fi
}

restore_pack() {
    uuid=$1
    version=$2
    world_packs_path=$3
    world_packs_file=$4
    world_pack_history_file=$5

    path_to_restore="$BACKUPS_PATH/${uuid} - ${version}"

    if [ ! -d "$path_to_restore" ]; then
        log "alert" "The uuid $uuid with version $version doesn't exists"
        exit 1
    fi

    while IFS= read -r pack_folder_path; do

        pack_folder_uuid=$(get_uuid_of_pack "$pack_folder_path")
        pack_folder_version=$(get_version_of_pack "$pack_folder_path")

        [ "$uuid" != "$pack_folder_uuid" ] && continue

        if [ "$version" == "$pack_folder_version" ]; then
            log "alert" "The $uuid pack has the same version of the installed"
            continue
        fi

        rm -rf "$pack_folder_path"
        mkdir "$pack_folder_path"
        rsync -a --exclude='.git' "$path_to_restore/" "$pack_folder_path/"
        log "success" "The files in $pack_folder_path has been restored"

        update_version_in_packs_file "$uuid" "$version" "$world_packs_file"
        update_version_in_pack_history_file "$uuid" "$version" "$world_pack_history_file"

    done < <(find "$world_packs_path" -mindepth 1 -maxdepth 1 -type d)
}
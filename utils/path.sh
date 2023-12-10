check_path() {
    path=$1

    if [ ! -d "$path" ]; then
        log "error" "The specified path $path does not exist"
        exit 1
    fi
}
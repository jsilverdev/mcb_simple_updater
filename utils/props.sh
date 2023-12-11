check_property() {
    prop_name=$1
    prop=$2
    if [ -z "$prop" ]; then
        log "error" "Required property $prop_name missing"
        exit 1
    fi
}
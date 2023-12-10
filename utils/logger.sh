log() {
    case "$1" in
        "info")
            echo -e "\e[96m$2\e[0m"
            ;;
        "error")
            echo -e "\e[91m$2\e[0m"
            ;;
        "success")
            echo -e "\e[92m$2\e[0m"
            ;;
        "alert")
            echo -e "\e[93m$2\e[0m"
            ;;
        *)
            echo -e "$1"
            ;;
    esac
}
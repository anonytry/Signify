#!/bin/bash
# Helper functions with timeouts

confirm_timeout() {
    local prompt_msg="$1"
    local default_choice="$2"
    local timeout=15

    [[ "$AUTO_MODE" == "true" ]] && echo "$default_choice" && return

    read -r -t $timeout -p "$prompt_msg (yes/no) [Default: $default_choice, Timeout: ${timeout}s]: " input
    local exit_code=$?

    if [[ $exit_code -gt 128 ]]; then
        echo -e "\n--> Timeout reached. Using default: $default_choice"
        echo "$default_choice"
        return
    fi

    case "$input" in
        [yY][eE][sS]|[yY]) echo "yes" ;;
        [nN][oO]|[nN]) echo "no" ;;
        *) echo "$default_choice" ;;
    esac
}

prompt_default_timeout() {
    local prompt_msg="$1"
    local default_val="$2"
    local timeout=15

    [[ "$AUTO_MODE" == "true" ]] && echo "$default_val" && return

    read -t $timeout -p "$prompt_msg [$default_val, Timeout: ${timeout}s]: " input
    local exit_code=$?

    if [[ $exit_code -gt 128 ]]; then
        echo -e "\n--> Timeout reached. Using default: $default_val"
        echo "$default_val"
    else
        echo "${input:-$default_val}"
    fi
}

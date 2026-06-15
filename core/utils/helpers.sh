#!/bin/bash
# Minimal Helper functions

confirm_timeout() {
    local prompt_msg="$1"
    local default_choice="$2"
    local timeout=15
    local hint="[y/n]"

    [[ "$AUTO_MODE" == "true" ]] && echo "$default_choice" && return

    # Minimal prompt style
    printf "${YELLOW}?? ${prompt_msg} ${hint} (${timeout}s): ${NC}" >&2
    
    read -r -t $timeout input
    local exit_code=$?

    if [[ $exit_code -gt 128 ]]; then
        echo -e "\n${BLUE}--> Timeout. Using: $default_choice${NC}" >&2
        echo "$default_choice"
        return
    fi

    case "$input" in
        [yY]*) echo "yes" ;;
        [nN]*) echo "no" ;;
        *) echo "$default_choice" ;;
    esac
}

prompt_default_timeout() {
    local prompt_msg="$1"
    local default_val="$2"
    local timeout=15

    [[ "$AUTO_MODE" == "true" ]] && echo "$default_val" && return

    printf "${YELLOW}>> ${prompt_msg} [${default_val}] (15s): ${NC}" >&2
    
    read -t $timeout input
    local exit_code=$?

    if [[ $exit_code -gt 128 ]]; then
        echo -e "\n${BLUE}--> Timeout. Using: $default_val${NC}" >&2
        echo "$default_val"
    else
        echo "${input:-$default_val}"
    fi
}

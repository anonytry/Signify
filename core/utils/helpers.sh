#!/bin/bash
# Minimal Helper functions (No timeouts)

confirm() {
    local prompt_msg="$1"
    local default_choice="$2"
    local hint="[y/n]"

    [[ "$AUTO_MODE" == "true" ]] && echo "$default_choice" && return

    # Minimal prompt style
    printf "${YELLOW}?? ${prompt_msg} ${hint}: ${NC}" >&2
    
    read -r input

    case "$input" in
        [yY]*) echo "yes" ;;
        [nN]*) echo "no" ;;
        *) echo "$default_choice" ;;
    esac
}

prompt_default() {
    local prompt_msg="$1"
    local default_val="$2"

    [[ "$AUTO_MODE" == "true" ]] && echo "$default_val" && return

    printf "${YELLOW}>> ${prompt_msg} [${default_val}]: ${NC}" >&2
    
    read input
    echo "${input:-$default_val}"
}

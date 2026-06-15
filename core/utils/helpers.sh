#!/bin/bash
# Minimal Helper functions with Silent Timeouts

confirm() {
    local prompt_msg="$1"
    local default_choice="$2"
    local timeout=20 # Manageable 20s timeout

    [[ "$AUTO_MODE" == "true" ]] && echo "$default_choice" && return

    # Clean prompt: no visible timer but backend timeout active
    printf "${YELLOW}?? ${prompt_msg} [y/n]: ${NC}" >&2
    
    read -r -t $timeout input
    local exit_code=$?

    if [[ $exit_code -gt 128 ]]; then
        # Silent timeout: just use default and move on
        echo "$default_choice"
        return
    fi

    case "$input" in
        [yY]*) echo "yes" ;;
        [nN]*) echo "no" ;;
        *) echo "$default_choice" ;;
    esac
}

prompt_default() {
    local prompt_msg="$1"
    local default_val="$2"
    local timeout=20

    [[ "$AUTO_MODE" == "true" ]] && echo "$default_val" && return

    printf "${YELLOW}>> ${prompt_msg} [${default_val}]: ${NC}" >&2
    
    read -t $timeout input
    local exit_code=$?

    if [[ $exit_code -gt 128 ]]; then
        echo "$default_val"
    else
        echo "${input:-$default_val}"
    fi
}

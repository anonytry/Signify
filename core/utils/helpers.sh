#!/bin/bash
confirm() {
    [[ "$AUTO_MODE" == "true" ]] && echo "yes" && return
    read -r -p "$1 (yes/no): " input
    case "$input" in [yY]*) echo "yes" ;; *) echo "no" ;; esac
}
prompt_default() {
    [[ "$AUTO_MODE" == "true" ]] && echo "$2" && return
    read -p "$1 [$2]: " input
    echo "${input:-$2}"
}

# SPDX-License-Identifier: Apache-2.0
# Signify Core Helpers & Paths

# ==============================
# HELPER FUNCTIONS
# ==============================
green()  { echo -e "\e[1;32m$1\e[0m"; }
yellow() { echo -e "\e[1;33m$1\e[0m"; }
red()    { echo -e "\e[1;31m$1\e[0m"; }

check_dependencies() {
    local missing=()
    for cmd in openssl python3 git; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        red "Error: Missing dependencies: ${missing[*]}"
        exit 1
    fi
}

confirm() {
    while true; do
        read -r -p "$1 (yes/no): " input
        case "$input" in
            [yY][eE][sS]|[yY]) echo "yes"; return ;;
            [nN][oO]|[nN]) echo "no"; return ;;
        esac
    done
}

prompt() {
    while true; do
        read -p "$1" input
        [[ -n "$input" ]] && echo "$input" && return
    done
}

prompt_key_size() {
    while true; do
        read -p "$1" input
        [[ "$input" == "2048" || "$input" == "4096" ]] && echo "$input" && return
    done
}

# ==============================
# PATHS (ROM ROOT SAFE)
# ==============================
if [[ -z "$ROM_ROOT" ]]; then
    echo "Error: ROM_ROOT not set. Run Signify from ROM root."
    exit 1
fi

MAKE_KEY="$ROM_ROOT/development/tools/make_key"

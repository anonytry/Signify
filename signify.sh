#!/bin/bash
# Signify - Advanced ROM Signing Wrapper

# --- User Editable Defaults ---
export DEFAULT_KEY_SIZE=4096
export DEFAULT_SUBJECT="/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com"
export KEYS_DIR="vendor/los/keys"
export SKIP_OTA="false"
# ------------------------------

# Configuration
export REPO_URL="https://github.com/anonytry/Signify.git"
export REPO_BRANCH="16.2"
export TOOL_DIR="signify"

# Must be run from ROM root
if [[ ! -f "build/envsetup.sh" ]]; then
    echo "Error: Run this script from the ROM root directory."
    exit 1
fi

export ROM_ROOT="$(pwd)"

# --- Bootstrap & Absolute Pathing ---
RELATIVE_SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
export SCRIPT_DIR="$(cd "$RELATIVE_SCRIPT_DIR" && pwd)"

if [[ "$(basename "$SCRIPT_DIR")" != "$TOOL_DIR" ]]; then
    if [[ ! -d "$TOOL_DIR/.git" ]]; then
        echo -e "\e[1;34m--> Cloning Signify into $TOOL_DIR\e[0m"
        git clone --depth=1 -b "$REPO_BRANCH" "$REPO_URL" "$TOOL_DIR"
    fi
    exec bash "$TOOL_DIR/signify.sh" "$@"
fi

# Modular components source
source "$SCRIPT_DIR/core/ui/colors.sh"
source "$SCRIPT_DIR/core/utils/helpers.sh"
source "$SCRIPT_DIR/core/logic/config.sh"
source "$SCRIPT_DIR/core/logic/signing.sh"

check_for_updates() {
    [[ "$AUTO_MODE" == "true" ]] && return
    [[ ! -d "$SCRIPT_DIR/.git" ]] && return

    printf "${YELLOW}--> Checking for updates... ${NC}" >&2
    (cd "$SCRIPT_DIR" && git fetch origin "$REPO_BRANCH" --quiet)
    
    LOCAL_HASH=$(cd "$SCRIPT_DIR" && git rev-parse HEAD)
    REMOTE_HASH=$(cd "$SCRIPT_DIR" && git rev-parse "origin/$REPO_BRANCH")

    if [[ "$LOCAL_HASH" != "$REMOTE_HASH" ]]; then
        echo -e "${BLUE}[Update Available]${NC}" >&2
        if [[ $(confirm "Update Signify now?" "no") == "yes" ]]; then
            echo -e "${GREEN}--> Updating...${NC}"
            (cd "$SCRIPT_DIR" && git reset --hard "origin/$REPO_BRANCH")
            echo -e "${GREEN}--> Restarting...${NC}"
            exec bash "$SCRIPT_DIR/signify.sh" "$@"
        fi
    else
        echo -e "${GREEN}[Up to date]${NC}" >&2
    fi
}

main() {
    print_banner
    detect_mode "$@"
    
    # We honor the editable default set at the top
    export KEYS_DIR="${KEYS_DIR}"
    setup_paths # Ensures directory exists

    if [[ "$AUTO_MODE" == "false" ]]; then
        # 1. Self Update
        check_for_updates

        # 2. Skip OTA
        export SKIP_OTA=$(confirm "Skip OTA key generation (Unofficial)?" "$SKIP_OTA")

        # 3. Customization
        if [[ $(confirm "Customize Key Config (Size/Dir/Subject)?" "no") == "yes" ]]; then
            export KEY_SIZE=$(prompt_default "Key Size" "$DEFAULT_KEY_SIZE")
            export KEYS_DIR=$(prompt_default "Keys Directory" "$KEYS_DIR")
            export SUBJECT_INFO=$(prompt_default "Subject Info" "$DEFAULT_SUBJECT")
        fi
    fi

    # Finalize variables
    export KEY_SIZE="${KEY_SIZE:-$DEFAULT_KEY_SIZE}"
    export SUBJECT_INFO="${SUBJECT_INFO:-$DEFAULT_SUBJECT}"
    export KEYS_DIR="${KEYS_DIR}"
    export SKIP_OTA="${SKIP_OTA:-false}"
    
    run_signing
}

main "$@"

#!/bin/bash
# Signify - Advanced ROM Signing Wrapper

# --- User Editable Defaults ---
export DEFAULT_KEY_SIZE=4096
export DEFAULT_SUBJECT="/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com"
export KEYS_DIR="vendor/signify/keys"
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

# --- Bootstrap & Self-Update Logic ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(basename "$SCRIPT_DIR")" != "$TOOL_DIR" ]]; then
    if [[ ! -d "$TOOL_DIR/.git" ]]; then
        echo "--> Cloning Signify ($REPO_BRANCH) into $TOOL_DIR"
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

    echo -e "${YELLOW}--> Checking for updates...${NC}"
    git fetch origin "$REPO_BRANCH" --quiet
    LOCAL_HASH=$(git rev-parse HEAD)
    REMOTE_HASH=$(git rev-parse "origin/$REPO_BRANCH")

    if [[ "$LOCAL_HASH" != "$REMOTE_HASH" ]]; then
        if [[ $(confirm_timeout "New update available. Update now?" "no") == "yes" ]]; then
            echo -e "${GREEN}--> Updating Signify...${NC}"
            git reset --hard "origin/$REPO_BRANCH"
            echo -e "${GREEN}--> Restarting after update...${NC}"
            exec bash "$0" "$@"
        fi
    else
        echo -e "${GREEN}--> Signify is up to date.${NC}"
    fi
}

main() {
    print_banner
    detect_mode "$@"
    setup_paths

    if [[ "$AUTO_MODE" == "false" ]]; then
        # 1. Self Update
        check_for_updates

        # 2. Skip OTA preference
        export SKIP_OTA=$(confirm_timeout "Skip OTA key generation (Unofficial build)?" "$SKIP_OTA")

        # 3. Further Customization
        if [[ $(confirm_timeout "Do you want to customize other settings (Key size/Subject)?" "no") == "yes" ]]; then
            export KEY_SIZE=$(prompt_default_timeout "Enter key size" "$DEFAULT_KEY_SIZE")
            export SUBJECT_INFO=$(prompt_default_timeout "Enter subject info" "$DEFAULT_SUBJECT")
            export KEYS_DIR=$(prompt_default_timeout "Enter keys directory" "$KEYS_DIR")
        fi
    fi

    # Finalize variables
    export KEY_SIZE="${KEY_SIZE:-$DEFAULT_KEY_SIZE}"
    export SUBJECT_INFO="${SUBJECT_INFO:-$DEFAULT_SUBJECT}"
    export SKIP_OTA="${SKIP_OTA:-false}"
    
    run_signing
}

main "$@"

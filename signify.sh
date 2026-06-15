#!/bin/bash
# Signify - Advanced ROM Signing Wrapper

# --- User Editable Defaults ---
export DEFAULT_KEY_SIZE=4096
export DEFAULT_SUBJECT="/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com"
export KEYS_DIR="vendor/signify/keys"
export SKIP_OTA="false"
# ------------------------------

# Configuration
export REPO_URL="https://github.com/TopexGuy/Signify-New.git"
export REPO_BRANCH="16.2" # Set your branch here
export TOOL_DIR="signify"

# Must be run from ROM root
if [[ ! -f "build/envsetup.sh" ]]; then
    echo "Error: Run this script from the ROM root directory."
    exit 1
fi

# Set ROM_ROOT immediately
export ROM_ROOT="$(pwd)"

# --- Bootstrap Logic ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(basename "$SCRIPT_DIR")" != "$TOOL_DIR" ]]; then
    if [[ ! -d "$TOOL_DIR/.git" ]]; then
        echo "--> Cloning Signify ($REPO_BRANCH) into $TOOL_DIR"
        git clone --depth=1 -b "$REPO_BRANCH" "$REPO_URL" "$TOOL_DIR"
    fi
    exec bash "$TOOL_DIR/signify.sh" "$@"
fi

# --- Modular Execution ---
source "$SCRIPT_DIR/core/ui/colors.sh"
source "$SCRIPT_DIR/core/utils/helpers.sh"
source "$SCRIPT_DIR/core/logic/config.sh"
source "$SCRIPT_DIR/core/logic/signing.sh"

main() {
    print_banner
    detect_mode "$@"
    setup_paths

    if [[ "$AUTO_MODE" == "false" ]]; then
        # 1. Self Update Prompt (Default: no)
        if [[ -d "$SCRIPT_DIR/.git" ]]; then
            if [[ $(confirm_timeout "Do you want to check for updates?" "no") == "yes" ]]; then
                echo "--> Checking for updates..."
                (cd "$SCRIPT_DIR" && git fetch origin && git reset --hard origin/"$REPO_BRANCH")
            fi
        fi

        # 2. Key Customization (Default: no, meaning use defaults)
        if [[ $(confirm_timeout "Do you want to customize key configuration?" "no") == "yes" ]]; then
            export KEY_SIZE=$(prompt_default_timeout "Enter key size" "$DEFAULT_KEY_SIZE")
            export SUBJECT_INFO=$(prompt_default_timeout "Enter subject info" "$DEFAULT_SUBJECT")
            export KEYS_DIR=$(prompt_default_timeout "Enter keys directory" "$KEYS_DIR")
            export SKIP_OTA=$(confirm_timeout "Skip OTA key generation (Unofficial build)?" "no")
        fi
    fi

    # Finalize variables for backend
    export KEY_SIZE="${KEY_SIZE:-$DEFAULT_KEY_SIZE}"
    export SUBJECT_INFO="${SUBJECT_INFO:-$DEFAULT_SUBJECT}"
    export SKIP_OTA="${SKIP_OTA:-$DEFAULT_OTA_CHOICE:-false}"
    
    run_signing
}

main "$@"

#!/bin/bash
# Signify - Advanced ROM Signing Wrapper (The Ghost Tool)

# --- User Editable Defaults ---
# We use vendor/signify/keys as the default to honor previous preference
export DEFAULT_KEY_SIZE="${DEFAULT_KEY_SIZE:-4096}"
export DEFAULT_SUBJECT="${DEFAULT_SUBJECT:-/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com}"
export KEYS_DIR="${KEYS_DIR:-vendor/signify/keys}"
export SKIP_OTA="${SKIP_OTA:-false}"
# ------------------------------

# Configuration
export REPO_URL="https://github.com/anonytry/Signify.git"
export REPO_BRANCH="16.2"

# Must be run from ROM root
if [[ ! -f "build/envsetup.sh" ]]; then
    echo "Error: Run this script from the ROM root directory."
    exit 1
fi

export ROM_ROOT="$(pwd)"

# --- Enhanced Ghost Execution Logic ---
# Force fresh clone if we are not in a temporary session yet
if [[ "$SIGNIFY_TMP_ACTIVE" != "true" ]]; then
    
    export TEMP_DIR="/tmp/.signify_$(date +%s)"
    
    echo -e "\e[1;34m--> Preparing Signify (Isolated Session)...\e[0m"
    mkdir -p "$TEMP_DIR"
    
    if ! git clone --depth=1 -b "$REPO_BRANCH" "$REPO_URL" "$TEMP_DIR" > /dev/null 2>&1; then
        echo "Error: Failed to clone Signify repository."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Export state to child process
    export SIGNIFY_TMP_ACTIVE="true"
    export SIGNIFY_REAL_ROOT="$ROM_ROOT"
    export SIGNIFY_PARENT_TEMP="$TEMP_DIR"
    
    # Run from temp location
    bash "$TEMP_DIR/signify.sh" "$@"
    
    echo -e "\e[1;34m--> Session finished. Cleaning up...\e[0m"
    rm -rf "$TEMP_DIR"
    
    # UNSET Signify environment to prevent pollution of the parent shell
    unset SIGNIFY_TMP_ACTIVE SIGNIFY_REAL_ROOT SIGNIFY_PARENT_TEMP TEMP_DIR
    unset DEFAULT_KEY_SIZE DEFAULT_SUBJECT KEYS_DIR SKIP_OTA KEY_SIZE SUBJECT_INFO AUTO_MODE
    
    exit 0
fi

# --- Execution (Running from Temp) ---
export ROM_ROOT="${SIGNIFY_REAL_ROOT:-$ROM_ROOT}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modular components
source "$SCRIPT_DIR/core/ui/colors.sh"
source "$SCRIPT_DIR/core/utils/helpers.sh"
source "$SCRIPT_DIR/core/logic/config.sh"
source "$SCRIPT_DIR/core/logic/signing.sh"

main() {
    print_banner
    detect_mode "$@"
    setup_paths # Ensures directory exists

    if [[ "$AUTO_MODE" == "false" ]]; then
        # 1. Skip OTA preference
        export SKIP_OTA=$(confirm "Skip OTA key generation (Unofficial)?" "$SKIP_OTA")

        # 2. Customization
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
    export SKIP_OTA="${SKIP_OTA}"
    
    run_signing
}

main "$@"

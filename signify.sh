#!/bin/bash
# Signify - Advanced ROM Signing Wrapper (Temporary Execution Mode)

# --- User Editable Defaults ---
export DEFAULT_KEY_SIZE=4096
export DEFAULT_SUBJECT="/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com"
export KEYS_DIR="vendor/los/keys"
export SKIP_OTA="false"
# ------------------------------

# Configuration
export REPO_URL="https://github.com/anonytry/Signify.git"
export REPO_BRANCH="16.2"
# Temp directory for one-time execution
export TEMP_DIR="/tmp/.signify_$(date +%s)"

# Must be run from ROM root
if [[ ! -f "build/envsetup.sh" ]]; then
    echo "Error: Run this script from the ROM root directory."
    exit 1
fi

export ROM_ROOT="$(pwd)"

# --- Temporary Execution Bootstrap ---
# Check if we are already running from a temp location
if [[ "$SIGNIFY_TMP_ACTIVE" != "true" ]]; then
    echo -e "\e[1;34m--> Preparing Signify (One-time Use)...\e[0m"
    mkdir -p "$TEMP_DIR"
    git clone --depth=1 -b "$REPO_BRANCH" "$REPO_URL" "$TEMP_DIR" > /dev/null 2>&1
    
    # Export flag to prevent infinite loop
    export SIGNIFY_TMP_ACTIVE="true"
    export SIGNIFY_REAL_ROOT="$ROM_ROOT"
    
    # Run from temp location and clean up after
    bash "$TEMP_DIR/signify.sh" "$@"
    
    echo -e "\e[1;34m--> Cleaning up temporary files...\e[0m"
    rm -rf "$TEMP_DIR"
    exit 0
fi

# --- Execution Logic (Running from Temp) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modular components
source "$SCRIPT_DIR/core/ui/colors.sh"
source "$SCRIPT_DIR/core/utils/helpers.sh"
source "$SCRIPT_DIR/core/logic/config.sh"
source "$SCRIPT_DIR/core/logic/signing.sh"

main() {
    print_banner
    detect_mode "$@"
    setup_paths

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
    export SKIP_OTA="${SKIP_OTA:-false}"
    
    run_signing
}

main "$@"

#!/bin/bash
# Signify - Advanced ROM Signing Wrapper (The Ghost Tool)

# --- User Editable Defaults (Supports Environment Overrides) ---
export DEFAULT_KEY_SIZE="${DEFAULT_KEY_SIZE:-4096}"
export DEFAULT_SUBJECT="${DEFAULT_SUBJECT:-/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com}"
export KEYS_DIR="${KEYS_DIR:-vendor/los/keys}"
export SKIP_OTA="${SKIP_OTA:-false}"
# -------------------------------------------------------------

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
# If running from a remote curl or if SIGNIFY_FORCE_TEMP is set
if [[ "$SIGNIFY_TMP_ACTIVE" != "true" ]]; then
    
    # Generate unique temp directory
    export TEMP_DIR="/tmp/.signify_$(date +%s)"
    
    echo -e "\e[1;34m--> Preparing Signify (Isolated Session)...\e[0m"
    mkdir -p "$TEMP_DIR"
    
    # Clone and redirect output
    if ! git clone --depth=1 -b "$REPO_BRANCH" "$REPO_URL" "$TEMP_DIR" > /dev/null 2>&1; then
        echo "Error: Failed to clone Signify repository."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Export state to child process
    export SIGNIFY_TMP_ACTIVE="true"
    export SIGNIFY_PARENT_DIR="$TEMP_DIR"
    
    # Run and cleanup
    bash "$TEMP_DIR/signify.sh" "$@"
    
    echo -e "\e[1;34m--> Session finished. Cleaning up...\e[0m"
    rm -rf "$TEMP_DIR"
    exit 0
fi

# --- Execution (Running from Temp) ---
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
        export SKIP_OTA=$(confirm "Skip OTA key generation (Unofficial build)?" "$SKIP_OTA")

        # 2. Customization
        if [[ $(confirm "Customize Key Config (Size/Dir/Subject)?" "no") == "yes" ]]; then
            export KEY_SIZE=$(prompt_default "Key Size" "$DEFAULT_KEY_SIZE")
            export KEYS_DIR=$(prompt_default "Keys Directory" "$KEYS_DIR")
            export SUBJECT_INFO=$(prompt_default "Subject Info" "$DEFAULT_SUBJECT")
        fi
    fi

    # Finalize variables (Prioritize the ones set in main over defaults)
    export KEY_SIZE="${KEY_SIZE:-$DEFAULT_KEY_SIZE}"
    export SUBJECT_INFO="${SUBJECT_INFO:-$DEFAULT_SUBJECT}"
    export KEYS_DIR="${KEYS_DIR}" # Already handled by top level export and customization
    export SKIP_OTA="${SKIP_OTA}"
    
    run_signing
}

main "$@"

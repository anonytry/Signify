#!/bin/bash
# Signify - Advanced ROM Signing Wrapper

# --- User Editable Defaults ---
export DEFAULT_KEY_SIZE=4096
export DEFAULT_SUBJECT="/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com"
export KEYS_DIR="vendor/signify/keys"
export SKIP_OTA="false" # Set to "true" for unofficial builds
# ------------------------------

# Configuration
REPO_URL="https://github.com/TopexGuy/Signify-New.git"
TOOL_DIR="signify"

# Must be run from ROM root
if [[ ! -f "build/envsetup.sh" ]]; then
    echo "Error: Run this script from the ROM root directory."
    exit 1
fi

# --- Bootstrap Logic ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$(basename "$SCRIPT_DIR")" != "$TOOL_DIR" ]]; then
    if [[ ! -d "$TOOL_DIR/.git" ]]; then
        echo "--> Cloning Signify into $TOOL_DIR"
        git clone --depth=1 "$REPO_URL" "$TOOL_DIR"
    fi
    export ROM_ROOT="$(pwd)"
    exec bash "$TOOL_DIR/signify.sh" "$@"
fi

# --- Modular Execution ---
export ROM_ROOT="$(pwd)"
source "$SCRIPT_DIR/core/ui/colors.sh"
source "$SCRIPT_DIR/core/utils/helpers.sh"
source "$SCRIPT_DIR/core/logic/config.sh"
source "$SCRIPT_DIR/core/logic/signing.sh"

main() {
    print_banner
    detect_mode "$@"
    setup_paths

    if [[ "$AUTO_MODE" == "false" ]]; then
        # Interactive Customization
        if [[ $(confirm "Do you want to customize key configuration?") == "yes" ]]; then
            export KEY_SIZE=$(prompt_default "Enter key size" "$DEFAULT_KEY_SIZE")
            export SUBJECT_INFO=$(prompt_default "Enter subject info" "$DEFAULT_SUBJECT")
            export KEYS_DIR=$(prompt_default "Enter keys directory" "$KEYS_DIR")
            export SKIP_OTA=$(confirm "Skip OTA key generation (Unofficial build)?")
        fi
    fi

    # Ensure variables are set for backend
    export KEY_SIZE="${KEY_SIZE:-$DEFAULT_KEY_SIZE}"
    export SUBJECT_INFO="${SUBJECT_INFO:-$DEFAULT_SUBJECT}"
    
    run_signing
}

main "$@"

#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
#
# Script Name : Signify.sh
# Author      : TopexGuy
# Description : ROM signing key generator & manager

set -e

# ==============================
# CONFIGURATION
# ==============================
KEYS_DIR="vendor/signify/keys"
REPO_URL="https://github.com/anonytry/Signify.git"
TOOL_DIR="Signify"

# Parse Arguments
FORCE_REPAIR=false
NO_OTA=false
show_help() {
    echo "Usage: bash Signify.sh [flags]"
    echo ""
    echo "Flags:"
    echo "  --force   Automated repair: Deletes and re-generates corrupted/mismatched keys."
    echo "  --no-ota  Unofficial mode: Skips otakey generation. Uses AOSP Test-keys for OTA/Recovery."
    echo "  --help    Show this help message."
    exit 0
}

for arg in "$@"; do
    case $arg in
        --force) FORCE_REPAIR=true ;;
        --no-ota) NO_OTA=true ;;
        --help) show_help ;;
    esac
done

# Must be ROM root
if [[ ! -f "build/envsetup.sh" ]]; then
    echo "Error: Run Signify from ROM root directory"
    exit 1
fi

# ==============================================================================
# BOOTSTRAP (ENSURE WE HAVE A LOCAL CLONE IF NEEDED)
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If running directly from a script that isn't part of a git repo or in the wrong place,
# we might want to clone. But if we are already in a ROM root and have the scripts,
# we should just run.
if [[ ! -d "$SCRIPT_DIR/scripts" ]]; then
    if [[ ! -d "$TOOL_DIR/.git" ]]; then
        echo "→ Cloning Signify into ROM root/$TOOL_DIR"
        rm -rf "$TOOL_DIR"
        git clone --depth=1 "$REPO_URL" "$TOOL_DIR"
    fi

    echo "→ Re-launching Signify from $TOOL_DIR"
    export ROM_ROOT="$(pwd)"
    exec bash "$TOOL_DIR/Signify.sh" "$@"
fi

# ROM_ROOT is current directory if not set
export ROM_ROOT="${ROM_ROOT:-$(pwd)}"

# ==============================================================================
# LOAD MODULES
# ==============================================================================
source "$SCRIPT_DIR/scripts/core.sh"
source "$SCRIPT_DIR/scripts/update.sh"
source "$SCRIPT_DIR/scripts/keys_list.sh"
source "$SCRIPT_DIR/scripts/generate.sh"

# 0. Check dependencies
check_dependencies

# ==============================================================================
# EXECUTION FLOW
# ==============================================================================

# 1. Self Update
update_signify "$SCRIPT_DIR"

# 2. User Input / Configuration
setup_config() {
    echo ""
    yellow "── Signify: Key Configuration ──"
    
    if [[ $(confirm "Do you want to customize key size and subject info?") == "yes" ]]; then
        key_size=$(prompt_key_size "Enter standard key size (2048 or 4096): ")
        country_code=$(prompt "Country code (e.g. US): ")
        state=$(prompt "State/Province: ")
        city=$(prompt "City/Locality: ")
        org=$(prompt "Organization: ")
        ou=$(prompt "Organizational Unit: ")
        cn=$(prompt "Common Name: ")
        email=$(prompt "Email: ")
    else
        echo "→ Using automated default values (2048-bit standard, 4096-bit APEX)"
        key_size=2048
        country_code=US
        state=California
        city="Mountain View"
        org=Android
        ou=Android
        cn=Android
        email="android@android.com"
    fi

    SUBJECT="/C=$country_code/ST=$state/L=$city/O=$org/OU=$ou/CN=$cn/emailAddress=$email"
}

# Run setup
setup_config

# 3. Generate Certificates
generate_certificates

# 4. Finalize
green "\n✓ All tasks completed successfully!"
echo "Keys saved at: $KEYS_DIR"
echo -e "🔏 Generated with Signify by TopexGuy"

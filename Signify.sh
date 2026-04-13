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
REPO_URL="https://github.com/TopexGuy/Signify.git"
TOOL_DIR="Signify"

# Must be ROM root
if [[ ! -f "build/envsetup.sh" ]]; then
    echo "Error: Run Signify from ROM root directory"
    exit 1
fi

mkdir -p "$KEYS_DIR"

# ==============================================================================
# BOOTSTRAP (CLONE SIGNIFY INTO ROM ROOT, ONCE)
# ==============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If NOT already running from cloned repo, bootstrap
if [[ "$(basename "$SCRIPT_DIR")" != "$TOOL_DIR" ]]; then
    if [[ ! -d "$TOOL_DIR/.git" ]]; then
        echo "→ Cloning Signify into ROM root/$TOOL_DIR"
        rm -rf "$TOOL_DIR"
        git clone --depth=1 "$REPO_URL" "$TOOL_DIR"
    fi

    echo "→ Re-launching Signify from $TOOL_DIR"
    export ROM_ROOT="$(pwd)"
    exec bash "$TOOL_DIR/Signify.sh" "$@"
fi
# ==============================================================================

# NOTE:
# We intentionally DO NOT cd into $SCRIPT_DIR
# Working directory must remain ROM root

# ==============================================================================
# SELF UPDATE (SAFE, NO LOOP)
# ==============================================================================
if [[ -d "$SCRIPT_DIR/.git" ]]; then
    echo "→ Updating Signify tool"
    (cd "$SCRIPT_DIR" && git fetch origin && git reset --hard origin/ota)
fi
# ==============================================================================

# ==============================
# LOAD FILES
# ==============================
source "$SCRIPT_DIR/keys.mk"
source "$SCRIPT_DIR/lib"

# ==============================
# USER INPUT
# ==============================
user_input() {
    echo ""
    yellow "── Key Configuration ──"

    if [[ $(confirm "Do you want to customize key size and subject info?") == "yes" ]]; then
        key_size=$(prompt_key_size "Enter key size (2048 or 4096): ")
        country_code=$(prompt "Country code (e.g. US): ")
        state=$(prompt "State/Province: ")
        city=$(prompt "City/Locality: ")
        org=$(prompt "Organization: ")
        ou=$(prompt "Organizational Unit: ")
        cn=$(prompt "Common Name: ")
        email=$(prompt "Email: ")
    else
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
    generate_certificates
}

# ==============================
# ENTRYPOINT
# ==============================
user_input
green "\n✓ All tasks completed successfully!"
echo "Keys saved at: $KEYS_DIR"
echo -e "🔏 Generated with Signify by TopexGuy"

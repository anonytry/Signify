# SPDX-License-Identifier: Apache-2.0
# Signify Self-Update Logic

update_signify() {
    local script_dir="$1"

    if [[ ! -d "$script_dir/.git" ]]; then
        return
    fi

    if [[ ! -t 0 ]]; then
        echo "→ Auto mode detected (non-interactive)"
        echo "→ Skipping update check"
        return
    fi

    while true; do
        echo ""
        read -p "Do you want to check for Signify updates? (yes/no): " choice

        case "$choice" in
            yes|y|Y|YES)
                echo "→ Updating Signify..."
                local current_branch=$(cd "$script_dir" && git rev-parse --abbrev-ref HEAD)
                (cd "$script_dir" && git fetch origin && git reset --hard "origin/$current_branch")
                green "✓ Signify is now up to date!"
                break
                ;;
            no|n|N|NO)
                echo "→ Skipping update"
                break
                ;;
            *)
                echo "Invalid input. Please type yes or no."
                ;;
        esac
    done
}

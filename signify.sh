#!/bin/bash
export DEFAULT_KEY_SIZE=4096
export DEFAULT_SUBJECT="/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ROM_ROOT="$(pwd)"
source "$SCRIPT_DIR/core/ui/colors.sh"
source "$SCRIPT_DIR/core/utils/helpers.sh"
source "$SCRIPT_DIR/core/logic/config.sh"
source "$SCRIPT_DIR/core/logic/signing.sh"
main() {
    print_banner
    detect_mode "$@"
    run_signing "$DEFAULT_KEY_SIZE" "$DEFAULT_SUBJECT"
}
main "$@"

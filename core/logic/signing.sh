#!/bin/bash
# Core Signing Orchestration

run_signing() {
    echo -e "${GREEN}--> Starting Signing Process${NC}"
    echo "    Target Directory: $KEYS_DIR"
    echo "    Key Size: $KEY_SIZE"
    echo "    Skip OTA: $SKIP_OTA"

    # Export for AOSP backend scripts
    export KEYS_DIR="$KEYS_DIR"
    export KEY_SIZE="$KEY_SIZE"
    export SUBJECT_INFO="$SUBJECT_INFO"
    export SKIP_OTA="$SKIP_OTA"
    
    pushd "$SCRIPT_DIR/main" > /dev/null
    bash keys.sh
    popd > /dev/null
    
    echo -e "${GREEN}\n✓ Signing tasks completed successfully!${NC}"
    echo "Keys are located in: $KEYS_DIR"
}

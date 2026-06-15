#!/bin/bash
# Core Signing Orchestration

run_signing() {
    echo -e "${GREEN}--> Starting Signing Process${NC}"
    echo -e "    Target Directory: ${BLUE}$KEYS_DIR${NC}"
    echo -e "    Key Size: ${BLUE}$KEY_SIZE${NC}"
    echo -e "    Skip OTA: ${BLUE}$SKIP_OTA${NC}"

    # Export for AOSP backend scripts
    export KEYS_DIR="$KEYS_DIR"
    export KEY_SIZE="$KEY_SIZE"
    export SUBJECT_INFO="$SUBJECT_INFO"
    export SKIP_OTA="$SKIP_OTA"
    
    pushd "$SCRIPT_DIR/main" > /dev/null
    bash keys.sh
    popd > /dev/null
    
    echo -e "\n${GREEN}✓ All tasks completed successfully!${NC}"
    echo -e "Keys saved at: ${BLUE}$KEYS_DIR${NC}"
    echo -e "🔏 ${YELLOW}Generated with Signify by TopexGuy${NC}"
}

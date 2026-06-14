#!/bin/bash
# Core Signing Orchestration
run_signing() {
    local key_size=$1
    local subject=$2
    export KEY_SIZE="$key_size"
    export SUBJECT_INFO="$subject"
    pushd "$SCRIPT_DIR/main" > /dev/null
    bash keys.sh
    popd > /dev/null
}

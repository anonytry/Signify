#!/bin/bash
# Configuration and Environment Logic
detect_mode() {
    if [[ ! -t 0 ]] || [[ "$1" == "--auto" ]]; then
        export AUTO_MODE="true"
    else
        export AUTO_MODE="false"
    fi
}

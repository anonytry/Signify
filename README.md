# Signify - Advanced ROM Signing Wrapper

Signify is a modular and automated toolset designed for Android/AOSP ROM maintainers to generate and manage cryptographic signing keys. It provides a seamless bridge between user interaction and the standard AOSP key generation tools while maintaining a clean environment through its unique ghost execution model.

## Core Features

- Ghost Mode: Executes from a temporary isolated session in /tmp to keep the ROM root directory clean.
- Modular Architecture: Logic is separated into UI, Utils, and Core modules for high performance and maintainability.
- Dynamic Patching: Automatically updates keys.mk and Android.bp to reflect your custom key directory and certificate overrides.
- Environment Awareness: Detects CI environments, piped inputs, or manual terminal sessions to adjust behavior automatically.
- Customization: Full control over key size, subject information, and target directories via environment variables or interactive prompts.
- Silent Timeouts: Background timers ensure automated flow without UI clutter.

## Project Structure

- main/: Contains the AOSP backend scripts and key generation engine.
- core/: Contains the internal modular logic (UI, Config, Signing Orchestration).
- signify.sh: The main entry point and bootstrap wrapper.

## Prerequisites

- Must be run from the root of an Android ROM source tree.
- Git must be installed and configured.
- Standard AOSP build tools must be present in the source tree.

## Usage

### 1. Standard Interactive Mode
Run this command from your ROM root to start an interactive session with 20-second silent timeouts:

bash <(curl -s https://raw.githubusercontent.com/anonytry/Signify/16.2/signify.sh)

### 2. Automated / CI Mode
Use the --auto flag or set SIGNIFY_AUTO=true to bypass all prompts and use defaults:

bash <(curl -s https://raw.githubusercontent.com/anonytry/Signify/16.2/signify.sh) --auto

### 3. Customized Execution
You can override default settings by passing environment variables directly to the one-liner:

KEYS_DIR="vendor/custom/keys" SKIP_OTA="true" TIMEOUT="120" bash <(curl -s https://raw.githubusercontent.com/anonytry/Signify/16.2/signify.sh) --auto

## Environment Variables

- KEYS_DIR: Target directory for generated keys (Default: vendor/signify/keys).
- SKIP_OTA: Set to true to skip OTA key generation (Default: false).
- TIMEOUT: Set the duration in seconds for silent prompt timeouts (Default: 20).
- DEFAULT_KEY_SIZE: RSA key size (Default: 4096).
- DEFAULT_SUBJECT: Distinguished Name for certificates.

## Maintenance and Cherry-Picking

Since the AOSP backend is isolated in the main/ directory, you can easily backport upstream changes using git subtree strategies:

git cherry-pick <commit_hash> --strategy-option=subtree=main/

## Credits

Developed and maintained by TopexGuy.

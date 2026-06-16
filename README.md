# Signify

Android ROM signing keys generator (standard + APEX) for AOSP / LineageOS.

---

## Quick Start
```bash
bash <(curl -s https://raw.githubusercontent.com/anonytry/Signify/16.2/signify.sh) --auto
```

---

## Device Integration
Add to your `device.mk` or `common.mk`:
```makefile
$(call inherit-product-if-exists, vendor/signify/keys/keys.mk)
```

---

## Usage

> **Note:** Always run commands from your ROM's root directory.

**Manual mode (Interactive):**
```bash
bash <(curl -s https://raw.githubusercontent.com/anonytry/Signify/16.2/signify.sh)
```

**Auto mode (Defaults):**
```bash
bash <(curl -s https://raw.githubusercontent.com/anonytry/Signify/16.2/signify.sh) --auto
```

**Custom mode (Managed):**
```bash
KEYS_DIR="vendor/lineage-priv/keys" SKIP_OTA="true" bash <(curl -s https://raw.githubusercontent.com/anonytry/Signify/16.2/signify.sh) --auto
```

| Command / Variable | Action |
|:---|:---|
| `--auto` | Non-interactive mode (uses default values) |
| `KEYS_DIR="..."` | Custom output location (relative to ROM root) |
| `SKIP_OTA=true` | Skip OTA key generation |
| `TIMEOUT=20` | Set silent prompt duration in seconds |

---

## Output

- **Location:** `KEYS_DIR` (Default: `vendor/signify/keys`)
- **Generated:**
  - `*.pk8`, `*.x509.pem` (Standard + APEX certificates)
  - `Android.bp` (Auto-generated Soong modules)
  - `keys.mk` (Auto-patched product configuration)
  - `releasekey`

*Existing keys are never overwritten.*

---

## Features

- **Auto Standard + APEX:** Dynamic extraction and generation of all required certs.
- **Smart Build System:** Auto-generates `Android.bp` and patches `keys.mk` paths.
- **Manageable:** Full control over output directory and OTA key skipping.
- **Safe & Clean:** Runs from temporary memory; never deletes existing keys.
- **Universal:** Compatible with AOSP / LineageOS and ready for CI pipelines.

# Signify

Android ROM signing keys generator (standard + APEX) for AOSP / LineageOS.

---

## ⚡ Quick Start
```bash
echo 'no' | bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/ota/Signify.sh)
```
---

## ⚙️ Device Integration
Add to your `device.mk` or `common.mk`:
```makefile
$(call inherit-product-if-exists, vendor/signify/keys/keys.mk)
```

---


## 🔧 Usage

> **Note:** Always run these commands from your ROM's root directory.

**Manual mode (confirm prompts manually):**
```bash
bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/ota/Signify.sh)
```

**Auto mode (skip all prompts):**
```bash
echo 'no' | bash <(curl -s https://raw.githubusercontent.com/TopexGuy/Signify/ota/Signify.sh)
```

---

## 🚩 Flags

| Flag | Description |
| :--- | :--- |
| `--force` | **Automated Repair:** Automatically deletes and re-generates only the corrupted/mismatched keys. |
| `--no-ota` | **Unofficial Mode:** Skips `otakey` generation. Uses AOSP Test-keys for OTA/Recovery signature (Ensures dirty flash success on unofficial builds). |

---


## 📁 Output

- Keys stored in `KEYS_DIR`
  - Default: `vendor/signify/keys`

- Generated:
  - `*.pk8`, `*.x509.pem`
  - `Android.bp` (Auto-generated certificates)
  - Product `keys.mk`
  - `check_keys.py` (Stand-alone key validator)

Existing keys are never overwritten unless `--force` is used.


---


## 🚀 Features

- **Healer Logic:** Automated key validation and repair engine.
- **Smart APEX:** Forces 4096-bit RSA for APEX modules (Fixes bootloops).
- **Zero-Interaction:** Patched `make_key` to skip all password prompts.
- **Modular Layout:** Clean separation of logic and key lists.
- **OTA Compatibility:** Optional AOSP Test-key mode for easier dirty flashing.
- **Self-updating:** Safe clean refresh from GitHub.

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


## 📁 Output

- Keys stored in `KEYS_DIR`
  - Default: `vendor/signify/keys`

- Generated:
  - `*.pk8`, `*.x509.pem`
  - `Android.bp`
  - Product `keys.mk`
  - Standard + APEX certs
  - `releasekey`

Existing keys are never overwritten.


---


## 🚀 Features

- Auto standard + APEX signing keys
- Release-keys ready
- Self-updating (safe clean refresh)
- Keys never deleted
- Works with `vendor/signify`, `lineage-priv`, or custom paths
- AOSP / LineageOS compatible

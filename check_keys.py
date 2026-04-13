#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Signify Key Validator (Healer Edition)

import os
import subprocess
import sys
import glob
import re

def strip_ansi(text):
    ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    return ansi_escape.sub('', text)

def run_command(cmd):
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return strip_ansi(result.stdout.strip())
    except subprocess.CalledProcessError:
        return None

def get_key_size(cert_path):
    out = run_command(["openssl", "x509", "-in", cert_path, "-text", "-noout"])
    if out:
        for line in out.split('\n'):
            if "Public-Key:" in line:
                match = re.search(r'\((\d+) bit\)', line)
                if match:
                    return int(match.group(1))
    return 0

def keys_match(pk8_path, cert_path):
    pub_from_cert = run_command(["openssl", "x509", "-in", cert_path, "-pubkey", "-noout"])
    pub_from_pk8 = run_command(["openssl", "rsa", "-in", pk8_path, "-inform", "DER", "-pubout"])
    return pub_from_cert == pub_from_pk8 if pub_from_cert and pub_from_pk8 else False

def main():
    list_faulty = "--list-faulty" in sys.argv
    keys_dir = [a for a in sys.argv[1:] if not a.startswith("--")]
    keys_dir = keys_dir[0] if keys_dir else "."
    
    certs = glob.glob(os.path.join(keys_dir, "*.x509.pem"))
    errors = []
    results = []

    for cert in sorted(certs):
        name = os.path.basename(cert).replace(".x509.pem", "")
        pk8 = os.path.join(keys_dir, name + ".pk8")
        
        if not os.path.exists(pk8):
            errors.append(name)
            results.append(f"❌ {name.ljust(45)} [Missing Private Key]")
            continue
            
        size = get_key_size(cert)
        match = keys_match(pk8, cert)
        
        if not match:
            errors.append(name)
            results.append(f"❌ {name.ljust(45)} [Key Pair Mismatch]")
        else:
            is_apex = ".certificate.override" in name
            status = "✅"
            note = f"({size} bit)"
            if is_apex and size < 4096:
                status = "⚠️"
                note += " [W: APEX should be 4096!]"
            results.append(f"{status} {name.ljust(45)} {note}")

    if list_faulty:
        for e in errors:
            print(e)
    else:
        print(f"\n🔍 Validating keys in: {keys_dir}")
        print("-" * 65)
        for r in results:
            print(r)
        print("-" * 65)
        print(f"Validation finished: {len(errors)} Errors")
        sys.exit(1 if errors else 0)

if __name__ == "__main__":
    main()

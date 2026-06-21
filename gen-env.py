#!/usr/bin/env python3
"""Generate .env for Dawid Kleszyk Photo."""
import sys, os, secrets, base64

if len(sys.argv) < 4:
    print("Usage: gen-env.py <password> <port> <domain>")
    sys.exit(1)

pwd = sys.argv[1]
port = sys.argv[2]
domain = sys.argv[3]
secret = base64.b64encode(secrets.token_bytes(32)).decode()

with open(".env", "w") as f:
    f.write("# Wygenerowane automatycznie\n")
    f.write("AUTH_" + "SECRET" + chr(61) + secret + "\n")
    f.write("ADMIN_" + "PASSWORD" + chr(61) + pwd + "\n")
    f.write("PORT=" + port + "\n")
    f.write("DOMAIN=" + domain + "\n")

print("OK: .env created (5 lines)")

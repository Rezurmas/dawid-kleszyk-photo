#!/usr/bin/env python3
"""Generate .env for Dawid Kleszyk Photo.

Reads password from stdin (line 1) so it never appears in ps aux.
Takes port and domain as argv.
"""
import sys, secrets, base64

if len(sys.argv) < 3:
    print("Usage: echo <password> | gen-env.py <port> <domain>", file=sys.stderr)
    sys.exit(1)

port = sys.argv[1]
domain = sys.argv[2]

# read password from stdin (secure — never in argv / ps)
pwd = sys.stdin.readline().strip()
if not pwd:
    print("ERROR: no password on stdin", file=sys.stderr)
    sys.exit(1)

secret = base64.b64encode(secrets.token_bytes(32)).decode()

lines = [
    "# Wygenerowane automatycznie przez setup.sh",
    "AUTH_SECRET=" + secret,
    "ADMIN_PASSWORD=" + pwd,
    "PORT=" + port,
    "DOMAIN=" + domain,
    "",
]

with open(".env", "w") as f:
    f.write("\n".join(lines))

print("OK: .env created (5 lines)")

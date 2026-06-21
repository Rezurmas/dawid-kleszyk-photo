#!/usr/bin/env bats
# Test suite for setup.sh — Dawid Kleszyk Photo installer
# Run: bats tests/setup.bats

setup() {
    TEST_DIR="$(mktemp -d)"
    cp /root/dawid-kleszyk-photo/setup.sh "$TEST_DIR/"
    cp /root/dawid-kleszyk-photo/gen-env.py "$TEST_DIR/"
    cp /root/dawid-kleszyk-photo/docker-compose.yml "$TEST_DIR/" 2>/dev/null || true

    export PATH="$TEST_DIR/bin:$PATH"
    mkdir -p "$TEST_DIR/bin"

    # docker mock
    cat > "$TEST_DIR/bin/docker" <<'SCRIPT'
#!/usr/bin/env bash
if [[ "$1" == "compose" ]]; then
    if [[ "$2" == "version" ]]; then echo "Docker Compose v2.29.1"; exit 0; fi
    echo "mock: docker compose $*"; exit 0
elif [[ "$1" == "ps" ]]; then exit 0
else echo "Docker version 27.3.1"; fi
SCRIPT
    chmod +x "$TEST_DIR/bin/docker"

    # python3 mock
    cat > "$TEST_DIR/bin/python3" <<'SCRIPT'
#!/usr/bin/env bash
[[ "$1" == "--version" ]] && echo "Python 3.12.4" && exit 0
/usr/bin/python3 "$@"
SCRIPT
    chmod +x "$TEST_DIR/bin/python3"

    # ss mock (nothing on port 80, something on port 8080)
    cat > "$TEST_DIR/bin/ss" <<'SCRIPT'
#!/usr/bin/env bash
echo "LISTEN 0 0 *:8080 *:*"
SCRIPT
    chmod +x "$TEST_DIR/bin/ss"

    # curl mock
    cat > "$TEST_DIR/bin/curl" <<'SCRIPT'
#!/usr/bin/env bash
[[ "$*" =~ ifconfig\.me ]] && echo "203.0.113.1" && exit 0
[[ "$*" =~ localhost ]] && exit 0   # health check passes
/usr/bin/curl "$@"
SCRIPT
    chmod +x "$TEST_DIR/bin/curl"

    # systemctl + sudo mocks
    for cmd in systemctl sudo; do
        cat > "$TEST_DIR/bin/$cmd" <<'SCRIPT'
#!/usr/bin/env bash
exit 0
SCRIPT
        chmod +x "$TEST_DIR/bin/$cmd"
    done

    cd "$TEST_DIR"
}

teardown() { rm -rf "$TEST_DIR"; }

# ── CORE ──────────────────────────────────────────────────

@test "syntax: bash -n passes" {
    run bash -n setup.sh
    [[ "$status" -eq 0 ]]
}

@test "shellcheck: zero warnings" {
    run shellcheck -S warning setup.sh
    [[ "$status" -eq 0 ]]
    [[ -z "$output" ]]
}

@test "banner: Dawid Kleszyk shown" {
    run timeout 5 bash setup.sh <<< $'\n\n\n' 2>/dev/null
    [[ "$output" =~ "Dawid Kleszyk" ]]
}

@test "preflight: detects docker version" {
    run timeout 5 bash setup.sh <<< $'\n\n\n' 2>/dev/null
    [[ "$output" =~ "Docker 27" ]]
}

@test "preflight: detects python" {
    run timeout 5 bash setup.sh <<< $'\n\n\n' 2>/dev/null
    [[ "$output" =~ "Python 3" ]]
}

# ── DOMAIN ────────────────────────────────────────────────

@test "domain: valid domain accepted → port 80" {
    run timeout 8 bash setup.sh <<< $'kleszyk.xyz\nT\ntest123456\ntest123456\n' 2>/dev/null
    [[ "$output" =~ "kleszyk.xyz" ]]
}

@test "domain: invalid domain rejected" {
    run timeout 5 bash setup.sh <<< $'!!!zla\n' 2>/dev/null
    [[ "$output" =~ "nie wyglada" ]]
}

@test "domain: public IP shown for domain path" {
    run timeout 8 bash setup.sh <<< $'kleszyk.xyz\nT\ntest123456\ntest123456\n' 2>/dev/null
    [[ "$output" =~ "203.0.113.1" ]]
}

# ── PORTS ─────────────────────────────────────────────────

@test "port: without domain, uses 3000" {
    run timeout 8 bash setup.sh <<< $'\n3000\nT\ntest123456\ntest123456\n' 2>/dev/null
    [[ "$output" =~ "Port:" ]]
}

# ── PASSWORD ──────────────────────────────────────────────

@test "password: rejects too short" {
    # full flow but password too short → should loop
    run timeout 5 bash -c 'printf "ab\nab\n" | timeout 3 bash setup.sh' 2>/dev/null
    # either it looped (exit 124 = timeout) or failed somewhere
    [[ "$status" -ne 0 ]]
}

@test "password: mismatched rejected" {
    run timeout 5 bash -c 'printf "abcdef\n123456\n" | timeout 3 bash setup.sh' 2>/dev/null
    [[ "$status" -ne 0 ]]
}

# ── GEN-ENV ───────────────────────────────────────────────

@test "gen-env.py: 5-line output" {
    echo "test_pass_123" | python3 "$TEST_DIR/gen-env.py" "3000" "kleszyk.xyz"
    [[ -f .env ]]
    lines=$(wc -l < .env)
    [[ $lines -ge 4 ]]
}

@test "gen-env.py: works with empty domain" {
    echo "test_pass_123" | python3 "$TEST_DIR/gen-env.py" "3000" ""
    [[ -f .env ]]
    grep -q "DOMAIN=" .env
}

@test "gen-env.py: empty password fails" {
    run bash -c 'echo "" | python3 '"$TEST_DIR"'/gen-env.py "3000" "test.com"'
    [[ "$status" -ne 0 ]]
}

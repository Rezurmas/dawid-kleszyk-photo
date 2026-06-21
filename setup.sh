#!/usr/bin/env bash
set -euo pipefail

# ── kolory ─────────────────────────────────────────────
BOLD='\033[1m';    DIM='\033[2m'
GREEN='\033[0;32m'; YELLOW='\033[1;33m'
RED='\033[0;31m';   CYAN='\033[0;36m'
WHITE='\033[1;37m'; NC='\033[0m'

OK="${GREEN}✓${NC}";   ERR="${RED}✗${NC}"
WARN="${YELLOW}⚠${NC}"; DOT="${DIM}•${NC}"


# ── helpers ─────────────────────────────────────────────
section()  { echo ""; echo -e "  ${BOLD}${WHITE}$1${NC}"; }
step_ok()  { echo -e "    ${OK}  $1"; }
step_warn(){ echo -e "    ${WARN}  $1"; }
step_err() { echo -e "    ${ERR}  $1"; }
info()     { echo -e "    ${DIM}$1${NC}"; }

divider() {
    local w
    w=$(tput cols 2>/dev/null || echo 60)
    printf '  %*s\n' "$((w-2))" '' | tr ' ' '─'
}

health_check() {
    local url=$1 max=$2
    local start
    start=$(date +%s)
    while true; do
        if curl -sSo /dev/null "$url" 2>/dev/null; then
            return 0
        fi
        if (( $(date +%s) - start > max )); then
            return 1
        fi
        sleep 1
    done
}

# ── banner ──────────────────────────────────────────────
clear 2>/dev/null || true
echo ""
echo -e "  ${BOLD}${WHITE}╭────────────────────────────────────────────╮${NC}"
echo -e "  ${BOLD}${WHITE}│${NC}     ${BOLD}Dawid Kleszyk — Fotografia${NC}           ${BOLD}${WHITE}│${NC}"
echo -e "  ${BOLD}${WHITE}│${NC}     ${DIM}Instalator v2  •  Next.js + Docker${NC}     ${BOLD}${WHITE}│${NC}"
echo -e "  ${BOLD}${WHITE}╰────────────────────────────────────────────╯${NC}"
echo ""

# ── pre-flight ─────────────────────────────────────────
section "Pre-flight checks"

# system packages (curl, python3, iproute2 for ss)
info "Sprawdzam pakiety systemowe..."
missing=()
for pkg in curl python3 iproute2 ca-certificates ncurses-bin sudo; do
    if ! dpkg -s "$pkg" &>/dev/null && ! command -v "$pkg" &>/dev/null; then
        [[ "$pkg" == "iproute2" ]] && pkg_cmd="ss" || pkg_cmd="$pkg"
        if ! command -v "$pkg_cmd" &>/dev/null; then
            missing+=("$pkg")
        fi
    fi
done
if [[ ${#missing[@]} -gt 0 ]]; then
    info "Instaluje: ${missing[*]}..."
    apt-get update -qq && apt-get install -y -qq "${missing[@]}" 2>&1 | tail -1
    step_ok "Pakiety systemowe gotowe"
else
    step_ok "Pakiety systemowe OK"
fi

# docker
if command -v docker &>/dev/null; then
    step_ok "Docker $(docker --version | grep -oP '\d+\.\d+\.\d+')"
else
    info "Instaluje Docker + Compose..."
    curl -fsSL https://get.docker.com | sh 2>&1 | tail -3
    systemctl start docker 2>/dev/null || true
    if command -v docker &>/dev/null; then
        step_ok "Docker $(docker --version | grep -oP '\d+\.\d+\.\d+')"
    else
        step_err "Docker nie udalo sie zainstalowac"
        exit 1
    fi
fi

# compose
if docker compose version &>/dev/null; then
    step_ok "Docker Compose ✓"
else
    step_err "Docker Compose nie dziala"
    exit 1
fi

# python3
if command -v python3 &>/dev/null; then
    step_ok "Python $(python3 --version | awk '{print $2}')"
else
    step_err "python3 wymagany"
    exit 1
fi

# disk (min 2 GB free in cwd)
free_mb=$(df -m . | awk 'NR==2{print $4}')
if (( free_mb < 2048 )); then
    step_warn "Malo miejsca: ${free_mb} MB (min 2 GB)"
else
    step_ok "Dysk: ${free_mb} MB wolne"
fi

# port check helper — returns 0 (true) if port IS occupied
port_occupied() {
    ss -tlnp 2>/dev/null | grep -q ":${1} "
}

# ── domena ──────────────────────────────────────────────
section "Konfiguracja domeny"
echo ""
read -p "  Domena [np. kleszyk.xyz, Enter=pomin]: " DOMAIN

if [[ -n "$DOMAIN" ]]; then
    # basic domain validation
    dom_re='^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)+$'
    if [[ ! "$DOMAIN" =~ $dom_re ]]; then
        step_err "\"$DOMAIN\" nie wyglada na poprawna domene"
        exit 1
    fi
    PORT_VAL=80
    step_ok "Domena: ${GREEN}${DOMAIN}${NC} → port ${BOLD}80${NC}"

    # port 80 check
    if port_occupied 80; then
        step_warn "Port 80 jest juz zajety! Sprawdzam co na nim siedzi..."
        ss -tlnp 2>/dev/null | grep ':80 ' || true
        echo ""
        read -p "  Kontynuowac mimo to? [t/N]: " FORCE
        if [[ ! "$FORCE" =~ ^[tT]$ ]]; then
            echo -e "  ${ERR} Przerwane."
            exit 1
        fi
    fi

    # public IP
    PUBLIC_IP=$(curl -s4 --max-time 3 ifconfig.me 2>/dev/null \
             || curl -s4 --max-time 3 icanhazip.com 2>/dev/null \
             || echo "")
    if [[ -n "$PUBLIC_IP" ]]; then
        echo ""
        echo -e "  ${CYAN}╭─ DNS ──────────────────────────╮${NC}"
        echo -e "  ${CYAN}│${NC}  Rekord A  →  ${BOLD}${PUBLIC_IP}${NC}   ${CYAN}│${NC}"
        echo -e "  ${CYAN}│${NC}  @         →  ${BOLD}${PUBLIC_IP}${NC}   ${CYAN}│${NC}"
        echo -e "  ${CYAN}╰────────────────────────────────╯${NC}"
        echo ""
        info "Przekieruj tez port 80 na routerze → ten serwer"
    else
        step_warn "Nie moge wykryc zewnetrznego IP"
        info "Sprawdz recznie: curl ifconfig.me"
    fi
else
    read -p "  Port [3000]: " PORT_VAL
    PORT_VAL=${PORT_VAL:-3000}

    if port_occupied "$PORT_VAL"; then
        step_warn "Port ${PORT_VAL} jest zajety"
        ss -tlnp 2>/dev/null | grep ":${PORT_VAL} " || true
        read -p "  Inny port: " PORT_VAL
        PORT_VAL=${PORT_VAL:-3000}
    fi
    step_ok "Port: ${BOLD}${PORT_VAL}${NC}"
fi

# ── auto-start ──────────────────────────────────────────
section "Auto-start po restarcie"
echo ""
read -p "  Wlaczyc? [T/n]: " AUTOSTART
AUTOSTART=${AUTOSTART:-t}
if [[ "$AUTOSTART" =~ ^[tT]$ ]]; then
    if command -v systemctl &>/dev/null; then
        if sudo systemctl enable docker 2>/dev/null; then
            step_ok "Docker startuje przy boot"
        else
            step_warn "Uruchom recznie: sudo systemctl enable docker"
        fi
    else
        step_warn "Brak systemctl — pominiete"
    fi
else
    step_ok "Auto-start wylaczony"
fi

# ── haslo ───────────────────────────────────────────────
section "Haslo administratora"
echo ""
while true; do
    read -s -p "  Haslo (min 6 znakow): " PASSWORD
    echo ""
    if [[ ${#PASSWORD} -lt 6 ]]; then
        echo -e "    ${ERR}  Za krotkie (min 6)"
        continue
    fi
    read -s -p "  Powtorz:              " PASSWORD2
    echo ""
    if [[ "$PASSWORD" != "$PASSWORD2" ]]; then
        echo -e "    ${ERR}  Hasla sa rozne"
        continue
    fi
    break
done
step_ok "Haslo ustawione"

# ── cleanup starych ─────────────────────────────────────
section "Przygotowanie srodowiska"
if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "dawid"; then
    info "Zatrzymuje poprzednie kontenery..."
    docker compose down --remove-orphans 2>/dev/null || true
    step_ok "Stare kontenery usuniete"
fi

# ── generuj .env ────────────────────────────────────────
info "Generuje .env..."
# pass password via stdin so it never shows in ps
echo "$PASSWORD" | python3 gen-env.py "$PORT_VAL" "$DOMAIN"
step_ok ".env gotowe (5 zmiennych)"

# ── buduj + uruchom ─────────────────────────────────────
section "Budowa i uruchomienie"
echo ""

# RAM / swap check — Next.js build needs ~1.5GB+
ram_mb=$(free -m | awk '/Mem:/{print $7}')
swap_mb=$(free -m | awk '/Swap:/{print $3 + $4}')
if (( ram_mb < 1536 )) && (( swap_mb < 512 )); then
    step_warn "RAM: ${ram_mb}MB, Swap: ${swap_mb}MB — Next.js potrzebuje ~1.5GB"
    info "Tworze tymczasowy swap 2GB (potrzebne root)..."
    if [[ -f /swapfile ]]; then
        info "Swap juz istnieje, wlaczam..."
        swapon /swapfile 2>/dev/null || true
    else
        dd if=/dev/zero of=/swapfile bs=1M count=2048 status=none 2>/dev/null
        chmod 600 /swapfile
        mkswap /swapfile 2>/dev/null | tail -1
        swapon /swapfile 2>/dev/null
        echo "/swapfile none swap sw 0 0" >> /etc/fstab 2>/dev/null || true
        step_ok "Swap 2GB utworzony"
    fi
else
    step_ok "RAM: ${ram_mb}MB, Swap: ${swap_mb}MB — OK"
fi

BUILD_LOG=/tmp/dawid-build.log
docker compose up -d --build > "$BUILD_LOG" 2>&1 &
DOCKER_PID=$!

# unified progress: spinner chars + last build line
spinner_chars='◐◓◑◒'
si=0
while kill -0 $DOCKER_PID 2>/dev/null; do
    sleep 0.3
    last_line=$(tail -1 "$BUILD_LOG" 2>/dev/null | cut -c1-60)
    c="${spinner_chars:$si:1}"
    si=$(( (si + 1) % ${#spinner_chars} ))
    if [[ -n "$last_line" ]]; then
        printf "\r  ${CYAN}%s${NC} %-60s" "$c" "$last_line"
    else
        printf "\r  ${CYAN}%s${NC} %s" "$c" "Buduje obraz Docker..."
    fi
done

wait $DOCKER_PID 2>/dev/null
DOCKER_EXIT=$?
printf "\r%-60s\r" ""

if [[ $DOCKER_EXIT -eq 0 ]]; then
    BUILD_OK=254  # sentinel — docker nigdy nie zwraca 254
else
    BUILD_OK=$DOCKER_EXIT
fi

if [[ "$BUILD_OK" != "254" ]]; then
    step_err "Build sie nie udal. Log: $BUILD_LOG"
    echo ""
    tail -20 "$BUILD_LOG"
    exit 1
fi

step_ok "Kontener zbudowany i wystartowany"

# ── health check ────────────────────────────────────────
section "Sprawdzam czy strona zyje..."
echo ""

if [[ "$PORT_VAL" == "80" ]]; then
    HEALTH_URL="http://localhost"
else
    HEALTH_URL="http://localhost:${PORT_VAL}"
fi

if health_check "$HEALTH_URL" 15; then
    step_ok "Strona odpowiada — wszystko dziala!"
else
    step_warn "Strona nie odpowiada po 15s..."
    info "Logi: docker compose logs --tail=30"
    echo ""
    docker compose logs --tail=15 2>/dev/null || true
fi

# ── gotowe ──────────────────────────────────────────────
echo ""
echo -e "  ${BOLD}${WHITE}╭────────────────────────────────────────────╮${NC}"
echo -e "  ${BOLD}${WHITE}│${NC}              ${GREEN}Gotowe! ✓${NC}                    ${BOLD}${WHITE}│${NC}"
echo -e "  ${BOLD}${WHITE}╰────────────────────────────────────────────╯${NC}"
echo ""

if [[ -n "$DOMAIN" ]]; then
    echo -e "  ${DOT} Strona  ${GREEN}http://${DOMAIN}${NC}"
else
    echo -e "  ${DOT} Strona  ${GREEN}http://localhost:${PORT_VAL}${NC}"
fi
echo -e "  ${DOT} Admin   ${GREEN}/admin/login${NC}"
echo ""
divider
echo ""
echo -e "  ${DIM}Polecenia:${NC}"
echo -e "    stop   ${YELLOW}docker compose down${NC}"
echo -e "    logi   ${YELLOW}docker compose logs -f${NC}"
echo -e "    restart ${YELLOW}docker compose restart${NC}"
echo ""
divider
echo ""

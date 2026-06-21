#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${BOLD}   Dawid Kleszyk - Fotografia - Instalator${NC}"
echo -e "${BOLD}============================================${NC}"
echo ""

echo -e "${YELLOW}[1/5]${NC} Sprawdzam zaleznosci..."
if ! command -v docker &>/dev/null; then
    echo -e "${RED}[BLAD]${NC} Docker nie jest zainstalowany."
    echo "  Zainstaluj: https://docs.docker.com/engine/install/"
    exit 1
fi
if ! docker compose version &>/dev/null; then
    echo -e "${RED}[BLAD]${NC} Docker Compose nie jest dostepny."
    exit 1
fi
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}[BLAD]${NC} python3 nie jest zainstalowany."
    exit 1
fi
echo -e "  ${GREEN}OK${NC} Docker + Python3 gotowe"

echo ""
echo -e "${YELLOW}[2/5]${NC} Domena (opcjonalne)"
echo -e "  Jesli masz domene, strona pojdzie na porcie 80."
read -p "  Domena [np. kleszyk.xyz, Enter=pomin]: " DOMAIN
if [[ -n "$DOMAIN" ]]; then
    PORT_VAL=80
    echo -e "  ${GREEN}OK${NC} Domena: ${DOMAIN}, port 80"
    echo "  DNS: rekord A, @ -> IP serwera"
    PUBLIC_IP=$(curl -s4 ifconfig.me 2>/dev/null || curl -s4 icanhazip.com 2>/dev/null || echo "")
    if [[ -n "$PUBLIC_IP" ]]; then
        echo -e "  ${CYAN}IP serwera: ${BOLD}${PUBLIC_IP}${NC}"
    fi
else
    read -p "  Port [3000]: " PORT_VAL
    PORT_VAL=${PORT_VAL:-3000}
    echo -e "  ${GREEN}OK${NC} Port: ${PORT_VAL}"
fi

echo ""
echo -e "${YELLOW}[3/5]${NC} Auto-start"
read -p "  Wlaczyc auto-start po restarcie? [T/n]: " AUTOSTART
AUTOSTART=${AUTOSTART:-t}
if [[ "$AUTOSTART" =~ ^[tT]$ ]]; then
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable docker 2>/dev/null || echo "  UWAGA: sudo systemctl enable docker"
        echo -e "  ${GREEN}OK${NC} Docker wystartuje przy boot."
    fi
else
    echo -e "  ${YELLOW}UWAGA${NC} Auto-start pominiety."
fi

echo ""
echo -e "${YELLOW}[4/5]${NC} Haslo admina"
while true; do
    read -s -p "  Haslo (min 6): " PASSWORD
    echo ""
    if [[ ${#PASSWORD} -lt 6 ]]; then
        echo -e "  ${RED}✗${NC} Za krotkie."
        continue
    fi
    read -s -p "  Powtorz: " PASSWORD2
    echo ""
    if [[ "$PASSWORD" != "$PASSWORD2" ]]; then
        echo -e "  ${RED}✗${NC} Rozne."
        continue
    fi
    break
done
echo -e "  ${GREEN}OK${NC} Haslo ustawione."

echo ""
echo -e "${YELLOW}[5/5]${NC} Generuje .env..."
python3 gen-env.py "$PASSWORD" "$PORT_VAL" "$DOMAIN"
echo -e "  ${GREEN}OK${NC} .env gotowe."

echo ""
echo -e "${BOLD}Buduje i uruchamiam...${NC}"
docker compose up -d --build

echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${BOLD}   Gotowe!${NC}"
echo ""
if [[ -n "$DOMAIN" ]]; then
    echo -e "  Strona: ${GREEN}http://${DOMAIN}${NC}"
else
    echo -e "  Strona: ${GREEN}http://localhost:${PORT_VAL}${NC}"
fi
echo -e "  Admin:  ${GREEN}/admin/login${NC}"
echo ""
echo -e "  Zatrzymaj: ${YELLOW}docker compose down${NC}"
echo -e "  Logi:      ${YELLOW}docker compose logs -f${NC}"
echo -e "${BOLD}============================================${NC}"

#!/usr/bin/env bash
set -euo pipefail

# ─── Kolory ───
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# ─── Banner ───
echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${BOLD}   Dawid Kleszyk — Fotografia — Instalator${NC}"
echo -e "${BOLD}============================================${NC}"
echo ""

# ─── Sprawdź zależności ───
echo -e "${YELLOW}[1/5]${NC} Sprawdzam zależności..."

if ! command -v docker &>/dev/null; then
    echo -e "${RED}[BŁĄD]${NC} Docker nie jest zainstalowany."
    echo "  Zainstaluj: https://docs.docker.com/engine/install/"
    exit 1
fi

if ! docker compose version &>/dev/null; then
    echo -e "${RED}[BŁĄD]${NC} Docker Compose nie jest dostępny."
    exit 1
fi

echo -e "  ${GREEN}✓${NC} Docker: $(docker --version | head -1)"
echo -e "  ${GREEN}✓${NC} Docker Compose: $(docker compose version --short 2>/dev/null || echo 'OK')"

# ─── Domena ───
echo ""
echo -e "${YELLOW}[2/5]${NC} Konfiguracja domeny (opcjonalne)"
echo -e "  Jeśli masz domenę, strona będzie dostępna na porcie 80."
echo -e "  Jeśli nie — zostanie port 3000."
read -p "  Domena [np. kleszyk.xyz, lub Enter żeby pominąć]: " DOMAIN

if [[ -n "$DOMAIN" ]]; then
    PORT=80
    echo -e "  ${GREEN}✓${NC} Domena: ${DOMAIN}"
    echo -e "  ${GREEN}✓${NC} Port: 80 (standardowy HTTP)"
    echo ""
    echo -e "  ${CYAN}📋 DNS — skonfiguruj u swojego dostawcy domeny:${NC}"
    echo -e "     Typ:    ${BOLD}A${NC}"
    echo -e "     Nazwa:  ${BOLD}@${NC} (lub ${BOLD}${DOMAIN}${NC})"
    echo -e "     Wartość: ${BOLD}(adres IP tego serwera)${NC}"
    echo ""
    # Spróbuj wykryć zewnętrzny IP
    PUBLIC_IP=$(curl -s4 ifconfig.me 2>/dev/null || curl -s4 icanhazip.com 2>/dev/null || echo "NIEZNANY")
    if [[ "$PUBLIC_IP" != "NIEZNANY" ]]; then
        echo -e "  ${CYAN}  Twój zewnętrzny IP: ${BOLD}${PUBLIC_IP}${NC}"
    fi
    echo -e "  ${CYAN}  Po ustawieniu DNS strona będzie na: ${BOLD}http://${DOMAIN}${NC}"
else
    read -p "  Port [domyślnie: 3000]: " PORT
    PORT=${PORT:-3000}
    echo -e "  ${GREEN}✓${NC} Port: ${PORT}"
fi

# ─── Auto-start ───
echo ""
echo -e "${YELLOW}[3/5]${NC} Konfiguracja auto-startu"
read -p "  Włączyć automatyczne uruchamianie po restarcie serwera? [T/n]: " AUTOSTART
AUTOSTART=${AUTOSTART:-t}

if [[ "$AUTOSTART" =~ ^[tT]$ ]]; then
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable docker 2>/dev/null || echo -e "  ${YELLOW}⚠${NC} Uruchom ręcznie: sudo systemctl enable docker"
        echo -e "  ${GREEN}✓${NC} Docker włączy się automatycznie przy starcie systemu."
    else
        echo -e "  ${YELLOW}⚠${NC} Brak systemd — pomijam."
    fi
else
    echo -e "  ${YELLOW}⚠${NC} Auto-start pominięty."
fi

# ─── Hasło admina ───
echo ""
echo -e "${YELLOW}[4/5]${NC} Ustaw hasło do panelu admina"
while true; do
    read -s -p "  Hasło (min. 6 znaków): " PASSWORD
    echo ""
    if [[ ${#PASSWORD} -lt 6 ]]; then
        echo -e "  ${RED}✗${NC} Hasło musi mieć minimum 6 znaków."
        continue
    fi
    read -s -p "  Powtórz hasło: " PASSWORD2
    echo ""
    if [[ "$PASSWORD" != "$PASSWORD2" ]]; then
        echo -e "  ${RED}✗${NC} Hasła się nie zgadzają. Spróbuj ponownie."
        continue
    fi
    break
done
echo -e "  ${GREEN}✓${NC} Hasło ustawione."

# ─── Generuj .env ───
echo ""
echo -e "${YELLOW}[5/5]${NC} Generuję konfigurację..."

AUTH_SECRET=$(openssl rand -base64 32)

cat > .env << EOF
# ─── Wygenerowane automatycznie przez setup.sh ───
AUTH_SECRET=${AUTH...}
ADMIN...{PASSWORD}

# ─── Port ───
PORT=${PORT}

# ─── Domena ───
DOMAIN=${DOMAIN}
EOF

echo -e "  ${GREEN}✓${NC} Plik .env utworzony."

# ─── Buduj i uruchom ───
echo ""
echo -e "${BOLD}Buduję obraz Docker i uruchamiam kontener...${NC}"
echo ""

docker compose up -d --build

# ─── Podsumowanie ───
echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${BOLD}   Gotowe!${NC}"
echo ""

if [[ -n "$DOMAIN" ]]; then
    echo -e "  🌐 Strona:        ${GREEN}http://${DOMAIN}${NC}"
else
    echo -e "  🌐 Strona:        ${GREEN}http://localhost:${PORT}${NC}"
fi
echo -e "  🔐 Panel admina:  ${GREEN}/admin/login${NC}"
echo -e "  🔑 Hasło admina:  ${GREEN}${PASSWORD}${NC}"
echo ""
echo -e "  📁 Pliki:         ${BOLD}$(pwd)${NC}"
echo -e "  📦 Kontener:      ${BOLD}fotograf-portfolio${NC}"

if [[ "$AUTOSTART" =~ ^[tT]$ ]]; then
    echo -e "  🔄 Auto-start:    ${GREEN}włączony${NC} (przetrwa restart serwera)"
fi

echo ""
echo -e "  Zatrzymaj:        ${YELLOW}docker compose down${NC}"
echo -e "  Logi:             ${YELLOW}docker compose logs -f${NC}"
echo -e "  Restart po zmianach: ${YELLOW}docker compose up -d --build${NC}"

if [[ -n "$DOMAIN" ]]; then
    echo ""
    echo -e "  ${CYAN}⚠  Pamiętaj o skonfigurowaniu DNS (rekord A → IP serwera)!${NC}"
fi

echo -e "${BOLD}============================================${NC}"

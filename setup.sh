#!/usr/bin/env bash
set -euo pipefail

# ─── Kolory ───
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# ─── Banner ───
echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${BOLD}   Dawid Kleszyk — Fotografia — Instalator${NC}"
echo -e "${BOLD}============================================${NC}"
echo ""

# ─── Sprawdź zależności ───
echo -e "${YELLOW}[1/4]${NC} Sprawdzam zależności..."

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

# ─── Port ───
echo ""
echo -e "${YELLOW}[2/4]${NC} Konfiguracja portu"
read -p "  Port dla strony [domyślnie: 3000]: " PORT
PORT=${PORT:-3000}
echo -e "  ${GREEN}✓${NC} Port: ${PORT}"

# ─── Hasło admina ───
echo ""
echo -e "${YELLOW}[3/4]${NC} Ustaw hasło do panelu admina"
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
echo -e "${YELLOW}[4/4]${NC} Generuję konfigurację..."

AUTH_SECRET=$(openssl rand -base64 32)

cat > .env << EOF
# ─── Wygenerowane automatycznie ───
AUTH_SECRET=${AUTH...}
ADMIN...{PASSWORD}

# ─── Port ───
PORT=${PORT}
EOF

echo -e "  ${GREEN}✓${NC} Plik .env utworzony."
echo -e "  ${GREEN}✓${NC} docker-compose.yml zaktualizowany (port ${PORT})."

# ─── Buduj i uruchom ───
echo ""
echo -e "${BOLD}Buduję obraz Docker i uruchamiam kontener...${NC}"
echo ""

docker compose up -d --build

echo ""
echo -e "${BOLD}============================================${NC}"
echo -e "${BOLD}   Gotowe!${NC}"
echo ""
echo -e "  🌐 Strona:        ${GREEN}http://localhost:${PORT}${NC}"
echo -e "  🔐 Panel admina:  ${GREEN}http://localhost:${PORT}/admin/login${NC}"
echo -e "  🔑 Hasło admina:  ${GREEN}${PASSWORD}${NC}"
echo ""
echo -e "  📁 Pliki:         ${BOLD}$(pwd)${NC}"
echo -e "  📦 Kontener:      ${BOLD}fotograf-portfolio${NC}"
echo ""
echo -e "  Aby zatrzymać:    ${YELLOW}docker compose down${NC}"
echo -e "  Aby zobaczyć logi: ${YELLOW}docker compose logs -f${NC}"
echo -e "${BOLD}============================================${NC}"

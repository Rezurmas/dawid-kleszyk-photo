# Dawid Kleszyk — Fotografia

Strona portfolio w Next.js. Czarno-biały, ostry design (Flickr-inspired).

## Szybki start

```bash
git clone https://github.com/Rezurmas/dawid-kleszyk-photo.git
cd dawid-kleszyk-photo
chmod +x setup.sh
./setup.sh
```

Skrypt zapyta o:
- **Port** (domyślnie 3000)
- **Hasło admina** (do panelu `/admin`)

Reszta dzieje się automatycznie — generuje `.env`, buduje Dockera, odpala kontener.

## Ręczna instalacja

```bash
cp .env.example .env
# Edytuj .env: ustaw ADMIN_PASSWORD i AUTH_SECRET
# AUTH_SECRET wygeneruj: openssl rand -base64 32
docker compose up -d --build
```

## Strony

| Strona | Ścieżka |
|--------|---------|
| Home | `/` |
| Portfolio | `/portfolio` |
| O mnie | `/about` |
| Kontakt | `/contact` |
| Admin (login) | `/admin/login` |
| Admin (panel) | `/admin` |

## Zabezpieczenia

- Admin: hasło, httpOnly cookie, HMAC-SHA256
- Rate limit: 10 prób/5 min (tylko zewnętrzne IP)
- CSP, X-Frame-Options DENY, nosniff
- Upload: tylko JPG/PNG/WebP, max 10 MB

## Stack

Next.js 16 · Tailwind CSS 4 · TypeScript · Docker

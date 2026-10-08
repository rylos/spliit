# Deploy Spliit su NAS Synology

Guida completa: `DEPLOY-NAS.md` nella root del repo.

## Configurazione
- **NAS**: SSH `ssh -p 2222 marco@home.ziliani.net` (utente di sistema: Marco, sudo NOPASSWD)
- **Docker sul NAS**: `sudo /usr/local/bin/docker` (serve il percorso completo)
- **Stack manager**: Dockhand (Portainer non si usa più)
- **Stack**: `/volume1/docker/dockhand/stacks/NAS/spliit/docker-compose.yml`
- **Dati PostgreSQL 18**: `/volume1/docker/spliit` (montato su `/var/lib/postgresql`)
- **Container**: `spliit` (immagine `spliit:custom`, porta 3000), `spliit_db`
- **URL pubblico**: https://home.ziliani.net:3443/ (reverse proxy del NAS)

## Modifiche custom rispetto a upstream
1. **Footer nascosto**: CSS in `src/app/globals.css` (`/* Hide footer */`)
2. **HTTP Basic Auth**: `src/middleware.ts` (env `AUTH_USER` / `AUTH_PASSWORD`)

## File di deploy
- `compose.dockhand.yaml`: compose di riferimento con placeholder (`YOUR_DB_PASSWORD_HERE`, `YOUR_AUTH_USER`, `YOUR_AUTH_PASSWORD`)
- `deploy-nas.sh`: build `spliit:custom`, `docker save | ssh docker load`, tag `spliit:previous` per il rollback, `docker compose up -d` nello stack
- `.env.nas.example` / `.env.nas` (gitignored, opzionale): `NAS_HOST`, `NAS_PORT`, `NAS_USER`, `STACK_DIR`
- Le password reali stanno solo nel compose sul NAS

## Aggiornamento
```bash
git fetch upstream && git merge upstream/main
# Conflitti tipici: .env.example, .gitignore, globals.css, middleware.ts
# Backup DB se ci sono nuove migrazioni:
ssh -p 2222 marco@home.ziliani.net \
  'sudo /usr/local/bin/docker exec spliit_db pg_dump -U spliit spliit | gzip > /volume1/docker/spliit-backup/spliit-$(date +%F).sql.gz'
[ -f .env.nas ] && source .env.nas
./deploy-nas.sh   # richiede il daemon Docker locale attivo
```
Le migrazioni Prisma si applicano all'avvio del container.

## Rollback
```bash
ssh -p 2222 marco@home.ziliani.net '
  sudo /usr/local/bin/docker tag spliit:previous spliit:custom
  cd /volume1/docker/dockhand/stacks/NAS/spliit && sudo /usr/local/bin/docker compose up -d'
```

## Variabili runtime nel compose
`BASE_URL=https://home.ziliani.net:3443`, `DEFAULT_CURRENCY_CODE=EUR`, `AUTH_USER`, `AUTH_PASSWORD`, `POSTGRES_PRISMA_URL`, `POSTGRES_URL_NON_POOLING`, `TZ=Europe/Rome`

## Architettura
```
Internet → Reverse Proxy NAS (3443) → Spliit Container (3000) → PostgreSQL (5432)
```

# Deploy Spliit su NAS Synology

Stack gestito da **Dockhand**: `/volume1/docker/dockhand/stacks/NAS/spliit/docker-compose.yml`
Dati PostgreSQL: `/volume1/docker/spliit`

## Setup iniziale (una volta sola)

1. Crea le directory sul NAS:
   ```bash
   ssh -p 2222 marco@home.ziliani.net
   sudo mkdir -p /volume1/docker/spliit /volume1/docker/dockhand/stacks/NAS/spliit
   sudo chown Marco:users /volume1/docker/spliit
   ```
2. Copia `compose.dockhand.yaml` in `/volume1/docker/dockhand/stacks/NAS/spliit/docker-compose.yml`
   e sostituisci i placeholder (`YOUR_DB_PASSWORD_HERE`, `YOUR_AUTH_USER`, `YOUR_AUTH_PASSWORD`).
3. Esegui `./deploy-nas.sh` (build, upload e avvio dello stack).
4. In Dockhand: **Stacks → Import** → `/volume1/docker/dockhand/stacks/NAS/spliit`.

## Deploy / aggiornamento

```bash
# 1. Merge delle novità upstream
git fetch upstream && git merge upstream/main
# Conflitti tipici: .env.example, .gitignore, globals.css, middleware.ts

# 2. Backup del database (consigliato se ci sono nuove migrazioni in prisma/migrations)
ssh -p 2222 marco@home.ziliani.net \
  'sudo /usr/local/bin/docker exec spliit_db pg_dump -U spliit spliit | gzip > /volume1/docker/spliit-backup/spliit-$(date +%F).sql.gz'

# 3. Build + upload + restart stack (richiede il daemon Docker locale attivo)
[ -f .env.nas ] && source .env.nas
./deploy-nas.sh
```

Le migrazioni Prisma vengono applicate automaticamente all'avvio del container.
L'immagine precedente resta disponibile come `spliit:previous`.

### Rollback

```bash
ssh -p 2222 marco@home.ziliani.net '
  sudo /usr/local/bin/docker tag spliit:previous spliit:custom
  cd /volume1/docker/dockhand/stacks/NAS/spliit && sudo /usr/local/bin/docker compose up -d'
```

Se una migrazione ha modificato i dati, ripristina anche il dump del database.

## Configurazione runtime

Variabili nel compose (non serve ricostruire l'immagine per cambiarle):

- `BASE_URL` — URL pubblico (`https://home.ziliani.net:3443`)
- `DEFAULT_CURRENCY_CODE` — valuta predefinita dei nuovi gruppi (`EUR`)
- `AUTH_USER` / `AUTH_PASSWORD` — HTTP Basic Auth (middleware custom)
- Opzionali: `ENABLE_EXPENSE_DOCUMENTS`, `ENABLE_RECEIPT_EXTRACT`, `ENABLE_CATEGORY_EXTRACT`,
  `OPENAI_API_KEY` ecc. (vedi `.env.example`)

## Accesso

- **URL**: https://home.ziliani.net:3443/
- Credenziali: `AUTH_USER` / `AUTH_PASSWORD` dello stack

## Sicurezza

⚠️ Le password NON vanno su Git: `compose.dockhand.yaml` usa placeholder, le password reali
stanno solo nel compose sul NAS (ed eventualmente in `.env.nas`, gitignored).

## Comandi utili sul NAS

```bash
ssh -p 2222 marco@home.ziliani.net 'sudo /usr/local/bin/docker logs -f spliit'
ssh -p 2222 marco@home.ziliani.net 'sudo /usr/local/bin/docker restart spliit'
ssh -p 2222 marco@home.ziliani.net 'sudo /usr/local/bin/docker images | grep spliit'
```

## Architettura

```
Internet → Reverse Proxy NAS (3443) → Spliit Container (3000) → PostgreSQL (5432)
```

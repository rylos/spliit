# Deploy Spliit su NAS Synology

## Setup iniziale (una volta sola)

### 1. Crea directory sul NAS
```bash
ssh -p 2222 marco@home.ziliani.net
sudo mkdir -p /volume1/docker/spliit
sudo chown Marco:users /volume1/docker/spliit
exit
```

### 2. Configura credenziali locali
Crea il file `.env.nas` (già in .gitignore):
```bash
cp .env.nas.example .env.nas
nano .env.nas  # Inserisci le tue password
```

**Variabili da configurare:**
- `NAS_SUDO_PASSWORD`: password sudo del NAS
- `POSTGRES_PASSWORD`: password database PostgreSQL
- `AUTH_USER`: username per autenticazione web
- `AUTH_PASSWORD`: password per autenticazione web

## Deploy

### 1. Build e carica immagine

```bash
# Carica variabili d'ambiente
source .env.nas

# Esegui deploy
./deploy-nas.sh
```

### 2. Deploy con Portainer

1. Apri Portainer sul NAS
2. **Stacks > Add stack**
3. **Nome**: spliit
4. **Web editor**: copia il contenuto di `compose.portainer.yaml`
5. **Sostituisci i placeholder** con le password da `.env.nas`:
   - `YOUR_DB_PASSWORD_HERE` → valore di `POSTGRES_PASSWORD`
   - `YOUR_AUTH_USER` → valore di `AUTH_USER`
   - `YOUR_AUTH_PASSWORD` → valore di `AUTH_PASSWORD`
6. **Deploy the stack**

## Accesso

- **URL**: https://home.ziliani.net:3443/
- **Username**: (quello impostato in AUTH_USER)
- **Password**: (quella impostata in AUTH_PASSWORD)

> Il container espone la porta 3000, accessibile tramite reverse proxy su porta 3443

## Aggiornamento

```bash
# 1. Pull ultime modifiche da upstream
git pull upstream main

# 2. Risolvi conflitti se necessari (globals.css, middleware.ts)

# 3. Ricarica immagine
source .env.nas
./deploy-nas.sh

# 4. In Portainer: Update the stack (riavvia container)
```

## Sicurezza

⚠️ **IMPORTANTE**: Le password NON sono committate su Git!

- ✅ `.env.nas` contiene le password reali (gitignored)
- ✅ `.env.nas.example` è il template pubblico
- ✅ `compose.portainer.yaml` usa placeholder
- ✅ `deploy-nas.sh` legge password da variabili d'ambiente

**Non committare mai `.env.nas`!**

## Comandi utili sul NAS

```bash
# Logs
ssh -p 2222 marco@home.ziliani.net 'sudo /usr/local/bin/docker logs -f spliit'

# Restart (da Portainer o SSH)
source .env.nas
ssh -p 2222 marco@home.ziliani.net "echo '$NAS_SUDO_PASSWORD' | sudo -S /usr/local/bin/docker restart spliit"

# Lista immagini
ssh -p 2222 marco@home.ziliani.net 'sudo /usr/local/bin/docker images | grep spliit'
```

## Architettura

```
Internet → Reverse Proxy NAS (3443) → Spliit Container (3000) → PostgreSQL (5432)
```

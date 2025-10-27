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
5. **Sostituisci i placeholder** con le password reali:
   - `YOUR_DB_PASSWORD_HERE` → password PostgreSQL
   - `YOUR_AUTH_USER` → username autenticazione web
   - `YOUR_AUTH_PASSWORD` → password autenticazione web
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

## Comandi utili sul NAS

```bash
# Logs
ssh -p 2222 marco@home.ziliani.net 'sudo /usr/local/bin/docker logs -f spliit'

# Restart (da Portainer o SSH)
ssh -p 2222 marco@home.ziliani.net 'echo "YOUR_SUDO_PASSWORD" | sudo -S /usr/local/bin/docker restart spliit'

# Lista immagini
ssh -p 2222 marco@home.ziliani.net 'sudo /usr/local/bin/docker images | grep spliit'
```

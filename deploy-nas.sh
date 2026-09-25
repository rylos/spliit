#!/bin/bash
set -e

echo "🚀 Build e deploy Spliit su NAS Synology"

# Variabili
NAS_HOST="${NAS_HOST:-home.ziliani.net}"
NAS_PORT="${NAS_PORT:-2222}"
NAS_USER="${NAS_USER:-marco}"
STACK_DIR="${STACK_DIR:-/volume1/docker/dockhand/stacks/NAS/spliit}"
DOCKER=/usr/local/bin/docker

echo "📦 Build immagine Docker..."
docker build -t spliit:custom .

echo "📤 Upload e caricamento immagine su NAS..."
docker save spliit:custom | gzip | ssh -p "$NAS_PORT" "$NAS_USER@$NAS_HOST" "
  set -e
  # Conserva l'immagine attuale per un eventuale rollback
  sudo $DOCKER image inspect spliit:custom >/dev/null 2>&1 && sudo $DOCKER tag spliit:custom spliit:previous
  gunzip | sudo $DOCKER load
"

echo "🐳 Riavvio stack Dockhand..."
ssh -p "$NAS_PORT" "$NAS_USER@$NAS_HOST" "cd '$STACK_DIR' && sudo $DOCKER compose up -d"

echo "✅ Deploy completato! Log: ssh -p $NAS_PORT $NAS_USER@$NAS_HOST 'sudo $DOCKER logs -f spliit'"

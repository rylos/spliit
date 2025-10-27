#!/bin/bash
set -e

echo "🚀 Build e Upload Spliit su NAS Synology"

# Variabili
NAS_HOST="${NAS_HOST:-home.ziliani.net}"
NAS_PORT="${NAS_PORT:-2222}"
NAS_USER="${NAS_USER:-marco}"
NAS_SUDO_PASSWORD="${NAS_SUDO_PASSWORD:?Errore: imposta NAS_SUDO_PASSWORD}"

echo "📦 Build immagine Docker..."
docker build -t spliit:custom .

echo "💾 Salvataggio immagine..."
docker save spliit:custom | gzip > /tmp/spliit-custom.tar.gz

echo "📤 Upload su NAS..."
cat /tmp/spliit-custom.tar.gz | ssh -p $NAS_PORT $NAS_USER@$NAS_HOST "cat > /volume1/docker/spliit/spliit-custom.tar.gz"

echo "🐳 Caricamento immagine su Docker NAS..."
ssh -p $NAS_PORT $NAS_USER@$NAS_HOST << EOF
  cd /volume1/docker/spliit
  echo '$NAS_SUDO_PASSWORD' | sudo -S /usr/local/bin/docker load < /volume1/docker/spliit/spliit-custom.tar.gz
  rm /volume1/docker/spliit/spliit-custom.tar.gz
EOF

echo "✅ Immagine caricata con successo!"
echo "📋 Ora usa Portainer per deployare lo stack con compose.portainer.yaml"

# Pulizia locale
rm /tmp/spliit-custom.tar.gz

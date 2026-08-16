#!/usr/bin/env bash
# --------------------------------------------------
# scripts/02-configure-ubuntu.sh
# Configuração base da distribuição Ubuntu no WSL
# Execução: sudo ./02-configure-ubuntu.sh (ou via wsl -u root)
# --------------------------------------------------

set -e

export DEBIAN_FRONTEND=noninteractive

echo "========================================"
echo " [02/04] Configurando Sistema Ubuntu"
echo "========================================"

# Verificar permissão de root
if [ "$EUID" -ne 0 ]; then
  echo "[ERRO] Este script precisa ser executado como root (sudo)."
  exit 1
fi

# Remover preventivamente qualquer arquivo de repositório corrompido de execuções anteriores
rm -f /etc/apt/sources.list.d/gierens.list

echo -e "\n1. Atualizando repositórios e pacotes do sistema..."
apt-get update -y && apt-get upgrade -y

echo -e "\n2. Instalando utilitários essenciais..."
apt-get install -y \
  build-essential \
  curl \
  wget \
  git \
  ca-certificates \
  gnupg \
  lsb-release \
  unzip \
  zip \
  jq \
  software-properties-common \
  apt-transport-https \
  locales \
  sudo \
  htop \
  tree

echo -e "\n3. Configurando suporte a locales (en_US.UTF-8 e pt_BR.UTF-8)..."
locale-gen en_US.UTF-8 pt_BR.UTF-8
update-locale LANG=en_US.UTF-8

echo -e "\n4. Configurando /etc/wsl.conf..."
cat <<'EOF' > /etc/wsl.conf
[boot]
systemd=true

[automount]
enabled=true
options="metadata,uid=1000,gid=1000,umask=022,fmask=000"
mountFsTab=true

[interop]
enabled=true
appendWindowsPath=true
EOF

echo "   /etc/wsl.conf atualizado com systemd=true e automount otimizado."

echo -e "\n========================================"
echo " [SUCESSO] Passo 02 concluído!"
echo "========================================"

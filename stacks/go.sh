#!/usr/bin/env bash
# --------------------------------------------------
# stacks/go.sh
# Instalação da Stack Go (Golang) com suporte a Fish Shell
# --------------------------------------------------

set -e

echo -e "\n----------------------------------------"
echo " Instalando Stack Go (Golang)"
echo "----------------------------------------"

if ! command -v go &> /dev/null; then
  echo "1. Baixando e instalando a versão mais recente do Go..."
  GO_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
  echo "   Versão identificada: $GO_VERSION"

  wget -q "https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  rm -f /tmp/go.tar.gz
else
  echo "1. Go já está instalado: $(go version)"
fi

# Adicionar Go ao PATH no Bash e no Fish Shell
echo "2. Configurando variáveis de ambiente (GOPATH e PATH)..."
mkdir -p "$HOME/go/bin"

# Bash
ADD_PATH='export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin'
if ! grep -q '/usr/local/go/bin' "$HOME/.bashrc"; then
  echo "$ADD_PATH" >> "$HOME/.bashrc"
fi

# Fish Shell
FISH_CONF="$HOME/.config/fish/config.fish"
if [ -f "$FISH_CONF" ]; then
  if ! grep -q '/usr/local/go/bin' "$FISH_CONF"; then
    echo 'fish_add_path /usr/local/go/bin $HOME/go/bin' >> "$FISH_CONF"
  fi
fi

echo -e "\n[OK] Stack Go instalada com sucesso!"

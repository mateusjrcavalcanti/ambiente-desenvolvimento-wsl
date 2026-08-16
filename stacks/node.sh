#!/usr/bin/env bash
# --------------------------------------------------
# stacks/node.sh
# Instalação da Stack Node.js (NVM + Node LTS + Corepack) com suporte a Fish Shell
# --------------------------------------------------

set -e

echo -e "\n----------------------------------------"
echo " Instalando Stack Node.js (NVM + Node LTS)"
echo "----------------------------------------"

export NVM_DIR="$HOME/.nvm"

if [ ! -d "$NVM_DIR" ]; then
  echo "1. Instalando NVM (Node Version Manager)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Carregar NVM no bash atual para instalar a versão LTS
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if command -v nvm &> /dev/null; then
  echo "2. Instalando Node.js LTS..."
  nvm install --lts
  nvm use --lts
  nvm alias default 'lts/*'
  echo "   Node.js: $(node -v)"
  echo "   NPM: $(npm -v)"

  echo "3. Habilitando Corepack (PNPM / Yarn)..."
  corepack enable || true
else
  echo "[ERRO] Falha ao carregar o NVM."
  exit 1
fi

# Adicionar integração nativa para o Fish Shell
echo "4. Configurando integração com o Fish Shell..."
mkdir -p "$HOME/.config/fish/conf.d"
cat <<'EOF' > "$HOME/.config/fish/conf.d/nvm.fish"
# Suporte nativo ao Node.js / NVM no Fish Shell
if test -d "$HOME/.nvm/versions/node"
    set -l latest_node (ls -d $HOME/.nvm/versions/node/* 2>/dev/null | tail -n 1)
    if test -n "$latest_node"
        fish_add_path $latest_node/bin
    end
end
EOF

echo -e "\n[OK] Stack Node.js instalada com sucesso!"

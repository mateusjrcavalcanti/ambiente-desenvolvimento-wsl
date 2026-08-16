#!/usr/bin/env bash
# --------------------------------------------------
# stacks/base-fish.sh
# Instalação idempotente do Fish Shell, Starship Prompt e Tools Essentials
# --------------------------------------------------

set -e

echo -e "\n----------------------------------------"
echo " Configurando Fish Shell, Starship & Tools Essentials"
echo "----------------------------------------"

# Limpar qualquer lista de repositório corrompida de execuções anteriores
sudo rm -f /etc/apt/sources.list.d/gierens.list 2>/dev/null || true

# --------------------------------------------------
# 1. Instalar Fish Shell e pacotes base (se ausentes)
# --------------------------------------------------
if ! command -v fish &> /dev/null; then
  echo "1. Instalando Fish Shell e pacotes base..."
  sudo apt-get update -y
  sudo apt-get install -y software-properties-common wget curl git gpg
  sudo add-apt-repository -y ppa:fish-shell/release-3
  sudo apt-get update -y
  sudo apt-get install -y fish neovim fzf ripgrep fd-find bat htop
else
  echo "1. Fish Shell ja esta instalado: $(fish --version)"
  # Garantir ferramentas base leves
  sudo apt-get install -y neovim fzf ripgrep fd-find bat htop 2>/dev/null || true
fi

# Links simbólicos para ferramentas no ~/.local/bin
mkdir -p "$HOME/.local/bin"

if command -v fdfind &> /dev/null && [ ! -f "$HOME/.local/bin/fd" ]; then
  ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
fi

if command -v batcat &> /dev/null && [ ! -f "$HOME/.local/bin/bat" ]; then
  ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
fi

# --------------------------------------------------
# 2. Instalar eza (Substituto moderno do ls)
# --------------------------------------------------
if ! command -v eza &> /dev/null && [ ! -f "$HOME/.local/bin/eza" ] && [ ! -f "/usr/local/bin/eza" ]; then
  echo "2. Instalando eza (ls moderno com icones)..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null || true
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list 2>/dev/null || true
  sudo apt-get update -y || true
  sudo apt-get install -y eza || true

  # Fallback via GitHub Releases se apt falhar
  if ! command -v eza &> /dev/null; then
    echo "   Baixando binario oficial do eza via GitHub Releases..."
    wget -q https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz -O /tmp/eza.tar.gz || true
    if [ -f /tmp/eza.tar.gz ]; then
      tar -xzf /tmp/eza.tar.gz -C /tmp 2>/dev/null || true
      sudo mv /tmp/eza /usr/local/bin/eza 2>/dev/null || mv /tmp/eza "$HOME/.local/bin/eza" 2>/dev/null || true
      rm -f /tmp/eza.tar.gz
    fi
  fi
else
  echo "2. eza ja esta instalado."
fi

# --------------------------------------------------
# 3. Instalar zoxide (Navegação inteligente)
# --------------------------------------------------
if ! command -v zoxide &> /dev/null && [ ! -f "$HOME/.local/bin/zoxide" ]; then
  echo "3. Instalando zoxide..."
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash || sudo apt-get install -y zoxide || true
else
  echo "3. zoxide ja esta instalado."
fi

# --------------------------------------------------
# 4. Instalar mise (Gerenciador universal de versões)
# --------------------------------------------------
if ! command -v mise &> /dev/null && [ ! -f "$HOME/.local/bin/mise" ] && [ ! -f "$HOME/.local/share/mise/bin/mise" ]; then
  echo "4. Instalando mise..."
  curl https://mise.run | sh || true
else
  echo "4. mise ja esta instalado."
fi

# --------------------------------------------------
# 5. Instalar Starship Prompt
# --------------------------------------------------
if ! command -v starship &> /dev/null; then
  echo "5. Instalando Starship Prompt..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
else
  echo "5. Starship Prompt ja esta instalado: $(starship --version | head -n 1)"
fi

# --------------------------------------------------
# 6. Configurar ~/.config/fish/config.fish
# --------------------------------------------------
echo "6. Verificando configuracoes do Fish Shell (~/.config/fish/config.fish)..."
mkdir -p "$HOME/.config/fish"
FISH_CONF="$HOME/.config/fish/config.fish"

if [ ! -f "$FISH_CONF" ]; then
  touch "$FISH_CONF"
fi

if ! grep -q 'fish_add_path $HOME/.local/bin' "$FISH_CONF"; then
  echo 'fish_add_path $HOME/.local/bin' >> "$FISH_CONF"
fi

if ! grep -q 'fish_add_path $HOME/.local/share/mise/bin' "$FISH_CONF"; then
  echo 'fish_add_path $HOME/.local/share/mise/bin' >> "$FISH_CONF"
fi

if ! grep -q 'starship init fish' "$FISH_CONF"; then
  echo -e '\n# Starship Prompt\nstarship init fish | source' >> "$FISH_CONF"
fi

if ! grep -q 'zoxide init fish' "$FISH_CONF"; then
  echo -e '\n# Zoxide Navigation\nzoxide init fish | source' >> "$FISH_CONF"
fi

if ! grep -q 'mise activate fish' "$FISH_CONF"; then
  echo -e '\n# Mise Version Manager\nmise activate fish | source' >> "$FISH_CONF"
fi

if ! grep -q 'alias ls=' "$FISH_CONF"; then
  cat <<'EOF' >> "$FISH_CONF"

# Aliases do eza
alias ls='eza --icons=always'
alias lz='eza --color=always --long --no-filesize --icons=always --no-time'
alias ll='eza -l --icons=always'
alias la='eza -la --icons=always'
alias lt='eza --tree --icons=always'
EOF
fi

# --------------------------------------------------
# 7. Copiar starship-config-example.toml para ~/.config/starship.toml
# --------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$SCRIPT_DIR/config/starship-config-example.toml" ]; then
  mkdir -p "$HOME/.config"
  cp "$SCRIPT_DIR/config/starship-config-example.toml" "$HOME/.config/starship.toml"
elif [ -f "$SCRIPT_DIR/starship-config-example.toml" ]; then
  mkdir -p "$HOME/.config"
  cp "$SCRIPT_DIR/starship-config-example.toml" "$HOME/.config/starship.toml"
fi

# --------------------------------------------------
# 8. Definir Fish Shell como Shell Padrão
# --------------------------------------------------
FISH_PATH="$(which fish 2>/dev/null || echo '/usr/bin/fish')"
CURRENT_SHELL="$(getent passwd "$USER" | cut -d: -f7 2>/dev/null || echo "$SHELL")"

if [ -n "$FISH_PATH" ] && [ "$CURRENT_SHELL" != "$FISH_PATH" ]; then
  echo "7. Alterando shell padrao para o Fish Shell..."
  sudo chsh -s "$FISH_PATH" "$USER" || chsh -s "$FISH_PATH" || true
else
  echo "7. Fish Shell ja e o shell padrao."
fi

echo -e "\n[OK] Fish Shell, Starship Prompt e Tools Essentials prontos!"

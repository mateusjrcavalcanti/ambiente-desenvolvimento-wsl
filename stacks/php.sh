#!/usr/bin/env bash
# --------------------------------------------------
# stacks/php.sh
# Instalação da Stack PHP, Laravel & Laravel Sail
# --------------------------------------------------

set -e

echo -e "\n----------------------------------------"
echo " Instalando Stack PHP, Laravel & Laravel Sail"
echo "----------------------------------------"

echo "1. Instalando PHP e extensões necessárias para o Laravel..."
sudo apt-get update -y
sudo apt-get install -y \
  php-cli \
  php-curl \
  php-mbstring \
  php-xml \
  php-zip \
  php-mysql \
  php-sqlite3 \
  php-gd \
  php-intl \
  php-bcmath \
  sqlite3 \
  unzip \
  git

echo "   PHP versão: $(php -v | head -n 1)"

# 2. Instalar Composer
if ! command -v composer &> /dev/null; then
  echo "2. Instalando Composer..."
  curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
else
  echo "2. Composer já está instalado."
fi

echo "   Composer versão: $(composer --version | head -n 1)"

# 3. Instalar Laravel Installer CLI globalmente
echo "3. Instalando o Laravel Installer CLI..."
composer global require laravel/installer || true

# 4. Configurar PATH do Composer no Fish Shell e Bash
COMPOSER_BIN="$HOME/.config/composer/vendor/bin"
mkdir -p "$COMPOSER_BIN"

# Bash
if ! grep -q 'composer/vendor/bin' "$HOME/.bashrc"; then
  echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> "$HOME/.bashrc"
fi

# Fish Shell
FISH_CONF="$HOME/.config/fish/config.fish"
if [ -f "$FISH_CONF" ]; then
  if ! grep -q 'composer/vendor/bin' "$FISH_CONF"; then
    echo 'fish_add_path $HOME/.config/composer/vendor/bin' >> "$FISH_CONF"
  fi
fi

# 5. Configurar alias universal para Laravel Sail
echo "4. Configurando alias do Laravel Sail (sail)..."

# Bash
if ! grep -q "alias sail=" "$HOME/.bashrc"; then
  echo "alias sail='[ -f sail ] && sh sail || ./vendor/bin/sail'" >> "$HOME/.bashrc"
fi

# Fish Shell
if [ -f "$FISH_CONF" ]; then
  if ! grep -q "alias sail=" "$FISH_CONF"; then
    echo "alias sail='[ -f sail ] && sh sail || ./vendor/bin/sail'" >> "$FISH_CONF"
  fi
fi

echo -e "\n[OK] Stack PHP, Laravel & Sail configurada com sucesso!"
echo "     - Criar novo projeto: laravel new meu-projeto"
echo "     - Executar Laravel Sail: sail up"

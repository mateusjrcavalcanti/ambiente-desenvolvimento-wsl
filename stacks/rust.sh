#!/usr/bin/env bash
# --------------------------------------------------
# stacks/rust.sh
# Instalação da Stack Rust (Rustup + Cargo) com suporte a Fish Shell
# --------------------------------------------------

set -e

echo -e "\n----------------------------------------"
echo " Instalando Stack Rust (Rustup + Cargo)"
echo "----------------------------------------"

if [ ! -d "$HOME/.cargo" ]; then
  echo "1. Instalando Rust via rustup (modo não-interativo)..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
  echo "1. Rustup já instalado. Atualizando..."
  "$HOME/.cargo/bin/rustup" update || true
fi

# Configurar PATH no Fish Shell
FISH_CONF="$HOME/.config/fish/config.fish"
if [ -f "$FISH_CONF" ]; then
  if ! grep -q 'cargo/bin' "$FISH_CONF"; then
    echo 'fish_add_path $HOME/.cargo/bin' >> "$FISH_CONF"
  fi
fi

echo -e "\n[OK] Stack Rust instalada com sucesso!"

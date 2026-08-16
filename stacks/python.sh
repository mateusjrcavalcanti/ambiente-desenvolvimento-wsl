#!/usr/bin/env bash
# --------------------------------------------------
# stacks/python.sh
# Instalação da Stack Python (Python 3, pip, venv, uv)
# --------------------------------------------------

set -e

echo -e "\n----------------------------------------"
echo " Instalando Stack Python (Python 3, pip, venv, uv)"
echo "----------------------------------------"

echo "1. Instalando pacotes do Python..."
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip python3-venv python3-full

echo "   Python versão: $(python3 --version)"

echo "2. Instalando uv (gerenciador ultrarrápido de pacotes/ambientes Python)..."
if ! command -v uv &> /dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh || true
fi

echo -e "\n[OK] Stack Python instalada com sucesso!"

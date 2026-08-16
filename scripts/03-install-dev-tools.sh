#!/usr/bin/env bash
# --------------------------------------------------
# scripts/03-install-dev-tools.sh
# Script interativo principal para instalação de Dev Tools, Fish Shell & Stacks
# --------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACKS_DIR="$(cd "$SCRIPT_DIR/../stacks" && pwd)"

echo "========================================"
echo " [03/04] Instalando Ferramentas de Dev"
echo "========================================"

# --------------------------------------------------
# 1. SEMPRE executar a base (Fish Shell + Starship + Tools Essentials)
# --------------------------------------------------
if [ -f "$STACKS_DIR/base-fish.sh" ]; then
  bash "$STACKS_DIR/base-fish.sh"
else
  echo "[ERRO] Script de base $STACKS_DIR/base-fish.sh não encontrado."
  exit 1
fi

# --------------------------------------------------
# 2. Processar Stacks de Linguagem
# --------------------------------------------------

run_stack() {
  local stack_name="$1"
  local stack_script="$STACKS_DIR/$stack_name.sh"

  if [ -f "$stack_script" ]; then
    bash "$stack_script"
  else
    echo "[AVISO] Script da stack '$stack_name' não encontrado em $stack_script."
  fi
}

CHOICES=""

# Verificar se foram passados argumentos via linha de comando
if [ "$#" -gt 0 ]; then
  for arg in "$@"; do
    case "$arg" in
      --all|all|A|a)
        CHOICES="1,2,3,4,5"
        ;;
      node|1) CHOICES="$CHOICES,1" ;;
      python|2) CHOICES="$CHOICES,2" ;;
      go|3) CHOICES="$CHOICES,3" ;;
      rust|4) CHOICES="$CHOICES,4" ;;
      php|5) CHOICES="$CHOICES,5" ;;
    esac
  done
fi

# Se não foram informadas escolhas por parâmetro e temos TTY disponível
if [ -z "$CHOICES" ] && { [ -t 0 ] || [ -c /dev/tty ]; }; then
  echo ""
  echo "=================================================="
  echo " SELEÇÃO DE STACKS DE DESENVOLVIMENTO"
  echo "=================================================="
  echo "Quais stacks você deseja instalar no seu ambiente?"
  echo ""
  echo "  [1] Node.js (NVM, Node LTS, Corepack, PNPM, Yarn)"
  echo "  [2] Python  (Python 3, pip, venv, uv)"
  echo "  [3] Go      (Golang)"
  echo "  [4] Rust    (Rustup, Cargo)"
  echo "  [5] PHP & Laravel (PHP CLI, Extensões Laravel, Composer, Laravel Installer)"
  echo "  [A] TODAS AS STACKS ACIMA"
  echo "  [N] Nenhuma adicional (apenas Fish + Starship + Tools Essentials: Neovim, mise, eza, zoxide, fzf)"
  echo ""
  
  if [ -c /dev/tty ]; then
    read -p "Sua escolha (ex: 1,2,4 ou A / N) [Padrão: A]: " INPUT_CHOICE < /dev/tty
  else
    read -p "Sua escolha (ex: 1,2,4 ou A / N) [Padrão: A]: " INPUT_CHOICE
  fi

  if [ -z "$INPUT_CHOICE" ]; then
    INPUT_CHOICE="A"
  fi

  CHOICES="$INPUT_CHOICE"
elif [ -z "$CHOICES" ]; then
  # Modo não-interativo sem parâmetros: padrão instala Node e Python
  echo "[INFO] Executando em modo automático não-interativo. Instalando Node.js e Python..."
  CHOICES="1,2"
fi

# Normalizar escolhas
case "$CHOICES" in
  *A*|*a*|*all*)
    run_stack "node"
    run_stack "python"
    run_stack "go"
    run_stack "rust"
    run_stack "php"
    ;;
  *N*|*n*)
    echo "Nenhuma stack adicional selecionada."
    ;;
  *)
    [[ "$CHOICES" =~ 1 ]] && run_stack "node"
    [[ "$CHOICES" =~ 2 ]] && run_stack "python"
    [[ "$CHOICES" =~ 3 ]] && run_stack "go"
    [[ "$CHOICES" =~ 4 ]] && run_stack "rust"
    [[ "$CHOICES" =~ 5 ]] && run_stack "php"
    ;;
esac

echo -e "\n========================================"
echo " [SUCESSO] Passo 03 concluído!"
echo "========================================"

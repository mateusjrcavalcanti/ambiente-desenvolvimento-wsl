# 🚀 Ambiente de Desenvolvimento WSL 2 + Ubuntu

[![WSL 2](https://img.shields.io/badge/WSL-2-blue.svg?logo=windows&logoColor=white)](https://learn.microsoft.com/windows/wsl/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420.svg?logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Shell](https://img.shields.io/badge/Shell-Fish_3-4E9A06.svg?logo=fishshell&logoColor=white)](https://fishshell.com/)
[![Prompt](https://img.shields.io/badge/Prompt-Starship-DD0B78.svg?logo=starship&logoColor=white)](https://starship.rs/)
[![Docker](https://img.shields.io/badge/Docker-WSL_Integration-2496ED.svg?logo=docker&logoColor=white)](https://www.docker.com/)

Orquestrador automatizado para provisionamento e configuração de um **Ambiente de Desenvolvimento Moderno, Produtivo e Completo** no Windows utilizando **WSL 2 (Ubuntu)**, **Fish Shell**, **Starship Prompt**, utilitários CLI de última geração e **Stacks de Linguagens de Programação** personalizáveis.


## 📋 Resumo do Projeto

Este repositório fornece uma solução automatizada em 4 etapas para transformar um ambiente Windows limpo em um ambiente de desenvolvimento Linux completo de alta performance. Com apenas um comando (`.\up.ps1`), o script cuida de toda a elevação de privilégios Administrador, instalação das dependências no Windows, preparação da distribuição Ubuntu no WSL, instalação de ferramentas CLI e setup das stacks escolhidas.

### 🌟 O que é instalado e configurado?

- **WSL 2 & Ubuntu 24.04 LTS**: Instalação, atualização do Kernel WSL e otimização do `/etc/wsl.conf` (Systemd ativado, automount configurado e suporte a UTF-8).
- **Ferramentas Windows & Fontes**: Instalação do Microsoft PowerToys, Windows Terminal e download automático da **MesloLGS Nerd Font** (essencial para ícones do terminal).
- **Fish Shell & Starship Prompt**: Shell rápido e inteligente com auto-completar preditivo, destaques de sintaxe, integração universal de PATH e prompt customizado com ícones e status de Git/Stacks.
- **Tools Essentials (Utilitários CLI)**:
  - `eza`: Substituto moderno e colorido do `ls` com ícones.
  - `zoxide`: Navegação inteligente de diretórios (`z <pasta>`).
  - `mise`: Gerenciador universal de versões e ambientes.
  - `neovim`: Editor de texto moderno em terminal.
  - `fzf`, `ripgrep`, `fd`, `bat`, `htop`, `tree`, `jq`, `build-essential`.
- **Integração com Docker**: Ajuste de permissões de grupo `docker` dentro da distribuição Ubuntu para uso sem `sudo`.
- **Stacks de Desenvolvimento (Seleção Interativa)**:
  - 🟢 **Node.js**: NVM (Node Version Manager), Node.js LTS, Corepack (PNPM, Yarn).
  - 🟡 **Python**: Python 3, pip, venv e `uv` (gerenciador ultrarrápido).
  - 🔷 **Go**: Golang atualizado via go.dev e variáveis de ambiente (GOPATH/PATH).
  - 🦀 **Rust**: Rustup, Cargo e integração nativa de PATH.
  - 🐘 **PHP & Laravel**: PHP CLI, extensões para Laravel, Composer, Laravel Installer CLI e alias `sail`.


## 📁 Estrutura do Repositório

```
ambiente-desenvolvimento-wsl/
├── up.ps1                                # Orquestrador principal PowerShell (ponto de entrada)
├── scripts/
│   ├── 01-install-wsl.ps1               # Configura WSL 2, Ubuntu, PowerToys, Fonts & Terminal
│   ├── 02-configure-ubuntu.sh           # Configuração base root no Ubuntu (systemd, apt, locales)
│   ├── 03-install-dev-tools.sh          # Instala Fish, Starship, CLI tools e menu de Stacks
│   └── 04-configure-docker.ps1          # Configura grupo docker e integração no WSL
├── stacks/
│   ├── base-fish.sh                     # Base essencial (Fish Shell, Starship, eza, zoxide, mise, etc)
│   ├── node.sh                          # Setup da stack Node.js / NVM / Corepack
│   ├── python.sh                        # Setup da stack Python 3 / uv
│   ├── go.sh                            # Setup da stack Golang
│   ├── rust.sh                          # Setup da stack Rust / Cargo
│   └── php.sh                           # Setup da stack PHP / Composer / Laravel / Sail
└── config/
    ├── starship-config-example.toml     # Exemplo de configuração do Starship Prompt
    └── windows-terminal-settings-example.json # Perfil de configurações do Windows Terminal
```


## ⚡ Como Usar

### 1. Pré-requisitos
- Sistema Operacional: **Windows 10 (versão 2004+) ou Windows 11**.
- Conexão com a Internet.
- Execução no PowerShell (não é necessário abrir como Administrador previamente, o script solicitará elevação UAC automaticamente caso necessário).

> [!TIP]
> Caso a execução de scripts esteja desabilitada no seu PowerShell, libere temporariamente antes de rodar o comando:
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
> ```

### 2. Execução Automática (Recomendado)

Abra o PowerShell na pasta do repositório e execute:

```powershell
.\up.ps1
```

O orquestrador executará a sequência completa:
1. **Passo 1**: Valida/Instala o WSL 2, baixa a Nerd Font e configura o Windows Terminal.
2. **Passo 2**: Atualiza os pacotes do Ubuntu, ativa `systemd` e ajusta os locales.
3. **Passo 3**: Instala o Fish Shell, Starship e exibe o menu interativo para escolha das stacks de linguagem.
4. **Passo 4**: Adiciona o usuário do Ubuntu ao grupo `docker`.


## 🛠️ Modos de Instalação das Stacks

Durante o **Passo 03**, você pode selecionar quais linguagens deseja provisionar no ambiente:

```text
==================================================
 SELEÇÃO DE STACKS DE DESENVOLVIMENTO
==================================================
  [1] Node.js (NVM, Node LTS, Corepack, PNPM, Yarn)
  [2] Python  (Python 3, pip, venv, uv)
  [3] Go      (Golang)
  [4] Rust    (Rustup, Cargo)
  [5] PHP & Laravel (PHP CLI, Extensões Laravel, Composer, Laravel Installer)
  [A] TODAS AS STACKS ACIMA
  [N] Nenhuma adicional (apenas Fish + Starship + Tools Essentials)
```

### Execução Não-Interativa via Terminal Linux
Se quiser rodar o script de ferramentas individualmente com opções por linha de comando:

```bash
# Instalar todas as stacks
./scripts/03-install-dev-tools.sh --all

# Instalar apenas Node.js e Python
./scripts/03-install-dev-tools.sh node python

# Instalar apenas Go e Rust
./scripts/03-install-dev-tools.sh go rust
```


## 🧰 Utilitários e Atalhos Pré-configurados

No **Fish Shell**, diversos aliases e atalhos já vêm ativados de fábrica:

| Comando | Descrição | Ferramenta Subjacente |
| :--- | :--- | :--- |
| `ls` | Listagem moderna com ícones | `eza --icons=always` |
| `ll` | Listagem em formato detalhado (long format) | `eza -l --icons=always` |
| `la` | Listagem incluindo arquivos ocultos | `eza -la --icons=always` |
| `lt` | Exibe a estrutura de diretórios em árvore | `eza --tree --icons=always` |
| `z <pasta>` | Navegação rápida por histórico inteligente | `zoxide` |
| `bat <file>` | Exibição de arquivos com syntax highlighting | `batcat` |
| `fd <busca>` | Busca rápida e intuitive de arquivos | `fd-find` |
| `rg <termo>` | Busca ultrarrápida de conteúdo em arquivos | `ripgrep` |
| `sail` | Executa o Laravel Sail no projeto atual | `./vendor/bin/sail` |


## 🐳 Configuração do Docker Desktop

Após a conclusão da instalação:
1. Abra o **Docker Desktop** no Windows.
2. Acesse **Settings (Engrenagem) ⚙️ -> Resources -> WSL Integration**.
3. Certifique-se de que a opção **Use the WSL 2 based engine** está marcada.
4. Ative o toggle para a sua distribuição (**Ubuntu-24.04** ou **Ubuntu**).
5. Clique em **Apply & restart**.

> [!NOTE]
> O script adiciona automaticamente o seu usuário ao grupo `docker` no Ubuntu, permitindo executar comandos como `docker ps` e `docker compose` sem precisar de `sudo`.


## 🎨 Personalização do Terminal e Prompt

- **Starship Prompt**: A configuração utilizada pode ser consultada ou alterada em `~/.config/starship.toml` (o modelo base fica disponível em `config/starship-config-example.toml`).
- **Fonte**: A fonte **MesloLGS Nerd Font** é instalada no Windows para renderizar corretamente ícones de Git, pastas e linguagens no terminal.


## ❓ Solução de Problemas (Troubleshooting)

<details>
<summary><b>1. O PowerShell bloqueia a execução do script (ExecutionPolicy)</b></summary>

Execute o seguinte comando no PowerShell antes de chamar o `.\up.ps1`:
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```
</details>

<details>
<summary><b>2. O WSL precisa ser reiniciado para aplicar as configurações de systemd</b></summary>

No PowerShell do Windows, encerre a instância do WSL com:
```powershell
wsl --shutdown
```
Em seguida, abra o terminal novamente digitando `wsl`.
</details>

<details>
<summary><b>3. O comando <code>docker</code> pede <code>sudo</code> dentro do Ubuntu</b></summary>

Execute a atualização do grupo no WSL manualmente se necessário:
```bash
sudo usermod -aG docker $USER
```
E feche/reabra o terminal.
</details>
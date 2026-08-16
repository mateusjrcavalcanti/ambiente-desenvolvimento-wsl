# --------------------------------------------------
# up.ps1
# Orquestrador principal da instalação do ambiente de desenvolvimento WSL
# Executa em sequência:
#   scripts/01-install-wsl.ps1
#   scripts/02-configure-ubuntu.sh
#   scripts/03-install-dev-tools.sh
#   scripts/04-configure-docker.ps1
# --------------------------------------------------

$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$PSScriptDir = $PSScriptRoot
if (-not $PSScriptDir) {
    $PSScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
}

# Função utilitária para garantir alinhamento perfeito na margem esquerda (coluna 0) em qualquer terminal
function Out-CleanHost {
    param([string]$Text, [ConsoleColor]$ForegroundColor)
    $esc = [char]27
    [Console]::Write("`r$esc[1G")
    try {
        if ([System.Console]::CursorLeft -gt 0) {
            [System.Console]::SetCursorPosition(0, [System.Console]::CursorTop)
        }
    }
    catch {
        # Ignorar exceção em consoles sem buffer interativo
    }
    if ($ForegroundColor) {
        Write-Host $Text -ForegroundColor $ForegroundColor
    }
    else {
        Write-Host $Text
    }
    [Console]::Write("`r$esc[1G")
}

# Função utilitária para conversão confiável de caminho do Windows para o WSL
function Get-WslPath {
    param ([string]$winPath)
    if ($winPath -match '^([a-zA-Z]):\\(.*)$') {
        $drive = $Matches[1].ToLower()
        $relativePath = $Matches[2].Replace("\", "/")
        return "/mnt/$drive/$relativePath"
    }
    return $winPath.Replace("\", "/")
}

# Função utilitária para detectar dinamicamente o nome da distribuição Ubuntu instalada
function Get-UbuntuDistro {
    $installedDistros = @(
        wsl.exe --list --quiet 2>$null | ForEach-Object { $_.Trim().Replace("`0", "") } | Where-Object { $_ -ne "" }
    )
    $ubuntu = $installedDistros | Where-Object { $_ -like "Ubuntu*" } | Select-Object -First 1
    if (-not $ubuntu) { return "Ubuntu-24.04" }
    return $ubuntu
}

Out-CleanHost ""
Out-CleanHost "==================================================" -ForegroundColor Cyan
Out-CleanHost "   CONFIGURACAO COMPLETA DO AMBIENTE DE DEV WSL   " -ForegroundColor Cyan
Out-CleanHost "==================================================" -ForegroundColor Cyan
Out-CleanHost ""

# --------------------------------------------------
# Auto-elevação de privilégios de Administrador
# --------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    try {
        Out-CleanHost "Solicitando privilegios de Administrador (UAC)..." -ForegroundColor Yellow
        $scriptPath = $MyInvocation.MyCommand.Definition
        if (-not $scriptPath) { $scriptPath = $PSCommandPath }

        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$scriptPath`"" -ErrorAction Stop
        exit 0
    }
    catch {
        Out-CleanHost "[ERRO] Nao foi possivel abrir janela com elevacao de Administrador." -ForegroundColor Red
        Out-CleanHost "Por favor, abra o PowerShell como Administrador manualmente." -ForegroundColor Yellow
        exit 1
    }
}

# --------------------------------------------------
# PASSO 1: Instalação do WSL 2, Ubuntu & Ferramentas Windows
# --------------------------------------------------
$step1Path = Join-Path $PSScriptDir "scripts\01-install-wsl.ps1"
if (Test-Path $step1Path) {
    Out-CleanHost ""
    Out-CleanHost ">>> Executando 01-install-wsl.ps1..." -ForegroundColor Cyan
    & $step1Path
    if ($LASTEXITCODE -ne 0) {
        Out-CleanHost "[ERRO] Falha na execucao do Passo 01." -ForegroundColor Red
        exit $LASTEXITCODE
    }
}
else {
    Out-CleanHost "[ERRO] Arquivo 01-install-wsl.ps1 nao encontrado em scripts/." -ForegroundColor Red
    exit 1
}

# --------------------------------------------------
# PASSO 2: Configuração Base do Ubuntu (Root)
# --------------------------------------------------
$step2Path = Join-Path $PSScriptDir "scripts\02-configure-ubuntu.sh"
if (Test-Path $step2Path) {
    $Distro = Get-UbuntuDistro
    Out-CleanHost ""
    Out-CleanHost ">>> Executando 02-configure-ubuntu.sh no WSL ($Distro)..." -ForegroundColor Cyan
    $step2WslPath = Get-WslPath $step2Path
    
    wsl.exe -d $Distro -u root -- bash -c "rm -f /etc/apt/sources.list.d/gierens.list 2>/dev/null; sed -i 's/\r//g' '$step2WslPath' 2>/dev/null; bash '$step2WslPath'"
    if ($LASTEXITCODE -ne 0) {
        Out-CleanHost "[ERRO] Falha na execucao do Passo 02 dentro do WSL." -ForegroundColor Red
        exit $LASTEXITCODE
    }
}
else {
    Out-CleanHost "[ERRO] Arquivo 02-configure-ubuntu.sh nao encontrado em scripts/." -ForegroundColor Red
    exit 1
}

# --------------------------------------------------
# PASSO 3: Ferramentas de Dev, Fish Shell & Stacks (User)
# --------------------------------------------------
$step3Path = Join-Path $PSScriptDir "scripts\03-install-dev-tools.sh"
$stacksDir = Join-Path $PSScriptDir "stacks"

if (Test-Path $step3Path) {
    $Distro = Get-UbuntuDistro
    Out-CleanHost ""
    Out-CleanHost ">>> Executando 03-install-dev-tools.sh no WSL ($Distro)..." -ForegroundColor Cyan
    $step3WslPath = Get-WslPath $step3Path
    $stacksWslPath = Get-WslPath $stacksDir
    
    # Sanitiza quebra de linha CRLF do Windows (sem símbolo $ para evitar conflito no Fish Shell)
    wsl.exe -d $Distro -- bash -c "sed -i 's/\r//g' '$step3WslPath' 2>/dev/null; find '$stacksWslPath' -type f -exec sed -i 's/\r//g' {} + 2>/dev/null; bash '$step3WslPath'"
    if ($LASTEXITCODE -ne 0) {
        Out-CleanHost "[ERRO] Falha na execucao do Passo 03 dentro do WSL." -ForegroundColor Red
        exit $LASTEXITCODE
    }
}
else {
    Out-CleanHost "[ERRO] Arquivo 03-install-dev-tools.sh nao encontrado em scripts/." -ForegroundColor Red
    exit 1
}

# --------------------------------------------------
# PASSO 4: Configuração do Docker
# --------------------------------------------------
$step4Path = Join-Path $PSScriptDir "scripts\04-configure-docker.ps1"
if (Test-Path $step4Path) {
    Out-CleanHost ""
    Out-CleanHost ">>> Executando 04-configure-docker.ps1..." -ForegroundColor Cyan
    & $step4Path
    if ($LASTEXITCODE -ne 0) {
        Out-CleanHost "[ERRO] Falha na execucao do Passo 04." -ForegroundColor Red
        exit $LASTEXITCODE
    }
}
else {
    Out-CleanHost "[ERRO] Arquivo 04-configure-docker.ps1 nao encontrado em scripts/." -ForegroundColor Red
    exit 1
}

Out-CleanHost ""
Out-CleanHost "==================================================" -ForegroundColor Cyan
Out-CleanHost " PARABENS! AMBIENTE WSL CONFIGURADO COM SUCESSO" -ForegroundColor Green
Out-CleanHost "==================================================" -ForegroundColor Cyan
Out-CleanHost ""
Out-CleanHost "Para acessar seu terminal Ubuntu com Fish Shell:"
Out-CleanHost "  wsl"
Out-CleanHost ""
Out-CleanHost "Pressione Enter para fechar esta janela..." -ForegroundColor Gray
Read-Host | Out-Null
[Environment]::Exit(0)
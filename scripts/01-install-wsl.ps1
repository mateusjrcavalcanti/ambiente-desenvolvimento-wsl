# --------------------------------------------------
# scripts/01-install-wsl.ps1
# Instalação e configuração inicial do WSL 2, Ubuntu, PowerToys, Terminal & Fonts
# --------------------------------------------------

$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$Distro = "Ubuntu-24.04"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " [01/04] Configurando WSL 2 + $Distro" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# --------------------------------------------------
# 1. Auto-elevação de privilégios de Administrador
# --------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    try {
        Write-Host "Solicitando privilegios de Administrador (UAC)..." -ForegroundColor Yellow
        $scriptPath = $MyInvocation.MyCommand.Definition
        if (-not $scriptPath) { $scriptPath = $PSCommandPath }

        Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$scriptPath`"" -ErrorAction Stop
        exit 0
    }
    catch {
        Write-Host "[ERRO] Nao foi possivel abrir janela com elevacao de Administrador." -ForegroundColor Red
        Write-Host "Por favor, abra o PowerShell como Administrador manualmente." -ForegroundColor Yellow
        exit 1
    }
}

# --------------------------------------------------
# 2. Verificar WSL
# --------------------------------------------------
Write-Host "`n1. Verificando estado do WSL..." -ForegroundColor Yellow

$wslInstalled = $false

try {
    wsl.exe --status *> $null
    if ($LASTEXITCODE -eq 0) {
        $wslInstalled = $true
    }
}
catch {
    $wslInstalled = $false
}

if (-not $wslInstalled) {
    Write-Host "   WSL nao encontrado. Instalando..." -ForegroundColor Yellow
    wsl.exe --install --no-distribution
    Write-Host "   WSL instalado com sucesso." -ForegroundColor Green
    Write-Host "[ATENCAO] Caso necessario, reinicie o Windows e execute novamente este script." -ForegroundColor Yellow
}
else {
    Write-Host "   WSL ja esta instalado." -ForegroundColor Green
}

# --------------------------------------------------
# 3. Atualizar kernel WSL
# --------------------------------------------------
Write-Host "`n2. Atualizando kernel do WSL..." -ForegroundColor Yellow
wsl.exe --update
if ($LASTEXITCODE -eq 0) {
    Write-Host "   Kernel WSL atualizado." -ForegroundColor Green
}

# --------------------------------------------------
# 4. Definir WSL 2 como versão padrão
# --------------------------------------------------
Write-Host "`n3. Definindo versao padrao para WSL 2..." -ForegroundColor Yellow
wsl.exe --set-default-version 2
Write-Host "   WSL 2 definido como padrao." -ForegroundColor Green

# --------------------------------------------------
# 5. Verificar e detectar distribuição Ubuntu (Store ou CLI)
# --------------------------------------------------
Write-Host "`n4. Verificando distribuicoes Ubuntu no WSL..." -ForegroundColor Yellow

$installedDistros = @(
    wsl.exe --list --quiet 2>$null | ForEach-Object { $_.Trim().Replace("`0", "") } | Where-Object { $_ -ne "" }
)

$ubuntuDistro = $installedDistros | Where-Object { $_ -like "Ubuntu*" } | Select-Object -First 1

if ($ubuntuDistro) {
    Write-Host "   Distribuicao Ubuntu detectada no sistema: '$ubuntuDistro'" -ForegroundColor Green
    $Distro = $ubuntuDistro
}
else {
    $Distro = "Ubuntu-24.04"
    Write-Host "   Nenhuma distribuicao Ubuntu encontrada. Instalando '$Distro'..." -ForegroundColor Yellow
    wsl.exe --install -d $Distro --no-launch

    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERRO] Falha ao instalar $Distro (codigo: $LASTEXITCODE)." -ForegroundColor Red
        exit $LASTEXITCODE
    }

    Write-Host "   $Distro instalada com sucesso." -ForegroundColor Green
}

# --------------------------------------------------
# 6. Definir $Distro como padrão
# --------------------------------------------------
Write-Host "`n5. Definindo '$Distro' como distribuicao padrao do WSL..." -ForegroundColor Yellow
wsl.exe --set-default $Distro
Write-Host "   '$Distro' definida como distribuicao padrao do WSL." -ForegroundColor Green

# --------------------------------------------------
# 7. Instalar Microsoft PowerToys (Windows)
# --------------------------------------------------
Write-Host "`n6. Verificando Microsoft PowerToys..." -ForegroundColor Yellow

$wingetPath = Get-Command "winget.exe" -ErrorAction SilentlyContinue

if ($wingetPath) {
    $powerToysCheck = winget.exe list --id Microsoft.PowerToys --exact 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $powerToysCheck) {
        Write-Host "   Instalando Microsoft PowerToys via winget..." -ForegroundColor Yellow
        winget.exe install -e --id Microsoft.PowerToys --accept-package-agreements --accept-source-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "   Microsoft PowerToys instalado com sucesso." -ForegroundColor Green
        }
        else {
            Write-Host "   [AVISO] Nao foi possivel instalar o Microsoft PowerToys via winget." -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "   Microsoft PowerToys ja esta instalado." -ForegroundColor Green
    }
}
else {
    Write-Host "   [AVISO] winget.exe nao encontrado no Windows. Instale o PowerToys manualmente se desejar." -ForegroundColor Yellow
}

# --------------------------------------------------
# 8. Instalar / Verificar Windows Terminal (Canary ou Preview)
# --------------------------------------------------
Write-Host "`n7. Verificando Windows Terminal..." -ForegroundColor Yellow

if ($wingetPath) {
    $wtCheck = Get-AppxPackage -Name "*WindowsTerminal*" 2>$null
    if (-not $wtCheck) {
        Write-Host "   Instalando Windows Terminal..." -ForegroundColor Yellow
        winget.exe install -e --id Microsoft.WindowsTerminal --accept-package-agreements --accept-source-agreements 2>$null
    }
    else {
        Write-Host "   Windows Terminal detectado." -ForegroundColor Green
    }
}

# --------------------------------------------------
# 9. Instalar MesloLGS Nerd Font
# --------------------------------------------------
Write-Host "`n8. Instalando MesloLGS Nerd Fonts (necessario para icones do Fish / Starship)..." -ForegroundColor Yellow

$fontUrls = @(
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf",
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf",
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf",
    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
)

$userFontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
if (-not (Test-Path $userFontDir)) {
    New-Item -ItemType Directory -Path $userFontDir -Force | Out-Null
}

foreach ($url in $fontUrls) {
    $fileName = [System.IO.Path]::GetFileName([System.Uri]::UnescapeDataString($url))
    $destPath = Join-Path $userFontDir $fileName

    if (-not (Test-Path $destPath)) {
        try {
            Write-Host "   Baixando $fileName..." -ForegroundColor Gray
            Invoke-WebRequest -Uri $url -OutFile $destPath -UseBasicParsing
            
            $regKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
            $fontName = "$([System.IO.Path]::GetFileNameWithoutExtension($fileName)) (TrueType)"
            New-ItemProperty -Path $regKey -Name $fontName -Value $destPath -PropertyType String -Force | Out-Null
        }
        catch {
            Write-Host "   [AVISO] Falha ao baixar $fileName" -ForegroundColor Yellow
        }
    }
}
Write-Host "   MesloLGS Nerd Fonts prontas no sistema." -ForegroundColor Green

# --------------------------------------------------
# 10. Aplicar configurações do Windows Terminal
# --------------------------------------------------
Write-Host "`n9. Aplicando configuracoes do Windows Terminal..." -ForegroundColor Yellow

$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition }
$repoDir = Split-Path -Parent $scriptDir

$settingsExample = Join-Path $repoDir "config\windows-terminal-settings-example.json"

$terminalSettingsPaths = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalCanary_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
)

foreach ($path in $terminalSettingsPaths) {
    $parentDir = Split-Path -Parent $path
    if (Test-Path $parentDir) {
        try {
            if (Test-Path $settingsExample) {
                Copy-Item -Path $settingsExample -Destination $path -Force
                Write-Host "   Configuracoes aplicadas com sucesso em: $path" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "   [AVISO] Nao foi possivel copiar configuracoes para $path" -ForegroundColor Yellow
        }
    }
}

Write-Host "`n[SUCESSO] Passo 01 concluido!" -ForegroundColor Green

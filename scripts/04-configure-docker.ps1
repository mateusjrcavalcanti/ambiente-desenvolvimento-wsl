# --------------------------------------------------
# scripts/04-configure-docker.ps1
# Configuração do Docker Desktop e Integração WSL 2
# --------------------------------------------------

$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

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

# Detectar se já existe qualquer distribuição Ubuntu instalada (da Store ou CLI)
$installedDistros = @(
    wsl.exe --list --quiet 2>$null | ForEach-Object { $_.Trim().Replace("`0", "") } | Where-Object { $_ -ne "" }
)
$Distro = $installedDistros | Where-Object { $_ -like "Ubuntu*" } | Select-Object -First 1
if (-not $Distro) {
    $Distro = "Ubuntu-24.04"
}

Out-CleanHost "========================================" -ForegroundColor Cyan
Out-CleanHost " [04/04] Configurando Docker + Integracao WSL ($Distro)" -ForegroundColor Cyan
Out-CleanHost "========================================" -ForegroundColor Cyan

# --------------------------------------------------
# 1. Verificar Docker no Windows
# --------------------------------------------------
Out-CleanHost ""
Out-CleanHost "1. Verificando instalacao do Docker Desktop no Windows..." -ForegroundColor Yellow

$dockerInstalled = $null -ne (Get-Command "docker.exe" -ErrorAction SilentlyContinue)

if (-not $dockerInstalled) {
    Out-CleanHost "   Docker Desktop nao foi detectado no PATH do Windows." -ForegroundColor Yellow
    Out-CleanHost "   Voce pode instala-lo manualmente ou via winget executando:" -ForegroundColor Cyan
    Out-CleanHost "     winget install -e --id Docker.DockerDesktop" -ForegroundColor Gray
}
else {
    Out-CleanHost "   Docker CLI detectado no Windows: $((docker.exe --version))" -ForegroundColor Green
}

# --------------------------------------------------
# 2. Configurar permissões de grupo docker no WSL
# --------------------------------------------------
Out-CleanHost ""
Out-CleanHost "2. Configurando permissoes do Docker na distribuicao $Distro..." -ForegroundColor Yellow

try {
    $wslUser = (wsl.exe -d $Distro -e whoami 2>$null)
    if ($LASTEXITCODE -eq 0 -and $wslUser) {
        $wslUser = $wslUser.Trim()
        Out-CleanHost "   Usuario WSL detectado: $wslUser" -ForegroundColor Green

        # Criar grupo docker e adicionar usuário
        wsl.exe -d $Distro -u root -- groupadd -f docker
        wsl.exe -d $Distro -u root -- usermod -aG docker $wslUser

        Out-CleanHost "   Usuario '$wslUser' adicionado ao grupo 'docker' no Ubuntu." -ForegroundColor Green
    }
    else {
        Out-CleanHost "   Distribuicao $Distro ainda nao instalada ou nao inicializada." -ForegroundColor Yellow
    }
}
catch {
    Out-CleanHost "[AVISO] Nao foi possivel configurar o grupo docker no WSL automaticamente." -ForegroundColor Yellow
}

# --------------------------------------------------
# 3. Testar comunicação do Docker no WSL
# --------------------------------------------------
Out-CleanHost ""
Out-CleanHost "3. Verificando suporte ao Docker dentro do WSL..." -ForegroundColor Yellow

try {
    $dockerInWsl = wsl.exe -d $Distro -e docker --version 2>$null
    if ($LASTEXITCODE -eq 0 -and $dockerInWsl) {
        Out-CleanHost "   Docker no WSL retornado: $dockerInWsl" -ForegroundColor Green
    }
    else {
        Out-CleanHost "   Nota: Certifique-se de que a opcao 'Use the WSL 2 based engine' e a integracao com '$Distro' estao ativadas nas configuracoes do Docker Desktop -> Resources -> WSL Integration." -ForegroundColor Yellow
    }
}
catch {
    Out-CleanHost "   Aguardando inicializacao do Docker Desktop para verificacao final." -ForegroundColor Yellow
}

# Resetar LASTEXITCODE para garantir retorno com sucesso (exit code 0)
$global:LASTEXITCODE = 0

Out-CleanHost ""
Out-CleanHost "========================================" -ForegroundColor Cyan
Out-CleanHost " [SUCESSO] Configuracao do Docker finalizada!" -ForegroundColor Green
Out-CleanHost "========================================" -ForegroundColor Cyan

exit 0

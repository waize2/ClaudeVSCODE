# Deconnecte Claude Code le mardi de sortie de la cedule A (jour 7 du cycle de 14 jours depuis le 6 oct 2026)
# Lance chaque mardi a 10:55 ; le cycle doit rester identique a celui de hotspot-cedule\hotspot.ps1
$debutCycle = [datetime]'2026-10-06'
$claude = Join-Path $env:APPDATA 'npm\claude.cmd'
$log = Join-Path $PSScriptRoot 'deconnexion.log'

function Log($msg) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $msg" | Out-File $log -Append -Encoding utf8 }

$jourCycle = (((Get-Date).Date - $debutCycle).Days % 14 + 14) % 14
if ($jourCycle -ne 7) { Log "mardi 10:55, jour $jourCycle du cycle : pas le mardi de sortie, rien a faire"; exit }

& $claude auth status *> $null
if ($LASTEXITCODE -ne 0) { Log 'mardi de sortie de la cedule A : deja deconnecte'; exit }
$sortie = (& $claude auth logout 2>&1 | Out-String).Trim()
Log "mardi de sortie de la cedule A : $sortie (code $LASTEXITCODE)"

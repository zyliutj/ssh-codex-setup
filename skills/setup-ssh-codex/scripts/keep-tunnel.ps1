param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-zA-Z0-9][a-zA-Z0-9._-]{0,127}$')]
    [string]$Alias,
    [switch]$CheckOnly
)
$ErrorActionPreference = 'Stop'
$sshExe = Join-Path $env:WINDIR 'System32\OpenSSH\ssh.exe'
if (-not (Test-Path -LiteralPath $sshExe)) { throw 'OpenSSH client not found.' }
if ($CheckOnly) {
    & $sshExe -G $Alias
    exit $LASTEXITCODE
}
$logDir = Join-Path $env:LOCALAPPDATA 'CodexSshTunnels'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null
$logPath = Join-Path $logDir "$Alias.log"
while ($true) {
    if ((Test-Path -LiteralPath $logPath) -and (Get-Item -LiteralPath $logPath).Length -gt 1MB) {
        Move-Item -LiteralPath $logPath -Destination "$logPath.previous" -Force
    }
    Add-Content -LiteralPath $logPath -Value "$(Get-Date -Format o) starting $Alias"
    # OpenSSH logs directly to a bounded file, keeping native stderr out of PowerShell error handling.
    & $sshExe -N -T -E $logPath -o BatchMode=yes -o ConnectTimeout=10 -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 $Alias
    Add-Content -LiteralPath $logPath -Value "$(Get-Date -Format o) ssh exit=$LASTEXITCODE; retry in 10 seconds"
    Start-Sleep -Seconds 10
}

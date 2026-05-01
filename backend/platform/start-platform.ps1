param(
  [string]$BindHost = '127.0.0.1',
  [int]$Port = 4100
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$serverPath = Join-Path $scriptDir 'server.js'
$bundledNode = 'C:\Users\U S E R\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe'

$env:SD_PLATFORM_HOST = $BindHost
$env:SD_PLATFORM_PORT = "$Port"

Write-Host ''
Write-Host "Starting SD Travel Guide platform on $BindHost:$Port ..." -ForegroundColor Yellow

if (Test-Path $bundledNode) {
  & $bundledNode $serverPath
  exit $LASTEXITCODE
}

Write-Host 'Bundled Node runtime was not found, falling back to node from PATH.' -ForegroundColor DarkYellow
& node $serverPath
exit $LASTEXITCODE

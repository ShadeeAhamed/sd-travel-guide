param(
  [Parameter(Mandatory = $true)]
  [string]$RepoUrl,

  [string]$CommitMessage = "Initial commit",
  [string]$UserName = "Shadee Ahamed",
  [string]$UserEmail = "shadeea653@gmail.com"
)

$ErrorActionPreference = "Stop"

function Invoke-Git {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  & git @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "Git command failed: git $($Arguments -join ' ')"
  }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$safeDirectories = @()
try {
  $safeDirectories = @(git config --global --get-all safe.directory 2>$null)
} catch {
  $safeDirectories = @()
}

if ($safeDirectories -notcontains $repoRoot) {
  Invoke-Git -Arguments @("config", "--global", "--add", "safe.directory", $repoRoot)
}

if (-not (Test-Path ".git")) {
  Invoke-Git -Arguments @("init", "--initial-branch=main")
}

Invoke-Git -Arguments @("add", ".")

$statusOutput = @(git status --short)
if ($LASTEXITCODE -ne 0) {
  throw "Git command failed: git status --short"
}

if ($statusOutput.Count -gt 0) {
  Invoke-Git -Arguments @(
    "-c", "user.name=$UserName",
    "-c", "user.email=$UserEmail",
    "commit", "-m", $CommitMessage
  )
} else {
  Write-Host "No new changes to commit." -ForegroundColor Yellow
}

$existingRemote = @(git remote)
if ($LASTEXITCODE -ne 0) {
  throw "Git command failed: git remote"
}

if ($existingRemote -notcontains "origin") {
  Invoke-Git -Arguments @("remote", "add", "origin", $RepoUrl)
} else {
  Invoke-Git -Arguments @("remote", "set-url", "origin", $RepoUrl)
}

Invoke-Git -Arguments @("push", "-u", "origin", "main")

Write-Host ""
Write-Host "Done. Your project is now connected to GitHub:" -ForegroundColor Green
Write-Host $RepoUrl -ForegroundColor Cyan

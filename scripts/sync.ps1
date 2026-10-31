# Kanban sync — pull --rebase then push if local is ahead. Light always-on job (like Claude inbox).
$ErrorActionPreference = 'Continue'
$Repo = 'C:\Users\quarm\Documents\Codex\Constellation\kanban'
$Log  = Join-Path $Repo 'scripts\sync.log'
function Log($m){ Add-Content -Path $Log -Value ("{0:s} {1}" -f (Get-Date), $m) }
try {
  if (-not (Test-Path $Repo)) { Log 'missing clone'; exit 1 }
  Set-Location $Repo
  git fetch origin 2>&1 | Out-Null
  $pull = git pull --rebase origin main 2>&1 | Out-String
  if ($LASTEXITCODE -ne 0) {
    Log ("rebase-fail: " + $pull.Trim())
    git rebase --abort 2>$null
    exit 1
  }
  $status = git status -sb
  if ($status -match 'ahead') {
    $push = git push origin main 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) { Log ("push-fail: " + $push.Trim()); exit 1 }
    Log 'pulled+pushed'
  } else {
    Log 'pulled'
  }
} catch {
  Log ("err: " + $_.Exception.Message)
  exit 1
}

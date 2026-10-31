param(
  [Parameter(Mandatory=$true)][ValidateSet('Codex','Claude','Grok Bot','Dev','Research','Ponytail')][string]$Owner,
  [Parameter(Mandatory=$true)][string]$TitleMatch,
  [Parameter(Mandatory=$true)][string]$Note,
  [string]$Email = ''
)
$ErrorActionPreference = 'Stop'
$Repo = 'C:\Users\quarm\Documents\Codex\Constellation\kanban'
Set-Location $Repo
git pull --rebase origin main
if ($LASTEXITCODE -ne 0) { git rebase --abort 2>$null; throw 'pull --rebase failed' }
$path = Join-Path $Repo 'index.html'
$html = [IO.File]::ReadAllText($path)
if ($html -notmatch [regex]::Escape($TitleMatch)) { throw "card title match not found: $TitleMatch" }
# Append note after the first <br> inside the matching card's .m block (best-effort, no secrets check beyond length)
$pattern = "(<b>[^<]*$([regex]::Escape($TitleMatch))[^<]*</b><div class=m>)(.*?)(</div></div>)"
$rx = [regex]::new($pattern, [Text.RegularExpressions.RegexOptions]::Singleline)
$m = $rx.Match($html)
if (-not $m.Success) { throw 'card structure match failed' }
$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm'
$newInner = $m.Groups[2].Value.TrimEnd() + "<br>$Note ($stamp)"
$html2 = $html.Substring(0,$m.Groups[2].Index) + $newInner + $html.Substring($m.Groups[2].Index + $m.Groups[2].Length)
# forbid obvious secret patterns in the note itself
if ($Note -match '(?i)(token|secret|password|api[_-]?key|BEGIN (RSA |OPENSSH )?PRIVATE)') { throw 'note looks like a secret' }
[IO.File]::WriteAllText($path, $html2)
if (-not $Email) {
  $Email = switch ($Owner) {
    'Codex' { 'codex@users.noreply.github.com' }
    'Claude' { 'claude@users.noreply.github.com' }
    default { 'agent@users.noreply.github.com' }
  }
}
git add index.html
git -c user.name="$Owner" -c user.email="$Email" commit -m "board($Owner): note on $TitleMatch"
if ($LASTEXITCODE -ne 0) { throw 'commit failed' }
git push origin main
if ($LASTEXITCODE -ne 0) { throw 'push failed' }
Write-Host "OK: noted and pushed as $Owner"

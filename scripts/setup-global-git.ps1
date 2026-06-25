# Safe global git configuration (Wave 2 — no gpgsign until verified)
# Run: .\scripts\setup-global-git.ps1
# Then: .\scripts\verify-gpg-signing.ps1 before enabling commit signing

param([switch]$EnableSigning)

$settings = @{
    "init.defaultBranch"     = "main"
    "pull.rebase"            = "false"
    "pull.ff"                = "only"
    "fetch.prune"            = "true"
    "push.default"           = "simple"
    "push.autoSetupRemote"   = "true"
    "core.longpaths"         = "true"
    "core.autocrlf"          = "true"
    "color.ui"               = "auto"
    "rerere.enabled"         = "true"
    "help.autocorrect"       = "1"
}

Write-Host "=== Global Git Config (safe settings) ===" -ForegroundColor Cyan

foreach ($key in $settings.Keys) {
    $val = $settings[$key]
    git config --global $key $val
    Write-Host "  $key = $val"
}

# Useful aliases
$aliases = @{
    "lg"      = "log --oneline --graph --decorate --all -20"
    "last"    = "log -1 HEAD"
    "unstage" = "reset HEAD --"
    "hist"    = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short -20"
}
foreach ($name in $aliases.Keys) {
    git config --global "alias.$name" $aliases[$name]
}

if ($EnableSigning) {
    Write-Host "`nEnabling GPG commit signing..." -ForegroundColor Yellow
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
    git config --global gpg.program "gpg"
} else {
    Write-Host "`nGPG signing NOT enabled. Run verify-gpg-signing.ps1 first, then:" -ForegroundColor Yellow
    Write-Host "  .\scripts\setup-global-git.ps1 -EnableSigning"
}

Write-Host "`nCurrent identity:" -ForegroundColor Green
git config --global user.name
git config --global user.email
Write-Host "Signing key: $(git config --global user.signingkey)"

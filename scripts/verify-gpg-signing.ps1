# Verify GPG signing works before enabling commit.gpgsign globally
# Run: .\scripts\verify-gpg-signing.ps1

$ErrorActionPreference = "Stop"
$testDir = Join-Path $env:TEMP "gpg-sign-test-$(Get-Random)"

Write-Host "=== GPG Signing Verification ===" -ForegroundColor Cyan

$userEmail = git config --global user.email
$signingKey = git config --global user.signingkey

Write-Host "Git email:    $userEmail"
Write-Host "Signing key:  $signingKey"

if (-not $signingKey) {
    Write-Host "FAIL: No user.signingkey configured" -ForegroundColor Red
    exit 1
}

$keyList = gpg --list-secret-keys --keyid-format=long 2>&1
Write-Host "`nSecret keys:`n$keyList"

if ($keyList -notmatch $signingKey) {
    Write-Host "WARN: signing key may not match available secret keys" -ForegroundColor Yellow
}

# Check email match
if ($keyList -notmatch [regex]::Escape($userEmail)) {
    Write-Host "WARN: git user.email ($userEmail) may not match GPG key UID" -ForegroundColor Yellow
    Write-Host "Fix with: git config --global user.email <matching-gpg-email>"
    Write-Host "GPG UID shows: janet.duffy@bhhsnv.com"
}

New-Item -ItemType Directory -Force -Path $testDir | Out-Null
Push-Location $testDir
try {
    git init -b main | Out-Null
    git config user.name (git config --global user.name)
    git config user.email (git config --global user.email)
    git config user.signingkey $signingKey
    git config commit.gpgsign true

    "test" | Out-File test.txt
    git add test.txt
    git commit -S -m "test: gpg signing verification" 2>&1

    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAIL: Signed commit failed" -ForegroundColor Red
        exit 1
    }

    $sig = git log --show-signature -1 2>&1
    Write-Host "`nSignature check:`n$sig"

    if ($sig -match "Good signature") {
        Write-Host "`nPASS: GPG signing works. Safe to run setup-global-git.ps1 -EnableSigning" -ForegroundColor Green
        exit 0
    }

    Write-Host "`nFAIL: No 'Good signature' in log output" -ForegroundColor Red
    exit 1
} finally {
    Pop-Location
    Remove-Item -Recurse -Force $testDir -ErrorAction SilentlyContinue
}

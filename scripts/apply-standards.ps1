# Apply Git Org Standards to DrJanDuffy repositories
# Safe by default: additive files only, no force-push, no branch rename unless -RenameBranches
#
# Usage:
#   .\scripts\apply-standards.ps1 -DryRun
#   .\scripts\apply-standards.ps1 -Repo centennialhillshomesforsale
#   .\scripts\apply-standards.ps1 -LocalRoot C:\Users\geneb\projects
#   .\scripts\apply-standards.ps1 -RenameBranches   # DANGER: updates GitHub default branch

param(
    [switch]$DryRun,
    [switch]$RenameBranches,
    [string]$Repo = "",
    [string]$Org = "DrJanDuffy",
    [string]$TemplatesDir = "$PSScriptRoot\..\templates",
    [string]$WorkDir = "$env:TEMP\git-org-standards-apply",
    [string]$LocalRoot = ""
)

$ErrorActionPreference = "Stop"

$AllRepos = @(
    "git-org-standards",
    "centennialhillshomesforsale",
    "StickStrick.com",
    "antigravity-lead-agent",
    "stickmanstrike",
    "stickmanshorts",
    "stickmanlegends",
    "stickmangear",
    "stickmanepiclegends",
    "stickmanepic",
    "stickmancommunity",
    "genekellyboyle",
    "genekellyboyle.com"
)

if ($Repo) { $AllRepos = @($Repo) }

$LogFile = Join-Path $WorkDir "apply-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $line = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Message"
    Write-Host $line
    if ($LogFile) {
        $dir = Split-Path $LogFile -Parent
        if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
        Add-Content -Path $LogFile -Value $line
    }
}

function Copy-FileIfMissing {
    param(
        [string]$Src,
        [string]$Dst,
        [switch]$Force
    )
    if (-not (Test-Path $Src)) {
        Write-Log "Template missing: $Src" "WARN"
        return $false
    }
    $dstDir = Split-Path $Dst -Parent
    if ($dstDir -and -not (Test-Path $dstDir)) {
        if ($DryRun) { return $true }
        New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
    }
    if ($Force -or -not (Test-Path $Dst)) {
        if ($DryRun) {
            Write-Log "Would copy: $(Split-Path $Src -Leaf) -> $Dst"
            return $true
        }
        Copy-Item -Path $Src -Destination $Dst -Force
        return $true
    }
    return $false
}

function Merge-Gitignore {
    param([string]$Dest)
    $template = Join-Path $TemplatesDir ".gitignore"
    $existing = Join-Path $Dest ".gitignore"
    if (-not (Test-Path $template)) { return }

    if (-not (Test-Path $existing)) {
        if ($DryRun) {
            Write-Log "Would create .gitignore"
            return
        }
        Copy-Item $template $existing
        return
    }

    $marker = "# --- Org standards ---"
    $existingContent = Get-Content $existing -Raw
    if ($existingContent -match [regex]::Escape($marker)) {
        Write-Log ".gitignore already merged"
        return
    }

    $templateContent = Get-Content $template -Raw
    $merged = $existingContent.TrimEnd() + "`n`n$marker`n" + $templateContent
    $lines = $merged -split "`r?`n" | Where-Object { $_.Trim() -ne "" } | Select-Object -Unique
    if ($DryRun) {
        Write-Log "Would merge .gitignore ($($lines.Count) unique lines)"
        return
    }
    ($lines -join "`n") + "`n" | Set-Content $existing -NoNewline
}

function Copy-Templates {
    param([string]$Dest)
    $changed = $false

    foreach ($item in @("CLAUDE.md", "AGENTS.md", "CONTRIBUTING.md", "commitlint.config.mjs", ".pre-commit-config.yaml")) {
        if (Copy-FileIfMissing -Src (Join-Path $TemplatesDir $item) -Dst (Join-Path $Dest $item) -Force) { $changed = $true }
    }

    Merge-Gitignore -Dest $Dest

    $githubFiles = @(
        "pull_request_template.md",
        "dependabot.yml",
        "ISSUE_TEMPLATE\bug_report.md",
        "ISSUE_TEMPLATE\feature_request.md",
        "workflows\ci.yml",
        "workflows\sync-standards.yml"
    )
    foreach ($rel in $githubFiles) {
        $force = $rel -in @("dependabot.yml", "workflows\sync-standards.yml")
        if (Copy-FileIfMissing -Src (Join-Path $TemplatesDir ".github\$rel") -Dst (Join-Path $Dest ".github\$rel") -Force:$force) { $changed = $true }
    }

    $claudeFiles = @(
        "LOOPS.md",
        "settings.json",
        "commands\babysit.md",
        "commands\post-merge-sweeper.md",
        "commands\pr-pruner.md",
        "commands\commit-push-pr.md",
        "commands\verify-loop.md",
        "commands\plan-then-build.md",
        "commands\nate-situation-brief.md",
        "commands\seo-audit-loop.md"
    )
    foreach ($rel in $claudeFiles) {
        if (Copy-FileIfMissing -Src (Join-Path $TemplatesDir ".claude\$rel") -Dst (Join-Path $Dest ".claude\$rel") -Force) { $changed = $true }
    }

    return $changed
}

function Get-RepoPath {
    param([string]$RepoName)
    if ($LocalRoot) {
        $local = Join-Path $LocalRoot $RepoName
        if (Test-Path (Join-Path $local ".git")) { return $local }
    }
    return Join-Path $WorkDir $RepoName
}

function Ensure-Clone {
    param([string]$RepoName, [string]$RepoPath)
    if (Test-Path (Join-Path $RepoPath ".git")) { return $true }

    $cloneUrl = "https://github.com/$Org/$RepoName.git"
    Write-Log "Cloning $cloneUrl"
    if ($DryRun) { return $true }

    New-Item -ItemType Directory -Force -Path (Split-Path $RepoPath -Parent) | Out-Null
    git clone --depth 1 $cloneUrl $RepoPath 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        New-Item -ItemType Directory -Force -Path $RepoPath | Out-Null
        Push-Location $RepoPath
        git init -b main
        git remote add origin $cloneUrl
        Pop-Location
    }
    return $true
}

function Rename-MasterToMain {
    param([string]$RepoPath, [string]$RepoName)
    if (-not $RenameBranches) { return }

    Push-Location $RepoPath
    try {
        $current = git rev-parse --abbrev-ref HEAD 2>$null
        $remoteBranches = git branch -r 2>$null
        if ($current -eq "master" -and $remoteBranches -notmatch "origin/main") {
            Write-Log "Renaming master -> main for $RepoName (update Vercel prod branch first!)" "WARN"
            if ($DryRun) { return }
            git branch -m master main
            git push -u origin main
            gh api -X PATCH "repos/$Org/$RepoName" -f default_branch=main
            git push origin --delete master
        }
    } finally { Pop-Location }
}

Write-Log "=== Git Org Standards Apply ==="
Write-Log "Templates: $TemplatesDir"
Write-Log "Repos: $($AllRepos.Count) | DryRun: $DryRun | RenameBranches: $RenameBranches"
if ($LocalRoot) { Write-Log "LocalRoot: $LocalRoot" }

if (-not $RenameBranches) {
    Write-Log "Branch rename SKIPPED (use -RenameBranches after updating Vercel prod branch per repo)" "WARN"
}

$results = @()

foreach ($repoName in $AllRepos) {
    Write-Log "--- $repoName ---"
    $repoPath = Get-RepoPath -RepoName $repoName

    if (-not (Ensure-Clone -RepoName $repoName -RepoPath $repoPath)) {
        $results += [PSCustomObject]@{ Repo = $repoName; Status = "clone-failed"; Branch = "-" }
        continue
    }

    $changed = Copy-Templates -Dest $repoPath

    if ($DryRun) {
        $results += [PSCustomObject]@{ Repo = $repoName; Status = "dry-run"; Branch = "-" }
        continue
    }

    Push-Location $repoPath
    try {
        git add -A
        $status = git status --porcelain
        if ($status) {
            git commit -m "chore: apply org git standards (CLAUDE.md, loops, CI, dependabot)"
            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            if (-not $branch -or $branch -eq "HEAD") {
                git checkout -b main
                $branch = "main"
            }
            $prevEAP = $ErrorActionPreference
            $ErrorActionPreference = "Continue"
            git push -u origin $branch 2>&1 | Out-Null
            $pushOk = ($LASTEXITCODE -eq 0)
            $ErrorActionPreference = $prevEAP
            if (-not $pushOk) {
                Write-Log "Push failed for $repoName - NOT force-pushing. Fix conflicts manually." "ERROR"
                $results += [PSCustomObject]@{ Repo = $repoName; Status = "push-failed"; Branch = $branch }
                continue
            }
            Rename-MasterToMain -RepoPath $repoPath -RepoName $repoName
            $results += [PSCustomObject]@{ Repo = $repoName; Status = "updated"; Branch = $branch }
        } else {
            $results += [PSCustomObject]@{ Repo = $repoName; Status = "no-changes"; Branch = (git rev-parse --abbrev-ref HEAD 2>$null) }
        }
    } finally { Pop-Location }
}

Write-Log "=== Results ==="
$results | Format-Table -AutoSize | Out-String | ForEach-Object { Write-Log $_.TrimEnd() }
if ($LogFile -and (Test-Path $LogFile)) { Write-Log "Log: $LogFile" }

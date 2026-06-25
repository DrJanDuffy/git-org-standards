# Apply Git Org Standards to DrJanDuffy Repositories
# Usage: .\scripts\apply-standards.ps1 [-DryRun] [-Repo <name>]

param(
    [switch]$DryRun,
    [string]$Repo = "",
    [string]$Org = "DrJanDuffy",
    [string]$TemplatesDir = "$PSScriptRoot\..\templates",
    [string]$WorkDir = "$env:TEMP\git-org-standards-apply"
)

$ErrorActionPreference = "Stop"

$AllRepos = @(
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

function Copy-FileIfMissing {
    param([string]$Src, [string]$Dst, [switch]$Force)
    if (-not (Test-Path $Src)) { return }
    $dstDir = Split-Path $Dst -Parent
    if ($dstDir -and -not (Test-Path $dstDir)) { New-Item -ItemType Directory -Force -Path $dstDir | Out-Null }
    if ($Force -or -not (Test-Path $Dst)) {
        Copy-Item -Path $Src -Destination $Dst -Force
    }
}

function Copy-Templates {
    param([string]$Dest)
    # Always update agent docs and contributing
    foreach ($item in @("CLAUDE.md", "AGENTS.md", "CONTRIBUTING.md", "commitlint.config.mjs", ".pre-commit-config.yaml")) {
        Copy-FileIfMissing -Src (Join-Path $TemplatesDir $item) -Dst (Join-Path $Dest $item) -Force
    }
    Merge-Gitignore -Dest $Dest
    # Merge .github — never delete existing workflows
    $githubFiles = @(
        "pull_request_template.md",
        "ISSUE_TEMPLATE\bug_report.md",
        "ISSUE_TEMPLATE\feature_request.md",
        "workflows\ci.yml",
        "workflows\sync-standards.yml"
    )
    foreach ($rel in $githubFiles) {
        Copy-FileIfMissing -Src (Join-Path $TemplatesDir ".github\$rel") -Dst (Join-Path $Dest ".github\$rel")
    }
    # Merge .claude — add commands/skills without removing existing
    $claudeFiles = @("LOOPS.md", "settings.json", "commands\babysit.md", "commands\post-merge-sweeper.md", "commands\pr-pruner.md", "commands\commit-push-pr.md")
    foreach ($rel in $claudeFiles) {
        Copy-FileIfMissing -Src (Join-Path $TemplatesDir ".claude\$rel") -Dst (Join-Path $Dest ".claude\$rel") -Force
    }
}

function Merge-Gitignore {
    param([string]$Dest)
    $template = Join-Path $TemplatesDir ".gitignore"
    $existing = Join-Path $Dest ".gitignore"
    if ((Test-Path $existing) -and (Test-Path $template)) {
        $existingContent = Get-Content $existing -Raw
        $templateContent = Get-Content $template -Raw
        $merged = $existingContent.TrimEnd() + "`n`n# --- Org standards ---`n" + $templateContent
        $lines = $merged -split "`n" | Select-Object -Unique
        $lines -join "`n" | Set-Content $existing -NoNewline
        Add-Content $existing "`n"
    }
}

function Rename-MasterToMain {
    param([string]$RepoPath, [string]$RepoName)
    Push-Location $RepoPath
    try {
        $branches = git branch -a 2>$null
        if ($branches -match "master" -and $branches -notmatch "main") {
            Write-Host "  Renaming master -> main for $RepoName"
            if (-not $DryRun) {
                git branch -m master main
                git push -u origin main 2>$null
                gh api -X PATCH "repos/$Org/$RepoName" -f default_branch=main 2>$null
                git push origin --delete master 2>$null
            }
        }
    } finally { Pop-Location }
}

Write-Host "=== Git Org Standards Apply ===" -ForegroundColor Cyan
Write-Host "Templates: $TemplatesDir"
Write-Host "Repos: $($AllRepos.Count)"
if ($DryRun) { Write-Host "DRY RUN - no pushes" -ForegroundColor Yellow }

New-Item -ItemType Directory -Force -Path $WorkDir | Out-Null

$results = @()

foreach ($repoName in $AllRepos) {
    Write-Host "`n--- $repoName ---" -ForegroundColor Green
    $repoPath = Join-Path $WorkDir $repoName

    if (Test-Path $repoPath) { Remove-Item -Recurse -Force $repoPath }

    $cloneUrl = "https://github.com/$Org/$repoName.git"
    Write-Host "  Cloning..."
    if (-not $DryRun) {
        git clone --depth 1 $cloneUrl $repoPath 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            # Empty repo - init fresh
            New-Item -ItemType Directory -Force -Path $repoPath | Out-Null
            Push-Location $repoPath
            git init -b main
            git remote add origin $cloneUrl
            Pop-Location
        }
    } else {
        New-Item -ItemType Directory -Force -Path $repoPath | Out-Null
    }

    if (-not $DryRun) {
        Copy-Templates -Dest $repoPath
        Merge-Gitignore -Dest $repoPath

        Push-Location $repoPath
        git add -A
        $status = git status --porcelain
        if ($status) {
            git commit -m "chore: apply org git standards (CLAUDE.md, loops, CI, hooks)"
            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            if (-not $branch -or $branch -eq "HEAD") { git checkout -b main; $branch = "main" }
            git push -u origin $branch 2>&1
            if ($LASTEXITCODE -ne 0) { git push -u origin $branch --force 2>&1 }
            Rename-MasterToMain -RepoPath $repoPath -RepoName $repoName
            $results += [PSCustomObject]@{ Repo = $repoName; Status = "updated"; Branch = $branch }
        } else {
            $results += [PSCustomObject]@{ Repo = $repoName; Status = "no-changes"; Branch = "-" }
        }
        Pop-Location
    } else {
        $results += [PSCustomObject]@{ Repo = $repoName; Status = "dry-run"; Branch = "-" }
    }
}

Write-Host "`n=== Results ===" -ForegroundColor Cyan
$results | Format-Table -AutoSize

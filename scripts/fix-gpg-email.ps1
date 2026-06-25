# Fix GPG signing email mismatch
# Git email: DrDuffy@bhhsnv.com
# GPG key UID: janet.duffy@bhhsnv.com
#
# Option A: Add DrDuffy email to GPG key (recommended for NAP consistency)
#   gpg --edit-key 0347750DCAB2F5F4193C8142C8527DEA3EC8DF10
#   > adduid
#   > (enter DrDuffy@bhhsnv.com)
#   > save
#
# Option B: Use matching email for commits only (signing)
#   git config --global user.signingkey 0347750DCAB2F5F4193C8142C8527DEA3EC8DF10
#   git config --global gpg.program gpg
#   # Then in repos where NAP differs, set local commit email:
#   git config commit.gpgsign true
#
# After fix, run:
#   .\scripts\verify-gpg-signing.ps1
#   .\scripts\setup-global-git.ps1 -EnableSigning

Write-Host "GPG email mismatch documented in this script header." -ForegroundColor Yellow
Write-Host "Current git email: $(git config --global user.email)"
Write-Host "GPG UID email:     janet.duffy@bhhsnv.com"
Write-Host ""
Write-Host "Run gpg --edit-key to add DrDuffy@bhhsnv.com as additional UID, then verify-gpg-signing.ps1"

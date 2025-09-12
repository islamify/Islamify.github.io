# ===============================
# 🔄 Git Backup & Restore Utility
# ===============================

Write-Host "==============================="
Write-Host " 🔄 Git Backup & Restore Utility"
Write-Host "==============================="
Write-Host ""

# --- Show current repo state ---
$currentBranch = git rev-parse --abbrev-ref HEAD
$currentCommit = git log -1 --pretty=format:"%h - %s (%cr)"
$latestBackup = git tag -l "backup-pre-*" | Sort-Object { $_ } | Select-Object -Last 1
$latestCIBak = git tag -l "backup-ci-*" | Sort-Object { $_ } | Select-Object -Last 1
$latestRestore = git tag -l "restore-*" | Sort-Object { $_ } | Select-Object -Last 1

Write-Host "📍 Current branch: $currentBranch"
Write-Host "🔖 Current commit: $currentCommit"
if ($latestBackup) { Write-Host "💾 Latest manual backup tag: $latestBackup" } else { Write-Host "💾 No manual backup tags found" }
if ($latestCIBak) { Write-Host "🤖 Latest CI backup tag: $latestCIBak" } else { Write-Host "🤖 No CI backup tags found" }
if ($latestRestore) { Write-Host "♻️ Latest restore tag: $latestRestore" } else { Write-Host "♻️ No restore tags found" }
Write-Host ""

# --- Mode selection ---
Write-Host "Select mode:"
Write-Host "  1. Dry-run (no changes, preview only)"
Write-Host "  2. Force (apply changes)"
$modeChoice = Read-Host "Enter choice [1/2]"

$dryRun = $true
if ($modeChoice -eq "2") { $dryRun = $false }

if ($dryRun) {
    Write-Host "🔒 Dry-run mode: showing what would happen, no changes applied." -ForegroundColor Yellow
} else {
    Write-Host "⚡ Force mode: changes will be applied!" -ForegroundColor Red
}
Write-Host ""

# --- Helpers ---
function Prune-BackupTags {
    $allBackups = git tag -l "backup-pre-*" | Sort-Object
    if ($allBackups.Count -gt 5) {
        $oldBackups = $allBackups | Select-Object -First ($allBackups.Count - 5)
        foreach ($old in $oldBackups) {
            if ($dryRun) {
                Write-Host "Would remove old manual backup tag: $old"
            } else {
                Write-Host "🗑️ Removing old manual backup tag: $old"
                git tag -d $old
                git push origin :refs/tags/$old
            }
        }
    }
}

function Prune-RestoreTags {
    $allRestores = git tag -l "restore-*" | Sort-Object
    if ($allRestores.Count -gt 5) {
        $oldRestores = $allRestores | Select-Object -First ($allRestores.Count - 5)
        foreach ($old in $oldRestores) {
            if ($dryRun) {
                Write-Host "Would remove old restore tag: $old"
            } else {
                Write-Host "🗑️ Removing old restore tag: $old"
                git tag -d $old
                git push origin :refs/tags/$old
            }
        }
    }
}

# --- Menu ---
Write-Host "Menu:"
Write-Host "  1. List backup tags"
Write-Host "  2. Create new backup tag"
Write-Host "  3. Restore from backup tag"
Write-Host "  4. Redeploy site (restore + trigger CI)"
Write-Host "  5. Exit"
$choice = Read-Host "Enter choice [1-5]"

switch ($choice) {
    "1" {
        Write-Host "`n💾 Manual backup tags (backup-pre-*):"
        git tag -l "backup-pre-*"
        Write-Host "`n🤖 CI backup tags (backup-ci-*):"
        git tag -l "backup-ci-*"
        Write-Host "`n♻️ Restore tags:"
        git tag -l "restore-*"
    }
    "2" {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $tag = "backup-pre-$timestamp"
        if ($dryRun) {
            Write-Host "Would create manual backup tag: $tag"
            Write-Host "Would prune old manual backup tags"
        } else {
            git tag $tag
            git push origin $tag
            Write-Host "✅ Created manual backup tag: $tag"
            Prune-BackupTags
        }
    }
    "3" {
        $tag = Read-Host "Enter backup tag to restore (manual or CI)"
        Write-Host "⚠️ You are about to restore to $tag"
        $confirm = Read-Host "Proceed? (y/n)"
        if ($confirm -eq "y") {
            if ($dryRun) {
                Write-Host "Would checkout $tag"
                Write-Host "Would create restore tag"
                Write-Host "Would prune old restore tags"
            } else {
                git checkout $tag
                $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
                $restoreTag = "restore-$timestamp"
                git tag $restoreTag
                git push origin $restoreTag
                Prune-RestoreTags
                Write-Host "✅ Restored to $tag"
                Write-Host "🏷️ Created restore tag: $restoreTag"
            }
        } else {
            Write-Host "❌ Restore cancelled"
        }
    }
    "4" {
        $tag = Read-Host "Enter backup tag to redeploy (manual or CI)"
        Write-Host "⚠️ You are about to redeploy site using $tag"
        $confirm = Read-Host "Proceed? (y/n)"
        if ($confirm -eq "y") {
            if ($dryRun) {
                Write-Host "Would checkout $tag"
                Write-Host "Would create restore tag"
                Write-Host "Would prune old restore tags"
                Write-Host "Would trigger redeploy"
            } else {
                git checkout $tag
                $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
                $restoreTag = "restore-$timestamp"
                git tag $restoreTag
                git push origin $restoreTag
                Prune-RestoreTags
                git commit --allow-empty -m "♻️ Redeploy triggered from restore.ps1"
                git push origin main
                Write-Host "✅ Restored to $tag"
                Write-Host "🏷️ Created restore tag: $restoreTag"
                Write-Host "🚀 Redeploy triggered"
            }
        } else {
            Write-Host "❌ Redeploy cancelled"
        }
    }
    "5" {
        Write-Host "Exiting..."
    }
    Default {
        Write-Host "Invalid choice."
    }
}

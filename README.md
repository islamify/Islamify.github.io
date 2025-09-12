# Islamify Git Backup & Restore

This repo has both **automatic** and **manual** backup/restore tools.

---

## 🚀 Automatic (CI)

- On every push to `main`, GitHub Actions:
  - Builds & deploys the MkDocs site to GitHub Pages.
  - Creates a backup tag: `backup-ci-YYYYMMDD-HHMMSS`.
  - Prunes old tags, keeping only the last 5.

You don’t need to do anything — backups and deploys run automatically.

---

## 🛠️ Manual (restore.ps1)

Run `restore.ps1` in PowerShell for interactive options:

- **List tags**  
  Shows:
  - `backup-pre-*` → Manual backups you create.
  - `backup-ci-*` → Automatic backups created by CI.
  - `restore-*` → Restores you’ve done.

- **Create backup**  
  Creates a manual tag `backup-pre-YYYYMMDD-HHMMSS`.

- **Restore backup**  
  Restores to any `backup-pre-*` or `backup-ci-*` tag and creates a `restore-*` tag.

- **Redeploy**  
  Restores to a tag, then pushes an empty commit to trigger GitHub Pages redeploy.

- **Dry-run vs Force**  
  At startup, you choose between:
  - **Dry-run** → preview only (safe mode).
  - **Force** → actually apply changes.

---

## 🔖 Tag naming convention

- `backup-ci-*` → Created automatically by CI.  
- `backup-pre-*` → Created manually using `restore.ps1`.  
- `restore-*` → Created when you restore to a backup.  

---

## 📖 Usage Examples

### 1. Run the tool
```powershell
.\restore.ps1


# CHOOSE MODE
Select mode:
  1. Dry-run (no changes, preview only)
  2. Force (apply changes)
Enter choice [1/2]:


# PICK AN ACTION
Menu:
  1. List backup tags
  2. Create new backup tag
  3. Restore from backup tag
  4. Redeploy site (restore + trigger CI)
  5. Exit
Enter choice [1-5]:

# EXAMPLE WORKFLOWS

# Make a manual backup
Mode: Force
Choice: 2
✅ Created backup tag: backup-pre-20250911-120045


# Restore to a backup
Mode: Force
Choice: 3
Enter backup tag to restore: backup-ci-20250911-115955
✅ Restored to backup-ci-20250911-115955
🏷️ Created restore tag: restore-20250911-120215


# Redeploy the site
Mode: Force
Choice: 4
Enter backup tag to redeploy: backup-pre-20250911-120045
✅ Restored to backup-pre-20250911-120045
🚀 Redeploy triggered

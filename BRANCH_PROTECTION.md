# Branch Protection Policy

## Overview
Your Git repository is now configured with multiple layers of protection to prevent accidental commits to main/master branches.

## Current Configuration

### 1. Branch Tracking
- **newcherry** → tracks `origin/newcherry` (your fork)
- **master** → tracks `origin/master` (your fork)
- **upstream/master** → read-only reference to facefusion/facefusion (original)

**Status:** ✅ PROTECTED - Your branches now track your own fork, not upstream

### 2. Pre-Commit Hooks
Two pre-commit hooks are installed to block commits to main/master:

**Location:** `.git/hooks/`

#### Hook 1: `pre-commit` (Bash/Unix)
- Runs on Linux/Mac environments
- Checks current branch before allowing commit
- Blocks: `main`, `master`

#### Hook 2: `pre-commit.bat` (Batch/Windows)
- Runs on Windows environments (cmd.exe)
- Checks current branch before allowing commit
- Blocks: `main`, `master`

**Status:** ✅ ACTIVE - Both hooks installed and ready

### 3. Protected Branch Rules

#### Rule 1: Never Auto-Commit to main/master
```bash
# ❌ BLOCKED: Attempting to commit to master
$ git checkout master
$ git commit -m "changes"
ERROR: You are trying to commit to the 'master' branch.
This branch is protected. Please create a feature branch instead.
```

#### Rule 2: Always Use Feature Branches
```bash
# ✅ ALLOWED: Working on feature branch
$ git checkout -b feature/your-feature-name
$ git commit -m "changes"
# Success!
```

#### Rule 3: newcherry is Your Safe Branch
```bash
# ✅ ALLOWED: Direct commits to newcherry (your work branch)
$ git checkout newcherry
$ git commit -m "updates"
# Success!
```

## How It Works

### When You Try to Commit to Protected Branch:
1. Git runs pre-commit hook
2. Hook reads current branch name
3. If branch is `main` or `master`:
   - ❌ Commit is **BLOCKED**
   - 🚫 Error message displayed
   - 📝 Instructions provided for proper workflow
4. If branch is anything else (e.g., `newcherry`):
   - ✅ Commit proceeds normally

### Example Error Message:
```
ERROR: You are trying to commit to the 'master' branch.
This branch is protected. Please create a feature branch instead:

  git checkout -b feature/your-feature-name
  git commit your changes...
  git push origin feature/your-feature-name
```

## Recommended Workflow

### For Daily Development:
```bash
# 1. Work on your safe branch
git checkout newcherry

# 2. Make changes
# (edit files as needed)

# 3. Commit safely
git add .
git commit -m "Your commit message"

# 4. Push to your fork
git push origin newcherry
```

### For Experimental Features:
```bash
# 1. Create feature branch from newcherry
git checkout -b feature/experimental

# 2. Make changes and commits
git add .
git commit -m "Experimental feature"

# 3. Push to your fork
git push origin feature/experimental

# 4. When ready, merge back to newcherry
git checkout newcherry
git merge feature/experimental
git push origin newcherry
```

### For Syncing with Upstream (Read-Only):
```bash
# 1. Fetch latest from upstream (doesn't commit)
git fetch upstream

# 2. Review changes
git log upstream/master

# 3. If you want specific upstream changes, cherry-pick them
git cherry-pick <commit-hash>
```

## Multi-Layer Protection Summary

| Layer | Type | Protection | Status |
|-------|------|-----------|--------|
| 1 | Branch Tracking | newcherry tracks your fork, not upstream | ✅ Active |
| 2 | Pre-Commit Hook (Bash) | Blocks commits to main/master | ✅ Active |
| 3 | Pre-Commit Hook (Batch) | Blocks commits to main/master (Windows) | ✅ Active |
| 4 | .gitattributes | Prevents upstream overwrites of critical files | ✅ Active |
| 5 | Repository Remote | upstream is fetch-only, origin is your fork | ✅ Active |

## Testing the Protection

### Test 1: Try to Commit to master (Should Fail)
```bash
git checkout master
git commit --allow-empty -m "Test commit"
# Expected: ERROR message, commit BLOCKED
```

### Test 2: Commit to newcherry (Should Succeed)
```bash
git checkout newcherry
git commit --allow-empty -m "Test commit"
# Expected: Commit succeeds
```

### Test 3: Verify Branch Tracking
```bash
git branch -vv
# newcherry should show: [origin/newcherry] not [upstream/master]
```

## If You Need to Update Main/Master

If you ever need to update the master branch (e.g., sync with your fork's master):

```bash
# 1. Temporarily disable protection (if needed)
# - Edit `.git/hooks/pre-commit` to comment out the check
# - Or use git commit --no-verify (NOT RECOMMENDED)

# 2. Update the branch
git checkout master
git pull origin master
# Make necessary changes
git commit -m "Update master branch"
git push origin master

# 3. Re-enable protection
# - Uncomment the check in `.git/hooks/pre-commit`
# - Or just avoid using --no-verify
```

## Troubleshooting

### Q: I accidentally used `git commit --no-verify` on master. How do I fix it?

**A:** If you pushed to master by accident:
```bash
# 1. Revert the commit
git revert <commit-hash>

# 2. Or, if not pushed yet, undo it
git reset --soft HEAD~1

# 3. Go back to your safe branch
git checkout newcherry
```

### Q: Can I disable the pre-commit hook?

**A:** Yes, but it's **not recommended**:
```bash
git commit --no-verify -m "Bypass protection"
```

Better solution: Use a feature branch instead:
```bash
git checkout -b feature/your-change
git commit -m "Your change"
```

### Q: Why is newcherry tracking origin/newcherry now?

**A:** Previously it tracked `upstream/master` (the original facefusion repo). This has been changed so:
- Your `newcherry` branch only tracks changes in YOUR fork
- You maintain complete independence from upstream
- No accidental merges or syncs with the original repository

## Verification

### ✅ Current Status:
```
Branch: newcherry (tracked to origin/newcherry)
Master: Protected by pre-commit hooks
Upstream: Read-only reference only
Protection Level: MAXIMUM
```

### ✅ What This Means:
- You can safely develop on `newcherry` branch
- Commits to `master` are **BLOCKED** by git hooks
- Your work is isolated from upstream repository
- Pinokio only uses your custom newcherry branch
- No auto-commits to main can occur

## Additional Resources

- **Git Hooks Documentation:** https://git-scm.com/docs/githooks
- **Branch Tracking:** `git branch -u <upstream> <branch>`
- **Reset Branch Tracking:** `git branch -u origin/newcherry newcherry`

---

**Last Updated:** December 7, 2025
**Protection Status:** ✅ FULLY PROTECTED
**Your Safe Branch:** newcherry → origin/newcherry

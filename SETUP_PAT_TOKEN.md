# Setup Personal Access Token for GitHub Releases

## Problem
The workflow is failing with a 403 error when trying to create GitHub releases. This happens because the default `GITHUB_TOKEN` doesn't have permission to create releases.

## Solution: Create a Personal Access Token (PAT)

### Step 1: Create a Personal Access Token
1. Go to [GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. Click **"Generate new token (classic)"**
3. Give it a descriptive name like `"Password Board Release Token"`
4. Set expiration (recommend 1 year)
5. Select these scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)

### Step 2: Add Token to Repository Secrets
1. Go to your repository: **Settings → Secrets and variables → Actions**
2. Click **"New repository secret"**
3. Name: `PAT_TOKEN`
4. Value: Paste your Personal Access Token
5. Click **"Add secret"**

### Step 3: Test the Workflow
Push a commit to trigger the workflow. The release should now work!

## Why This Fixes the Issue
- The default `GITHUB_TOKEN` has limited permissions in private repositories
- A PAT with `repo` scope has full repository access including creating releases
- This is the standard solution for automated release workflows

## Security Notes
- ✅ PAT is stored securely as a repository secret
- ✅ Token is only used for release creation
- ✅ You can revoke/regenerate the token anytime
- ✅ Set reasonable expiration dates

## Alternative Solutions (if you prefer not to use PAT)
1. **Use public repository** (GITHUB_TOKEN works better in public repos)
2. **Use GitHub CLI** instead of the release action
3. **Use a different release action** that handles permissions differently

---
*Once you've added the PAT_TOKEN secret, your next workflow run should create releases successfully!* 🎉

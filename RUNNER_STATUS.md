# GitHub Actions Runner Status

## Setup Complete! ✅

Your GitHub Actions self-hosted runner has been configured and is running.

### Runner Details:
- **Location**: `C:\actions-runner`
- **Repository**: https://github.com/dionysusZ/PipelinePilot
- **Status**: Running

### To Check Runner Status:

1. **View in GitHub**:
   - Go to: https://github.com/dionysusZ/PipelinePilot/settings/actions/runners
   - You should see your runner listed with a green "Idle" or "Active" status

2. **Run the runner manually** (if needed):
   ```cmd
   cd C:\actions-runner
   run.cmd
   ```

### How to Trigger a Deployment:

**Option 1: Automatic (on git push)**
```bash
cd D:\PipelinePilot
# Make any code change
git add .
git commit -m "Update code"
git push origin main
```

**Option 2: Manual trigger from GitHub**
1. Go to: https://github.com/dionysusZ/PipelinePilot/actions
2. Click "Deploy to IIS" workflow
3. Click "Run workflow" button
4. Select "main" branch
5. Click "Run workflow"

### What Happens During Deployment:

1. ✅ Runner picks up the job
2. ✅ Checks out your code
3. ✅ Builds the project
4. ✅ Stops IIS site
5. ✅ Publishes to `D:\PipelinePilot\publish`
6. ✅ Restarts IIS site
7. ✅ Your app is live at `http://localhost:8001/weatherforecast`

### Troubleshooting:

**If runner doesn't appear in GitHub:**
- Make sure the runner process is running
- Check that the token was valid (tokens expire after 1 hour)
- Try removing and reconfiguring:
  ```cmd
  cd C:\actions-runner
  config.cmd remove --token YOUR_TOKEN
  config.cmd --url https://github.com/dionysusZ/PipelinePilot --token NEW_TOKEN
  ```

**If deployment fails:**
- Check the Actions tab on GitHub for error logs
- Verify IIS is running
- Ensure the runner has admin permissions

### Important Files Created:

- `.github/workflows/deploy-to-iis.yml` - GitHub Actions workflow
- `setup-iis.ps1` - IIS configuration script
- `open-firewall.ps1` - Firewall configuration script
- `setup-github-runner.ps1` - Runner setup script (for reference)

### Next Steps:

Your deployment pipeline is now fully automated!  Every time you push code to the main branch, it will automatically deploy to your IIS server.

**Test it now:**
1. Make a small change to your code
2. Commit and push to GitHub
3. Watch the Actions tab to see it deploy automatically
4. Access your app at `http://localhost:8001/weatherforecast`
5. Access from your phone at `http://YOUR_IP:8001/weatherforecast`

---

For more information, see [GITHUB_RUNNER_SETUP.md](GITHUB_RUNNER_SETUP.md)

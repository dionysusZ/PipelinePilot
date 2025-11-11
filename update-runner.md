# Update GitHub Actions Runner

The current runner has a version compatibility issue. Here's how to fix it:

## Step 1: Get a New Runner Token

Go to this URL:
```
https://github.com/dionysusZ/PipelinePilot/settings/actions/runners/new
```

You'll see a page with setup instructions. **Copy the TOKEN** from the configuration command (it looks like: `AXXX...`)

## Step 2: Configure the New Runner

Once you have the token, run this command:

```bash
cd C:/actions-runner-new
./config.cmd --url https://github.com/dionysusZ/PipelinePilot --token YOUR_NEW_TOKEN_HERE
```

When prompted:
- **Runner name**: Press Enter (or type a name)
- **Runner group**: Press Enter
- **Labels**: Press Enter
- **Work folder**: Press Enter

## Step 3: Start the Runner

```bash
cd C:/actions-runner-new
./run.cmd
```

Keep this window open! The runner needs to stay running.

## Step 4: Test the Deployment

Push a commit to trigger deployment:
```bash
cd D:\PipelinePilot
git commit --allow-empty -m "Test with updated runner"
git push origin main
```

## Alternative: Make It Permanent (Requires Admin)

To install as a Windows service (so it runs automatically):

1. Open Command Prompt as Administrator
2. Run:
```cmd
cd C:\actions-runner-new
.\bin\RunnerService.exe install
.\bin\RunnerService.exe start
```

Then you can close the window and the runner will keep running!

---

## Quick Command Summary:

```bash
# Get token from: https://github.com/dionysusZ/PipelinePilot/settings/actions/runners/new

# Configure
cd C:/actions-runner-new
./config.cmd --url https://github.com/dionysusZ/PipelinePilot --token YOUR_TOKEN

# Run
./run.cmd
```

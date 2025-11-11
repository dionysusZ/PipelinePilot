# GitHub Actions Self-Hosted Runner Setup

This guide will help you set up a self-hosted GitHub Actions runner on your Windows machine to deploy your PipelinePilot application to IIS.

## Why Self-Hosted Runner?

Since you're deploying to a local IIS server at `D:\PipelinePilot\publish`, you need a self-hosted runner that runs directly on your Windows machine. GitHub-hosted runners cannot access your local file system.

## Prerequisites

- Windows machine with IIS installed
- Administrator access
- GitHub repository for PipelinePilot

## Setup Steps

### 1. Go to Your GitHub Repository Settings

1. Open your GitHub repository in a browser
2. Click on **Settings** tab
3. In the left sidebar, click **Actions** → **Runners**
4. Click the **New self-hosted runner** button
5. Select **Windows** as the operating system

### 2. Download and Install the Runner

GitHub will show you a set of commands. Follow them in **PowerShell as Administrator**:

```powershell
# Create a folder for the runner
mkdir C:\actions-runner
cd C:\actions-runner

# Download the latest runner package (GitHub will provide the exact URL)
Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.xxx.x/actions-runner-win-x64-2.xxx.x.zip -OutFile actions-runner-win-x64-2.xxx.x.zip

# Extract the installer
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.xxx.x.zip", "$PWD")
```

### 3. Configure the Runner

Run the configuration script (GitHub will provide the exact token):

```powershell
.\config.cmd --url https://github.com/YOUR-USERNAME/PipelinePilot --token YOUR-TOKEN
```

When prompted:
- **Runner name**: Press Enter for default or type a name (e.g., "windows-iis")
- **Runner group**: Press Enter for default
- **Labels**: Press Enter for default
- **Work folder**: Press Enter for default

### 4. Install and Start the Runner as a Service

To run the runner automatically in the background:

```powershell
# Install as a Windows service
.\svc.sh install

# Start the service
.\svc.sh start

# Check status
.\svc.sh status
```

**Alternative: Run Interactively (for testing)**

If you prefer to run it manually for testing:

```powershell
.\run.cmd
```

### 5. Verify Runner is Connected

1. Go back to your GitHub repository
2. Navigate to **Settings** → **Actions** → **Runners**
3. You should see your runner listed with a green "Idle" status

## Important Permissions

The runner service needs:

1. **Administrator privileges** to manage IIS
2. **Read/Write access** to `D:\PipelinePilot\publish`
3. **IIS Management permissions**

### Set Service to Run as Administrator

1. Open **Services** (Win + R, type `services.msc`)
2. Find **"GitHub Actions Runner (actions-runner...)"**
3. Right-click → **Properties**
4. Go to **Log On** tab
5. Select **"Local System account"** or use your admin account
6. Click **OK**
7. Restart the service

## Workflow Configuration

The workflow file has been created at:
`.github/workflows/deploy-to-iis.yml`

### Workflow Triggers

The workflow runs automatically on:
- Push to `main` or `master` branch
- Pull requests to `main` or `master` branch
- Manual trigger (workflow_dispatch)

### Manual Trigger

To manually trigger a deployment:
1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Deploy to IIS** workflow
4. Click **Run workflow** button

## What the Workflow Does

1. Checks out your code
2. Sets up .NET 8.0
3. Restores dependencies
4. Builds the project
5. Stops the IIS site and app pool
6. Publishes to `D:\PipelinePilot\publish`
7. Updates web.config to enable logging
8. Starts the IIS site and app pool
9. Shows deployment summary

## Testing the Workflow

1. Make a small change to your code
2. Commit and push to the `main` branch:
   ```bash
   git add .
   git commit -m "Test deployment"
   git push origin main
   ```
3. Go to GitHub Actions tab to watch the deployment
4. Check your IIS site at `http://localhost:8001/weatherforecast`

## Troubleshooting

### Runner Not Starting
- Check Windows Event Viewer for errors
- Ensure the service is running in Services
- Verify the runner has admin privileges

### Deployment Fails
- Check the GitHub Actions logs for specific errors
- Verify IIS is installed and configured
- Check that the publish folder path exists
- Ensure the runner service account has permissions

### IIS Won't Stop/Start
- Make sure the runner is running as an administrator
- Check if the app pool and site names match in the workflow

## Security Considerations

1. **Never commit secrets** to the repository
2. The runner has access to your local machine - only use on trusted repositories
3. Consider using a dedicated user account for the runner service
4. Restrict access to the runner machine

## Stopping the Runner

To stop the runner service:

```powershell
cd C:\actions-runner
.\svc.sh stop
```

To remove the runner completely:

```powershell
.\svc.sh uninstall
.\config.cmd remove --token YOUR-TOKEN
```

## Next Steps

After setup:
1. Push your code to GitHub
2. Watch the Actions tab for the deployment
3. Verify the app works at `http://localhost:8001/weatherforecast`
4. Access from your phone using the IP address shown by the firewall script

---

For more information, visit: https://docs.github.com/en/actions/hosting-your-own-runners

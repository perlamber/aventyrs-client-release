# Aventyrs

Installers for the Aventyrs game client. Each release has a macOS `.dmg` (Apple Silicon) and a Windows `.exe`.

## Install (recommended)

These one-liners download the latest release and install it. Run the same line again to update.

**macOS**: open Terminal and run:

```sh
curl -fsSL https://raw.githubusercontent.com/perlamber/aventyrs-client-release/main/install.sh | bash
```

**Windows**: open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/perlamber/aventyrs-client-release/main/install.ps1 | iex
```

## Manual download

Download the file for your system from [Releases](https://github.com/perlamber/aventyrs-client-release/releases/latest).
The installers aren't signed with a paid certificate, so on first launch your system will warn you:

- **macOS**: "Apple could not verify Aventyrs…". Click **Done**, then go to
  **System Settings → Privacy & Security**, scroll down and click **Open Anyway**.
  Or, in Terminal: `xattr -dr com.apple.quarantine /Applications/Aventyrs.app`
- **Windows**: "Windows protected your PC". Click **More info → Run anyway**.

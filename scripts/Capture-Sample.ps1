<#
.SYNOPSIS
  Launch a deployed UWP sample, drive its Scenario ListBox via UI Automation,
  capture screenshots for each scenario, then close.

.PARAMETER Aumid              Full AUMID e.g. 'Microsoft.SDKSamples.Calendar.CS_8wekyb3d8bbwe!Calendar.App'
.PARAMETER PackageFamilyName  e.g. 'Microsoft.SDKSamples.Calendar.CS_8wekyb3d8bbwe'
.PARAMETER OutDir             Output directory for screenshots
.PARAMETER SampleName         e.g. 'Calendar'

  Designed to be invoked under Windows PowerShell 5.1 (powershell.exe).
#>
param(
    [Parameter(Mandatory=$true)] [string] $Aumid,
    [Parameter(Mandatory=$true)] [string] $PackageFamilyName,
    [Parameter(Mandatory=$true)] [string] $OutDir,
    [Parameter(Mandatory=$true)] [string] $SampleName
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes

if (-not ('WinNative' -as [type])) {
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;
using System.Drawing.Imaging;

public static class WinNative
{
    [DllImport("user32.dll")]
    public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, int nFlags);
    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hwnd, out RECT lpRect);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int procId);
    [DllImport("user32.dll", CharSet=CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hwnd, System.Text.StringBuilder text, int count);
    [DllImport("user32.dll")]
    public static extern IntPtr GetDesktopWindow();
    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }

    public static Bitmap CaptureWindow(IntPtr hwnd)
    {
        RECT r; GetWindowRect(hwnd, out r);
        int w = r.Right - r.Left, h = r.Bottom - r.Top;
        if (w <= 0 || h <= 0) return null;
        var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb);
        using (var g = Graphics.FromImage(bmp))
        {
            IntPtr hdc = g.GetHdc();
            bool ok = PrintWindow(hwnd, hdc, 2); // PW_RENDERFULLCONTENT
            g.ReleaseHdc(hdc);
            if (!ok) { bmp.Dispose(); return null; }
        }
        return bmp;
    }
}

[ComImport]
[Guid("2e941141-7f97-4756-ba1d-9decde894a3d")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
public interface IApplicationActivationManager
{
    int ActivateApplication([In] string appUserModelId, [In] string arguments, [In] int options, [Out] out uint processId);
    int ActivateForFile([In] string appUserModelId, IntPtr itemArray, [In] string verb, [Out] out uint processId);
    int ActivateForProtocol([In] string appUserModelId, IntPtr itemArray, [Out] out uint processId);
}

[ComImport]
[Guid("45BA127D-10A8-46EA-8AB7-56EA9078943C")]
public class ApplicationActivationManager { }

public static class AppLauncher
{
    public static uint Activate(string aumid)
    {
        var mgr = (IApplicationActivationManager)(new ApplicationActivationManager());
        uint pid;
        int hr = mgr.ActivateApplication(aumid, "", 0, out pid);
        if (hr != 0) throw new System.ComponentModel.Win32Exception(hr);
        return pid;
    }
}
"@ -ReferencedAssemblies System.Drawing
}

function Save-Bitmap([System.Drawing.Bitmap]$bmp, [string]$path) {
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

function Get-ProcessMainWindow([int]$processId) {
    # Returns the most prominent visible top-level window owned by the process or any descendant.
    # UWP windows are owned by ApplicationFrameHost.exe; we need to walk via UIA tree instead.
    $foundHwnd = [IntPtr]::Zero
    $foundArea = 0
    $cb = [WinNative+EnumWindowsProc] {
        param($hWnd, $lParam)
        if (-not [WinNative]::IsWindowVisible($hWnd)) { return $true }
        $owner = 0
        [WinNative]::GetWindowThreadProcessId($hWnd, [ref]$owner) | Out-Null
        # Either belongs to our process or is hosted by ApplicationFrameHost referencing our app
        $title = New-Object System.Text.StringBuilder 256
        [WinNative]::GetWindowText($hWnd, $title, 256) | Out-Null
        $titleStr = $title.ToString()
        if ($titleStr.Length -eq 0) { return $true }
        $r = New-Object 'WinNative+RECT'
        [WinNative]::GetWindowRect($hWnd, [ref]$r) | Out-Null
        $area = ($r.Right - $r.Left) * ($r.Bottom - $r.Top)
        if ($owner -eq $script:targetPid -or $owner -eq $script:frameHostPid) {
            if ($area -gt $script:foundArea) {
                $script:foundArea = $area
                $script:foundHwnd = $hWnd
            }
        }
        return $true
    }
    $script:targetPid = $processId
    $script:foundArea = 0
    $script:foundHwnd = [IntPtr]::Zero
    # Also collect ApplicationFrameHost PIDs (UWP windows are wrapped by it)
    $script:frameHostPid = -1
    $afh = Get-Process -Name ApplicationFrameHost -ErrorAction SilentlyContinue
    foreach ($p in $afh) {
        $script:frameHostPid = $p.Id
        [WinNative]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
    }
    if ($script:foundHwnd -eq [IntPtr]::Zero) {
        # final attempt: any window from the same pid
        $script:frameHostPid = -1
        [WinNative]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
    }
    return $script:foundHwnd
}

function Find-UwpWindowByTitle([string]$titleSubstr, [int]$timeoutSec=20) {
    $deadline = (Get-Date).AddSeconds($timeoutSec)
    while ((Get-Date) -lt $deadline) {
        $best = [IntPtr]::Zero
        $bestArea = 0
        $cb = [WinNative+EnumWindowsProc] {
            param($hWnd, $lParam)
            if (-not [WinNative]::IsWindowVisible($hWnd)) { return $true }
            $sb = New-Object System.Text.StringBuilder 256
            [WinNative]::GetWindowText($hWnd, $sb, 256) | Out-Null
            $t = $sb.ToString()
            if ($t -and ($t -like "*${script:wantTitle}*")) {
                $r = New-Object 'WinNative+RECT'
                [WinNative]::GetWindowRect($hWnd, [ref]$r) | Out-Null
                $a = ($r.Right - $r.Left) * ($r.Bottom - $r.Top)
                if ($a -gt $script:bestArea) { $script:bestArea = $a; $script:bestHwnd = $hWnd }
            }
            return $true
        }
        $script:wantTitle = $titleSubstr
        $script:bestArea = 0
        $script:bestHwnd = [IntPtr]::Zero
        [WinNative]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
        if ($script:bestHwnd -ne [IntPtr]::Zero) { return $script:bestHwnd }
        Start-Sleep -Milliseconds 500
    }
    return [IntPtr]::Zero
}

# -------- 1. Launch via IApplicationActivationManager ----------
Write-Host "[LAUNCH] $Aumid"
$pidOut = [AppLauncher]::Activate($Aumid)
Write-Host "[LAUNCH] PID=$pidOut"
Start-Sleep -Seconds 3

# -------- 2. Find the window via UIA tree (UWP runs under ApplicationFrameHost) ----------
# The DisplayName from manifest matches the window title.  We'll resolve it from the AppX install.
$pkg = Get-AppxPackage | Where-Object { $_.PackageFamilyName -eq $PackageFamilyName } | Select-Object -First 1
if ($null -eq $pkg) { throw "Package $PackageFamilyName not found." }
$manifestPath = Join-Path $pkg.InstallLocation 'AppxManifest.xml'
[xml]$mx = Get-Content $manifestPath
$displayName = $mx.Package.Applications.Application.VisualElements.DisplayName
Write-Host "[WINDOW] Expected title contains: '$displayName'"

$hwnd = Find-UwpWindowByTitle -titleSubstr $displayName -timeoutSec 25
if ($hwnd -eq [IntPtr]::Zero) {
    # fallback: try with sample name
    $hwnd = Find-UwpWindowByTitle -titleSubstr $SampleName -timeoutSec 5
}
if ($hwnd -eq [IntPtr]::Zero) { throw "Could not find main window for $SampleName" }
Write-Host "[WINDOW] hwnd=$hwnd"
Start-Sleep -Seconds 2  # give it time to fully render

# -------- 3. Capture main page ----------
[WinNative]::ShowWindow($hwnd, 9) | Out-Null  # SW_RESTORE
[WinNative]::SetForegroundWindow($hwnd) | Out-Null
Start-Sleep -Milliseconds 800
$bmp = [WinNative]::CaptureWindow($hwnd)
if ($null -ne $bmp) {
    Save-Bitmap $bmp (Join-Path $OutDir '00_main.png')
    Write-Host "[CAPTURE] 00_main.png"
} else {
    Write-Host "[CAPTURE] main page failed"
}

# -------- 4. Drive Scenario ListBox via UI Automation ----------
$scenarioTitles = @()
$capturedScenarios = 0
try {
    $rootElem = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
    if ($null -eq $rootElem) { throw "FromHandle returned null" }

    $cond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::AutomationIdProperty, 'ScenarioControl')
    $listBox = $rootElem.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $cond)
    if ($null -eq $listBox) {
        # try by AutomationProperties.Name="Scenarios"
        $cond2 = New-Object System.Windows.Automation.PropertyCondition(
            [System.Windows.Automation.AutomationElement]::NameProperty, 'Scenarios')
        $listBox = $rootElem.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $cond2)
    }
    if ($null -eq $listBox) { throw "Scenario list not found in UIA tree" }

    $itemCond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::ListItem)
    $items = $listBox.FindAll([System.Windows.Automation.TreeScope]::Children, $itemCond)
    Write-Host "[SCENARIOS] Found $($items.Count)"

    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $title = $item.Current.Name
        $scenarioTitles += $title
        Write-Host "[SCENARIO $($i+1)] $title"
        try {
            $selPattern = $item.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern)
            $selPattern.Select()
        } catch {
            try {
                $invPattern = $item.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
                $invPattern.Invoke()
            } catch {
                Write-Host "[SCENARIO $($i+1)] could not select: $_"
                continue
            }
        }
        Start-Sleep -Milliseconds 1500   # let scenario render
        $bmp = [WinNative]::CaptureWindow($hwnd)
        if ($null -ne $bmp) {
            $safe = ($title -replace '[\\/:*?"<>|]', '_').Trim()
            if ($safe.Length -gt 60) { $safe = $safe.Substring(0, 60) }
            $fn = '{0:00}_{1}.png' -f ($i+1), $safe
            Save-Bitmap $bmp (Join-Path $OutDir $fn)
            Write-Host "[CAPTURE] $fn"
            $capturedScenarios++
        }
    }
} catch {
    Write-Host "[SCENARIOS] error: $_"
}

# -------- 5. Close the app ----------
try {
    Stop-Process -Id $pidOut -Force -ErrorAction SilentlyContinue
} catch {}
# Some UWP apps may have spawned child processes; also kill by sample exe name
$exeName = $SampleName
Get-Process -Name $exeName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

# -------- 6. Output summary as JSON ----------
$result = [pscustomobject]@{
    aumid               = $Aumid
    sample              = $SampleName
    scenarios_total     = $scenarioTitles.Count
    scenarios_captured  = $capturedScenarios
    scenario_titles     = $scenarioTitles
    main_captured       = (Test-Path (Join-Path $OutDir '00_main.png'))
}
$result | ConvertTo-Json -Depth 4 | Out-File (Join-Path $OutDir 'capture.json') -Encoding UTF8
$result | ConvertTo-Json -Depth 4

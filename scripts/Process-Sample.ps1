<#
.SYNOPSIS
  End-to-end pipeline for one UWP sample:
    Build -> Deploy -> Launch -> Capture (per-scenario, with safe button invocation) -> Close -> Uninstall

.PARAMETER SamplePath
  Path to the sample's cs/ directory (contains the .csproj).

.PARAMETER OutDir
  Destination root for screenshots and capture.json (a subdir per sample).

.PARAMETER SampleName
  Logical sample name (used for filenames + UI title fallback).

.PARAMETER SkipBuild       Skip msbuild step (assume bin\x64\Debug\AppxManifest.xml already exists).
.PARAMETER SkipUninstall   Leave the appx package installed after capture (for debugging).
.PARAMETER MaxButtonsPerScenario   Max buttons to invoke inside each scenario (default 3).
.PARAMETER PerScenarioTimeoutSec   Hard wall-clock per scenario (default 25).

  Run under Windows PowerShell 5.1 (System.Drawing/UIAutomation present).
#>
param(
    [Parameter(Mandatory=$true)] [string] $SamplePath,
    [Parameter(Mandatory=$true)] [string] $OutDir,
    [Parameter(Mandatory=$true)] [string] $SampleName,
    [switch] $SkipBuild,
    [switch] $SkipUninstall,
    [int] $MaxButtonsPerScenario = 3,
    [int] $PerScenarioTimeoutSec = 25
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'  # suppress Add-AppxPackage's progress spam
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$screenshotsDir = Join-Path $OutDir 'screenshots'
New-Item -ItemType Directory -Force -Path $screenshotsDir | Out-Null
$logFile = Join-Path $OutDir 'process.log'
function Log($m) { $line = "[$(Get-Date -Format HH:mm:ss)] $m"; Write-Host $line; Add-Content -Path $logFile -Value $line }

$result = [ordered]@{
    sample                = $SampleName
    sample_path           = $SamplePath
    build                 = 'pending'
    deploy                = 'pending'
    launch                = 'pending'
    capture               = 'pending'
    uninstall             = 'pending'
    package_full_name     = $null
    package_family_name   = $null
    aumid                 = $null
    scenarios             = @()
    error                 = $null
}

# Find the .csproj — first try directly under $SamplePath, then recurse one
# level deeper (some samples nest the csproj in a subdir, e.g. XamlTailoredMultipleViews).
$csproj = Get-ChildItem -Path $SamplePath -Filter *.csproj | Select-Object -First 1
if (-not $csproj) {
    $csproj = Get-ChildItem -Path $SamplePath -Filter *.csproj -Recurse -Depth 2 |
        Where-Object { $_.FullName -notmatch '\\(obj|bin)\\' } |
        Select-Object -First 1
}
if (-not $csproj) {
    $result.error = "No .csproj found in $SamplePath"
    $result.build = 'failed'
    $result | ConvertTo-Json -Depth 6 | Out-File (Join-Path $OutDir 'result.json')
    exit 1
}

# ============ 1. BUILD ============
if (-not $SkipBuild) {
    Log "[BUILD] $($csproj.FullName)"
    $msbuild = $env:MSBUILD_PATH
    if (-not $msbuild -or -not (Test-Path $msbuild)) {
        $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
        if (Test-Path $vswhere) {
            $msbuild = & $vswhere -latest -prerelease -products * `
                -requires Microsoft.Component.MSBuild `
                -find "MSBuild\**\Bin\MSBuild.exe" | Select-Object -First 1
        }
    }
    if (-not $msbuild -or -not (Test-Path $msbuild)) {
        $result.build = 'failed'
        $result.error = "MSBuild.exe not found. Set `$env:MSBUILD_PATH or install vswhere via VS Installer."
        Log "[BUILD] FAILED: $($result.error)"
        $result | ConvertTo-Json -Depth 6 | Out-File (Join-Path $OutDir 'result.json')
        exit 1
    }
    Log "[BUILD] using msbuild: $msbuild"

    # For samples with native C++ sub-projects (.vcxproj that's not in the
    # main .csproj's restore graph), msbuild /restore on the csproj does not
    # restore packages declared in the vcxproj's packages.config. Detect this
    # and run nuget.exe restore on the parent solution first if present.
    $nativeProjects = @()
    $sampleRoot = $csproj.Directory.Parent.FullName
    if (Test-Path $sampleRoot) {
        $nativeProjects = Get-ChildItem -Path $sampleRoot -Recurse -Filter '*.vcxproj' -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch '\\(obj|bin)\\' }
    }
    if ($nativeProjects.Count -gt 0) {
        $sln = Get-ChildItem -Path $sampleRoot -Filter '*.sln' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($sln) {
            $nugetExe = $null
            $nugetCmd = Get-Command nuget.exe -ErrorAction SilentlyContinue
            if ($nugetCmd) { $nugetExe = $nugetCmd.Source }
            if (-not $nugetExe) {
                foreach ($candidate in @(
                    'C:\Users\qiutongshen\tools\nuget.exe',
                    'C:\ProgramData\chocolatey\bin\nuget.exe',
                    "$env:USERPROFILE\.nuget\nuget.exe"
                )) {
                    if (Test-Path $candidate) { $nugetExe = $candidate; break }
                }
            }
            if ($nugetExe) {
                Log "[BUILD] native sub-project(s) found; nuget restore $($sln.FullName)"
                & $nugetExe restore $sln.FullName -NonInteractive *>&1 | Tee-Object -FilePath (Join-Path $OutDir 'nuget.log') | Out-Null
                # nuget.exe restore <sln> may skip native vcxproj packages.config in some layouts (e.g.
                # vcxproj outside the sln directory). For every detected vcxproj, if a sibling
                # packages.config exists, restore it explicitly into the sln's adjacent packages\ dir.
                $slnDir = $sln.Directory.FullName
                $pkgsDir = Join-Path $slnDir 'packages'
                foreach ($vcx in $nativeProjects) {
                    $pkgsCfg = Join-Path $vcx.Directory.FullName 'packages.config'
                    if (Test-Path $pkgsCfg) {
                        Log "[BUILD] restoring vcxproj packages.config $pkgsCfg -> $pkgsDir"
                        & $nugetExe restore $pkgsCfg -PackagesDirectory $pkgsDir -NonInteractive *>&1 |
                            Tee-Object -FilePath (Join-Path $OutDir 'nuget.log') -Append | Out-Null
                    }
                }
            } else {
                Log "[BUILD] WARN: native sub-project found but nuget.exe not on PATH or known locations"
            }
        }
    }

    & $msbuild $csproj.FullName /restore /t:Build `
        /p:Configuration=Debug /p:Platform=x64 `
        /p:AppxPackageSigningEnabled=false `
        /p:AppxBundle=Never `
        /p:UseDotNetNativeToolchain=false `
        /p:UapAppxPackageBuildMode=SideloadOnly `
        /m /v:minimal /nologo *>&1 | Tee-Object -FilePath (Join-Path $OutDir 'msbuild.log') | Out-Null
    if ($LASTEXITCODE -ne 0) {
        $result.build = 'failed'
        $result.error = "msbuild exit $LASTEXITCODE, see msbuild.log"
        Log "[BUILD] FAILED exit=$LASTEXITCODE"
        $result | ConvertTo-Json -Depth 6 | Out-File (Join-Path $OutDir 'result.json')
        exit 1
    }
    $result.build = 'ok'
    Log "[BUILD] ok"
} else {
    $result.build = 'skipped'
}

$manifestPath = Join-Path $csproj.DirectoryName 'bin\x64\Debug\AppxManifest.xml'
if (-not (Test-Path $manifestPath)) {
    $result.build = 'failed'
    $result.error = "AppxManifest.xml not produced at $manifestPath"
    $result | ConvertTo-Json -Depth 6 | Out-File (Join-Path $OutDir 'result.json')
    exit 1
}

[xml]$mx = Get-Content $manifestPath
$identityName = $mx.Package.Identity.Name
$appId = $mx.Package.Applications.Application.Id
$displayName = $mx.Package.Applications.Application.VisualElements.DisplayName
if (-not $displayName) { $displayName = $mx.Package.Properties.DisplayName }

# ============ 2. DEPLOY ============
Log "[DEPLOY] Register $identityName"
try {
    Add-AppxPackage -Register $manifestPath -ForceUpdateFromAnyVersion -ErrorAction Stop
    $result.deploy = 'ok'
} catch {
    # HRESULT 0x80073CF3 = PACKAGE_FAILED_DEPENDENCY_OR_CONFLICT. Most often
    # caused by an existing package with the same Identity from a different
    # signing/version. Remove it once and retry.
    if ("$_" -match '0x80073CF3' -or "$_" -match 'updates, dependency or conflict') {
        Log "[DEPLOY] retry: removing conflicting package(s) for $identityName"
        try {
            Get-AppxPackage -Name $identityName -AllUsers -ErrorAction SilentlyContinue |
                ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue }
            Get-AppxPackage -Name $identityName -ErrorAction SilentlyContinue |
                ForEach-Object { Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue }
        } catch { Log "[DEPLOY] cleanup pre-retry: $_" }
        try {
            Add-AppxPackage -Register $manifestPath -ForceUpdateFromAnyVersion -ErrorAction Stop
            $result.deploy = 'ok'
            Log "[DEPLOY] retry OK after cleanup"
        } catch {
            $result.deploy = 'failed'
            $result.error = "Add-AppxPackage (after cleanup) failed: $_"
            Log "[DEPLOY] FAILED after cleanup: $_"
            $result | ConvertTo-Json -Depth 6 | Out-File (Join-Path $OutDir 'result.json')
            exit 1
        }
    } else {
        $result.deploy = 'failed'
        $result.error = "Add-AppxPackage failed: $_"
        Log "[DEPLOY] FAILED $_"
        $result | ConvertTo-Json -Depth 6 | Out-File (Join-Path $OutDir 'result.json')
        exit 1
    }
}

$pkg = Get-AppxPackage | Where-Object { $_.Name -eq $identityName } | Select-Object -First 1
if (-not $pkg) {
    $result.deploy = 'failed'
    $result.error = "Could not find package $identityName after register"
    $result | ConvertTo-Json -Depth 6 | Out-File (Join-Path $OutDir 'result.json')
    exit 1
}
$result.package_full_name = $pkg.PackageFullName
$result.package_family_name = $pkg.PackageFamilyName
$aumid = "$($pkg.PackageFamilyName)!$appId"
$result.aumid = $aumid
Log "[DEPLOY] PFN=$($pkg.PackageFamilyName) AppId=$appId"

# ============ Load native helpers + COM ============
Log "[INIT] loading types"
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName UIAutomationClient
Add-Type -AssemblyName UIAutomationTypes
Log "[INIT] assemblies loaded"

if (-not ('WinNative' -as [type])) {
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;

public static class WinNative
{
    [DllImport("user32.dll")] public static extern bool PrintWindow(IntPtr hwnd, IntPtr hdcBlt, int nFlags);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hwnd, out RECT lpRect);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern bool IsIconic(IntPtr hWnd);
    [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int procId);
    [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern int GetWindowText(IntPtr hwnd, System.Text.StringBuilder text, int count);
    [DllImport("user32.dll", CharSet=CharSet.Auto)] public static extern int GetClassName(IntPtr hwnd, System.Text.StringBuilder text, int count);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern uint SendInput(uint nInputs, INPUT[] pInputs, int cbSize);
    [DllImport("user32.dll")] public static extern short GetAsyncKeyState(int vKey);
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }

    [StructLayout(LayoutKind.Sequential)]
    public struct INPUT { public uint type; public InputUnion u; }
    [StructLayout(LayoutKind.Explicit)]
    public struct InputUnion {
        [FieldOffset(0)] public KEYBDINPUT ki;
    }
    [StructLayout(LayoutKind.Sequential)]
    public struct KEYBDINPUT { public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo;
        public int pad1; public int pad2; }

    public static void SendKey(ushort vk)
    {
        var down = new INPUT { type = 1, u = new InputUnion { ki = new KEYBDINPUT { wVk = vk, dwFlags = 0 } } };
        var up   = new INPUT { type = 1, u = new InputUnion { ki = new KEYBDINPUT { wVk = vk, dwFlags = 2 } } };
        SendInput(1, new INPUT[]{ down }, Marshal.SizeOf(typeof(INPUT)));
        SendInput(1, new INPUT[]{ up },   Marshal.SizeOf(typeof(INPUT)));
    }

    public static Bitmap CaptureWindow(IntPtr hwnd)
    {
        RECT r; GetWindowRect(hwnd, out r);
        int w = r.Right - r.Left, h = r.Bottom - r.Top;
        if (w <= 0 || h <= 0) return null;
        var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb);
        using (var g = Graphics.FromImage(bmp))
        {
            IntPtr hdc = g.GetHdc();
            bool ok = PrintWindow(hwnd, hdc, 2);
            g.ReleaseHdc(hdc);
            if (!ok) { bmp.Dispose(); return null; }
        }
        return bmp;
    }

    // Find all visible top-level windows whose title matches a substring (case-insensitive).
    // When preferAppFrame is true, only ApplicationFrameWindow (UWP-host) windows are returned;
    // if none match, falls back to any matching window so non-UWP apps still resolve.
    public static List<IntPtr> FindWindowsByTitle(string substr, bool preferAppFrame)
    {
        var matches = new List<IntPtr>();
        var fallback = new List<IntPtr>();
        var lower = (substr ?? "").ToLowerInvariant();
        EnumWindows((hWnd, l) => {
            if (!IsWindowVisible(hWnd)) return true;
            var sb = new System.Text.StringBuilder(256);
            GetWindowText(hWnd, sb, 256);
            var t = sb.ToString();
            if (string.IsNullOrEmpty(t) || !t.ToLowerInvariant().Contains(lower)) return true;
            var cn = new System.Text.StringBuilder(128);
            GetClassName(hWnd, cn, 128);
            var cname = cn.ToString();
            if (cname == "ApplicationFrameWindow") {
                matches.Add(hWnd);
            } else {
                fallback.Add(hWnd);
            }
            return true;
        }, IntPtr.Zero);
        if (preferAppFrame && matches.Count > 0) return matches;
        if (matches.Count > 0) return matches;
        return fallback;
    }
    public static List<IntPtr> FindWindowsByTitle(string substr) { return FindWindowsByTitle(substr, true); }

    public static List<IntPtr> TopLevelVisible()
    {
        var list = new List<IntPtr>();
        EnumWindows((hWnd, l) => {
            if (IsWindowVisible(hWnd)) {
                var sb = new System.Text.StringBuilder(64);
                GetWindowText(hWnd, sb, 64);
                if (sb.Length > 0) list.Add(hWnd);
            }
            return true;
        }, IntPtr.Zero);
        return list;
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

function Sanitize-Name([string]$n) {
    $s = ($n -replace '[\\/:*?"<>|()\[\]]', '_').Trim()
    $s = $s -replace '\s+', '_'
    $s = $s -replace '_+', '_'
    if ($s.Length -gt 50) { $s = $s.Substring(0, 50) }
    return $s
}

# Buttons whose name/content matches these (case-insensitive) are NOT invoked
$BUTTON_BLOCKLIST = @(
    'open file', 'save file', 'save as', 'pick a', 'pick file', 'pick folder',
    'choose file', 'choose folder', 'select file', 'select folder', 'browse',
    'capture photo', 'capture video', 'take photo', 'take picture',
    'start recording', 'stop recording', 'record',
    'launch', 'restart', 'shut down', 'reset device',
    'install', 'uninstall', 'remove package',
    'print', 'share', 'open in store',
    'sign in', 'sign out'
)
function Is-Blocked([string]$name) {
    if (-not $name) { return $false }
    $n = $name.ToLowerInvariant()
    foreach ($p in $BUTTON_BLOCKLIST) { if ($n.Contains($p)) { return $true } }
    return $false
}

# ============ 3. LAUNCH ============
Log "[LAUNCH] $aumid"
$pidOut = 0
$activateErr = $null
try {
    $pidOut = [AppLauncher]::Activate($aumid)
    Log "[LAUNCH] returned PID=$pidOut"
    $result.launch = 'ok'
} catch {
    $activateErr = "$_"
    Log "[LAUNCH] IApplicationActivationManager failed: $_ -- trying shell:appsFolder fallback"
    # Some apps (e.g. RadialController) reject ActivateApplication with an opaque HR
    # but launch fine via Start Menu. Use explorer.exe shell:appsFolder\<AUMID> as
    # a fallback; downstream finds the window by title, so we don't need the PID.
    try {
        Start-Process -FilePath 'explorer.exe' -ArgumentList "shell:appsFolder\$aumid" | Out-Null
        $result.launch = 'ok'
        Log "[LAUNCH] shell:appsFolder fallback OK"
    } catch {
        $result.launch = 'failed'
        $result.error = "Activate failed: $activateErr; shell fallback also failed: $_"
        Log "[LAUNCH] FAILED $_"
        $result | ConvertTo-Json -Depth 6 | Out-File (Join-Path $OutDir 'result.json')
        exit 1
    }
}
Log "[LAUNCH] sleeping 3s"
Start-Sleep -Seconds 3
Log "[LAUNCH] proceeding to find window"

# ============ 4. FIND WINDOW ============
# Many UWP samples reference DisplayName via ms-resource:* — that literal will
# never match a real window title. Build a set of candidate substrings to search:
#   1. The literal $displayName (if not an ms-resource indirection)
#   2. The $SampleName as-is (PascalCase)
#   3. The $SampleName split at CamelCase boundaries (e.g. "ApplicationResources" -> "Application Resources")
$searchTitles = New-Object System.Collections.Generic.List[string]
if ($displayName -and -not $displayName.StartsWith('ms-resource:')) {
    [void]$searchTitles.Add($displayName)
}
[void]$searchTitles.Add($SampleName)
$spaced = [regex]::Replace($SampleName, '(?<=[a-z0-9])([A-Z])', ' $1')
$spaced = [regex]::Replace($spaced, '(?<=[A-Z])([A-Z][a-z])', ' $1')
if ($spaced -ne $SampleName) { [void]$searchTitles.Add($spaced) }

$hwnd = [IntPtr]::Zero
$deadline = (Get-Date).AddSeconds(25)
while ((Get-Date) -lt $deadline -and $hwnd -eq [IntPtr]::Zero) {
    foreach ($title in $searchTitles) {
        $list = [WinNative]::FindWindowsByTitle($title)
        if ($list.Count -gt 0) {
            $hwnd = $list[0]
            $bestArea = 0
            foreach ($h in $list) {
                $r = New-Object 'WinNative+RECT'
                [WinNative]::GetWindowRect($h, [ref]$r) | Out-Null
                $a = ($r.Right - $r.Left) * ($r.Bottom - $r.Top)
                if ($a -gt $bestArea) { $bestArea = $a; $hwnd = $h }
            }
            Log "[WINDOW] matched on substring '$title'"
            break
        }
    }
    if ($hwnd -ne [IntPtr]::Zero) { break }
    Start-Sleep -Milliseconds 500
}
if ($hwnd -eq [IntPtr]::Zero) {
    $result.capture = 'failed'
    $result.error = "Could not find main window (tried: " + ($searchTitles -join ', ') + ")"
    Log "[WINDOW] FAILED"
    Stop-Process -Id $pidOut -Force -ErrorAction SilentlyContinue
    $result | ConvertTo-Json -Depth 6 | Out-File (Join-Path $OutDir 'result.json')
    exit 1
}
Log "[WINDOW] hwnd=$hwnd"
[WinNative]::ShowWindow($hwnd, 9) | Out-Null
[WinNative]::SetForegroundWindow($hwnd) | Out-Null
Start-Sleep -Seconds 2

# ============ 5. CAPTURE MAIN ============
$bmp = [WinNative]::CaptureWindow($hwnd)
if ($null -eq $bmp) {
    # First capture failed - HWND likely points at a splash/transient window
    # that has since closed. Wait and re-find the real top-level window.
    Log "[CAPTURE] hwnd=$hwnd produced null bitmap - re-finding window"
    Start-Sleep -Seconds 3
    $deadline2 = (Get-Date).AddSeconds(15)
    while ((Get-Date) -lt $deadline2) {
        $list2 = $null
        foreach ($title in $searchTitles) {
            $list2 = [WinNative]::FindWindowsByTitle($title)
            if ($list2.Count -gt 0) { break }
        }
        if ($list2 -and $list2.Count -gt 0) {
            $newHwnd = $list2[0]
            $bestArea = 0
            foreach ($h in $list2) {
                $rect = New-Object 'WinNative+RECT'
                [WinNative]::GetWindowRect($h, [ref]$rect) | Out-Null
                $a = ($rect.Right - $rect.Left) * ($rect.Bottom - $rect.Top)
                if ($a -gt $bestArea) { $bestArea = $a; $newHwnd = $h }
            }
            if ($newHwnd -ne $hwnd) {
                Log "[WINDOW] re-found hwnd=$newHwnd (was $hwnd)"
                $hwnd = $newHwnd
                [WinNative]::ShowWindow($hwnd, 9) | Out-Null
                [WinNative]::SetForegroundWindow($hwnd) | Out-Null
                Start-Sleep -Milliseconds 1500
            }
            $bmp = [WinNative]::CaptureWindow($hwnd)
            if ($null -ne $bmp) { break }
        }
        Start-Sleep -Milliseconds 1000
    }
}
if ($null -ne $bmp) {
    Save-Bitmap $bmp (Join-Path $screenshotsDir '00_main.png')
    Log "[CAPTURE] 00_main.png"
} else {
    Log "[CAPTURE] failed - bitmap still null after retry (app likely crashed during startup; check Application Event Log)"
    $result.capture = 'crashed'
    $result.error = "App window found (hwnd=$hwnd) but PrintWindow returned null after retry - app likely crashed during startup."
}

# ============ 6. ITERATE SCENARIOS ============
function Get-ScenarioFrameRoot([System.Windows.Automation.AutomationElement]$root) {
    # Try by AutomationId
    $cond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::AutomationIdProperty, 'ScenarioFrame')
    $e = $root.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $cond)
    if ($null -ne $e) { return $e }
    return $root
}

function Find-EnabledButtons([System.Windows.Automation.AutomationElement]$scope) {
    $btnCond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Button)
    $enabledCond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::IsEnabledProperty, $true)
    $and = New-Object System.Windows.Automation.AndCondition($btnCond, $enabledCond)
    return $scope.FindAll([System.Windows.Automation.TreeScope]::Descendants, $and)
}

# Names of window chrome / scrollbar / non-content buttons (any case, partial match)
$CHROME_BUTTON_PATTERNS = @(
    'minimize', 'maximize', 'restore', 'close', 'menu', 'more options',
    'system menu', 'application menu',
    # ScrollBar repeat-buttons (appear when content overflows)
    'vertical small decrease', 'vertical small increase',
    'vertical large decrease', 'vertical large increase',
    'horizontal small decrease', 'horizontal small increase',
    'horizontal large decrease', 'horizontal large increase',
    'line up', 'line down', 'line left', 'line right',
    'page up', 'page down', 'page left', 'page right',
    # Page scroll arrows  
    'scroll up', 'scroll down', 'scroll left', 'scroll right'
)
function Is-ChromeButton([string]$name) {
    if (-not $name) { return $true }   # unnamed button -> treat as chrome to be safe
    $n = $name.ToLowerInvariant()
    foreach ($p in $CHROME_BUTTON_PATTERNS) { if ($n.Contains($p)) { return $true } }
    return $false
}

function Invoke-Element([System.Windows.Automation.AutomationElement]$el) {
    try {
        $p = $el.GetCurrentPattern([System.Windows.Automation.InvokePattern]::Pattern)
        $p.Invoke(); return $true
    } catch {
        try {
            $p = $el.GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern)
            $p.Select(); return $true
        } catch { return $false }
    }
}

# When invoking a button opens a new top-level window (dialog/picker/popup), capture
# the largest visible popup before dismissing it. Returns @{ Bitmap=...; Title=... } or $null.
function Capture-LargestPopup([System.Collections.Generic.List[IntPtr]]$newHwnds) {
    if ($null -eq $newHwnds -or $newHwnds.Count -eq 0) { return $null }
    $popupHwnd = $newHwnds[0]
    $bestArea = 0
    foreach ($p in $newHwnds) {
        $r = New-Object 'WinNative+RECT'
        [WinNative]::GetWindowRect($p, [ref]$r) | Out-Null
        $a = ($r.Right - $r.Left) * ($r.Bottom - $r.Top)
        # Require a minimum size (filters out invisible/zero-rect helpers)
        if ($a -gt $bestArea -and $a -gt 5000) { $bestArea = $a; $popupHwnd = $p }
    }
    if ($bestArea -eq 0) { return $null }
    # Bring popup forward briefly so its content is painted
    [WinNative]::SetForegroundWindow($popupHwnd) | Out-Null
    Start-Sleep -Milliseconds 400
    $sb = New-Object System.Text.StringBuilder 256
    [WinNative]::GetWindowText($popupHwnd, $sb, 256) | Out-Null
    $title = $sb.ToString()
    $bmp = [WinNative]::CaptureWindow($popupHwnd)
    if ($null -eq $bmp) { return $null }
    return @{ Bitmap = $bmp; Title = $title; Hwnd = $popupHwnd }
}

# Generic fallback: when no standard ScenarioControl is found, enumerate top-level
# interactive elements (Buttons, ListItems, HyperlinkButtons) on the MainPage and
# invoke each, capturing after. Used for samples with non-standard UI patterns
# (XamlMasterDetail, XamlStateTriggers, BackgroundMediaPlayback, RadialController, ...)
function Invoke-GenericIteration([System.Windows.Automation.AutomationElement]$rootElem, [IntPtr]$hwnd, [string]$screenshotsDir, [object]$result, [int]$maxInvoke, [int]$timeoutSec) {
    Log "[GENERIC] Standard ScenarioControl not found - generic enumeration on MainPage"

    $pseudoScenario = [ordered]@{
        index           = 1
        title           = 'MainPage (generic)'
        initial_capture = '00_main.png'
        buttons         = @()
    }

    $interactive = New-Object System.Collections.ArrayList

    # 1) Enabled Buttons
    $btnCond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Button)
    $btns = $rootElem.FindAll([System.Windows.Automation.TreeScope]::Descendants, $btnCond)
    foreach ($b in $btns) {
        try { if (-not $b.Current.IsEnabled) { continue } } catch { continue }
        [void]$interactive.Add(@{ Kind='Button'; Elem=$b; Name=$b.Current.Name })
    }

    # 2) ListItems (selectable items in any list-like container; covers ListBox, ListView, GridView)
    $liCond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::ListItem)
    $lis = $rootElem.FindAll([System.Windows.Automation.TreeScope]::Descendants, $liCond)
    foreach ($li in $lis) {
        try { if (-not $li.Current.IsEnabled) { continue } } catch { continue }
        [void]$interactive.Add(@{ Kind='ListItem'; Elem=$li; Name=$li.Current.Name })
    }

    # 3) Hyperlinks
    $hyperCond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::Hyperlink)
    $hls = $rootElem.FindAll([System.Windows.Automation.TreeScope]::Descendants, $hyperCond)
    foreach ($h in $hls) {
        try { if (-not $h.Current.IsEnabled) { continue } } catch { continue }
        [void]$interactive.Add(@{ Kind='Hyperlink'; Elem=$h; Name=$h.Current.Name })
    }

    # Filter & order: drop chrome buttons, blocklist, empty names. Dedupe ONLY Buttons by name
    # (Lists/Hyperlinks often share displayed text; keep them all as separate items.)
    $seenBtnNames = @{}
    $filtered = New-Object System.Collections.ArrayList
    foreach ($it in $interactive) {
        $n = $it.Name
        if (-not $n) { $n = '<unnamed>' }
        if (Is-ChromeButton $n) { continue }
        if (Is-Blocked $n) { continue }
        if ($it.Kind -eq 'Button') {
            if ($seenBtnNames.ContainsKey($n)) { continue }
            $seenBtnNames[$n] = $true
        }
        [void]$filtered.Add($it)
    }

    Log "[GENERIC] Found $($filtered.Count) interactive element(s): $(($filtered | ForEach-Object { "$($_.Kind):$($_.Name)" }) -join ' | ')"

    $startTime = Get-Date
    $invoked = 0
    $elemIdx = 0
    foreach ($entry in $filtered) {
        $elemIdx++
        if ((Get-Date) - $startTime -gt [TimeSpan]::FromSeconds($timeoutSec)) {
            Log "[GENERIC] timeout reached"; break
        }
        if ($invoked -ge $maxInvoke) {
            Log "[GENERIC] reached max ($maxInvoke) invocations"; break
        }
        $n = if ($entry.Name) { $entry.Name } else { '<unnamed>' }
        $btnInfo = [ordered]@{ name = "$($entry.Kind): $n"; invoked = $false; skipped_reason = $null; capture = $null }

        $before = [WinNative]::TopLevelVisible()
        $ok = Invoke-Element $entry.Elem
        if (-not $ok) {
            $btnInfo.skipped_reason = 'invoke_failed'
            $pseudoScenario.buttons += $btnInfo
            continue
        }
        $btnInfo.invoked = $true
        Start-Sleep -Milliseconds 1500

        # Dismiss any new top-level window (dialog/picker) so we capture back on main.
        # Plan D: capture the popup before dismissing it.
        $after = [WinNative]::TopLevelVisible()
        $news = New-Object 'System.Collections.Generic.List[IntPtr]'
        foreach ($a in $after) { if ($before -notcontains $a -and $a -ne $hwnd) { $news.Add($a) } }
        if ($news.Count -gt 0) {
            $pop = Capture-LargestPopup $news
            if ($null -ne $pop) {
                $pfn = '01_MainPage__{0:00}_{1}_{2}__popup.png' -f $elemIdx, (Sanitize-Name $entry.Kind), (Sanitize-Name $n)
                Save-Bitmap $pop.Bitmap (Join-Path $screenshotsDir $pfn)
                $btnInfo.popup_capture = $pfn
                $btnInfo.popup_title = $pop.Title
                Log "[CAPTURE] $pfn (popup: '$($pop.Title)')"
            }
            Log "[GENERIC] '$n' opened popup, sending ESC"
            [WinNative]::SendKey([uint16]0x1B)
            Start-Sleep -Milliseconds 600
            # Restore foreground to main window so subsequent capture lands on it
            [WinNative]::SetForegroundWindow($hwnd) | Out-Null
            Start-Sleep -Milliseconds 300
            $btnInfo.skipped_reason = 'opened_popup'
        }

        $bmp = [WinNative]::CaptureWindow($hwnd)
        if ($null -ne $bmp) {
            # Include ordinal so same-named items don't overwrite each other on disk
            $fn = '01_MainPage__{0:00}_{1}_{2}.png' -f $elemIdx, (Sanitize-Name $entry.Kind), (Sanitize-Name $n)
            Save-Bitmap $bmp (Join-Path $screenshotsDir $fn)
            $btnInfo.capture = $fn
            Log "[CAPTURE] $fn"
        }
        $pseudoScenario.buttons += $btnInfo
        $invoked++
    }

    $result.scenarios = @($pseudoScenario)
    Log "[GENERIC] done - invoked=$invoked elements, captures=$(($pseudoScenario.buttons | Where-Object { $_.capture }).Count)"
}

try {
    if ($result.capture -eq 'crashed') {
        Log "[SCENARIOS] skipping - main capture marked app as crashed"
        # Drop into the catch below via a benign rethrow that won't match the generic-fallback pattern
        throw 'app crashed during startup'
    }
    $rootElem = [System.Windows.Automation.AutomationElement]::FromHandle($hwnd)
    if ($null -eq $rootElem) { throw "FromHandle returned null" }

    function Get-ScenarioList() {
        # Defensive: UIA tree can take a moment to settle after navigation.
        # If FindFirst throws (HRESULT 0x80131505 timeout) or returns null,
        # retry up to 3 times with 500 ms backoff.
        $lb = $null
        for ($attempt = 0; $attempt -lt 3; $attempt++) {
            try {
                $listCond = New-Object System.Windows.Automation.PropertyCondition(
                    [System.Windows.Automation.AutomationElement]::AutomationIdProperty, 'ScenarioControl')
                $lb = $rootElem.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $listCond)
                if ($null -eq $lb) {
                    $cond2 = New-Object System.Windows.Automation.PropertyCondition(
                        [System.Windows.Automation.AutomationElement]::NameProperty, 'Scenarios')
                    $lb = $rootElem.FindFirst([System.Windows.Automation.TreeScope]::Descendants, $cond2)
                }
                if ($null -ne $lb) { return $lb }
            } catch {
                Log "[SCENARIOS] Get-ScenarioList attempt $attempt failed: $_"
            }
            Start-Sleep -Milliseconds 500
        }
        return $lb
    }

    $listBox = Get-ScenarioList
    if ($null -eq $listBox) { throw "Scenario list not found" }

    $itemCond = New-Object System.Windows.Automation.PropertyCondition(
        [System.Windows.Automation.AutomationElement]::ControlTypeProperty,
        [System.Windows.Automation.ControlType]::ListItem)
    $items = $listBox.FindAll([System.Windows.Automation.TreeScope]::Children, $itemCond)
    $scenarioCount = $items.Count
    Log "[SCENARIOS] count=$scenarioCount"
    # Snapshot titles up front (item references may go stale after Frame navigation)
    $titles = @()
    foreach ($it in $items) { $titles += $it.Current.Name }

    for ($i = 0; $i -lt $scenarioCount; $i++) {
        $idx = $i + 1
        $title = $titles[$i]
        $safeTitle = Sanitize-Name $title
        Log "[SCENARIO $idx] $title"
        $scenarioInfo = [ordered]@{
            index           = $idx
            title           = $title
            initial_capture = $null
            buttons         = @()
        }

        # Re-fetch listbox & items each iteration to avoid stale references.
        # Defensive: navigation may briefly destroy + recreate the listbox,
        # in which case Get-ScenarioList returns null. Skip the selection
        # attempt instead of crashing the whole loop.
        $listBox = Get-ScenarioList
        if ($null -eq $listBox) {
            Log "[SCENARIO $idx] listbox not found after navigation, skipping selection"
        } else {
            try {
                $items = $listBox.FindAll([System.Windows.Automation.TreeScope]::Children, $itemCond)
            } catch {
                Log "[SCENARIO $idx] FindAll failed: $_"
                $items = $null
            }
            if ($null -ne $items -and $i -lt $items.Count) {
                try {
                    $sel = $items[$i].GetCurrentPattern([System.Windows.Automation.SelectionItemPattern]::Pattern)
                    $sel.Select()
                } catch { Log "[SCENARIO $idx] select failed: $_" }
            }
        }
        Start-Sleep -Milliseconds 1500

        # Initial capture
        $bmp = [WinNative]::CaptureWindow($hwnd)
        if ($null -ne $bmp) {
            $fn = '{0:00}_{1}__initial.png' -f $idx, $safeTitle
            Save-Bitmap $bmp (Join-Path $screenshotsDir $fn)
            $scenarioInfo.initial_capture = $fn
            Log "[CAPTURE] $fn"
        }

        # Find buttons in the scenario frame & invoke up to N (skipping blocked)
        $scenarioStart = Get-Date
        try {
            $frameRoot = Get-ScenarioFrameRoot $rootElem
            $btns = Find-EnabledButtons $frameRoot
            $btnList = @()
            foreach ($b in $btns) {
                $bn = $b.Current.Name
                if (-not $bn) { continue }
                if (Is-ChromeButton $bn) { continue }
                $btnList += @{ Name = $bn; Elem = $b }
            }
            Log "[SCENARIO $idx] buttons found: $($btnList.Count) -> $((@($btnList.Name)) -join ' | ')"

            $invoked = 0
            foreach ($entry in $btnList) {
                if ((Get-Date) - $scenarioStart -gt [TimeSpan]::FromSeconds($PerScenarioTimeoutSec)) {
                    Log "[SCENARIO $idx] scenario timeout reached"
                    break
                }
                if ($invoked -ge $MaxButtonsPerScenario) { break }
                $bn = $entry.Name
                $btnInfo = [ordered]@{ name = $bn; invoked = $false; skipped_reason = $null; capture = $null }
                if (Is-Blocked $bn) {
                    $btnInfo.skipped_reason = 'blocklist'
                    Log "[BUTTON] SKIP '$bn' (blocklist)"
                    $scenarioInfo.buttons += $btnInfo
                    continue
                }
                # Snapshot top-level windows before
                $before = [WinNative]::TopLevelVisible()
                $ok = Invoke-Element $entry.Elem
                if (-not $ok) {
                    $btnInfo.skipped_reason = 'invoke_failed'
                    $scenarioInfo.buttons += $btnInfo
                    continue
                }
                $btnInfo.invoked = $true
                Start-Sleep -Milliseconds 1500
                # If a new top-level window appeared (dialog/picker), capture it then dismiss.
                $after = [WinNative]::TopLevelVisible()
                $news = New-Object 'System.Collections.Generic.List[IntPtr]'
                foreach ($a in $after) { if ($before -notcontains $a -and $a -ne $hwnd) { $news.Add($a) } }
                if ($news.Count -gt 0) {
                    $pop = Capture-LargestPopup $news
                    if ($null -ne $pop) {
                        $pfn = '{0:00}_{1}__popup_{2}.png' -f $idx, $safeTitle, (Sanitize-Name $bn)
                        Save-Bitmap $pop.Bitmap (Join-Path $screenshotsDir $pfn)
                        $btnInfo.popup_capture = $pfn
                        $btnInfo.popup_title = $pop.Title
                        Log "[CAPTURE] $pfn (popup: '$($pop.Title)')"
                    }
                    Log "[BUTTON] '$bn' opened popup, sending ESC"
                    [WinNative]::SendKey([uint16]0x1B) # VK_ESCAPE
                    Start-Sleep -Milliseconds 600
                    [WinNative]::SetForegroundWindow($hwnd) | Out-Null
                    Start-Sleep -Milliseconds 300
                    $btnInfo.skipped_reason = 'opened_popup'
                }
                # Capture (main window still — picker dismissed)
                $bmp = [WinNative]::CaptureWindow($hwnd)
                if ($null -ne $bmp) {
                    $fn = '{0:00}_{1}__after_{2}.png' -f $idx, $safeTitle, (Sanitize-Name $bn)
                    Save-Bitmap $bmp (Join-Path $screenshotsDir $fn)
                    $btnInfo.capture = $fn
                    Log "[CAPTURE] $fn"
                }
                $scenarioInfo.buttons += $btnInfo
                $invoked++
            }
        } catch {
            Log "[SCENARIO $idx] button enumeration error: $_"
        }

        $result.scenarios += $scenarioInfo
    }
    $result.capture = 'ok'
} catch {
    # If the standard ScenarioControl wasn't found, try generic top-level enumeration
    # instead of giving up with just the main-page screenshot.
    if ("$_" -match 'app crashed during startup') {
        # Preserve the 'crashed' status set by the main-capture retry block.
        Log "[SCENARIOS] skipped (app crashed during startup)"
    } elseif ("$_" -match 'Scenario list not found') {
        try {
            Invoke-GenericIteration $rootElem $hwnd $screenshotsDir $result 8 ($PerScenarioTimeoutSec * 2)
            $result.capture = 'ok-generic'
            $result.error = $null
        } catch {
            Log "[SCENARIOS] generic fallback failed: $_"
            $result.capture = 'partial'
            $result.error = "Generic iteration: $_"
        }
    } else {
        Log "[SCENARIOS] error: $_"
        $result.capture = 'partial'
        $result.error = "Scenario iteration: $_"
    }
}

# ============ 7. CLOSE ============
try { Stop-Process -Id $pidOut -Force -ErrorAction SilentlyContinue } catch {}
$leftover = Get-Process -Name $SampleName -ErrorAction SilentlyContinue
if ($leftover) { foreach ($p in $leftover) { try { Stop-Process -Id $p.Id -Force } catch {} } }
Start-Sleep -Milliseconds 500

# ============ 8. UNINSTALL ============
if (-not $SkipUninstall) {
    Log "[UNINSTALL] $($pkg.PackageFullName)"
    try {
        Remove-AppxPackage -Package $pkg.PackageFullName -ErrorAction Stop
        $result.uninstall = 'ok'
    } catch {
        $result.uninstall = 'failed'
        Log "[UNINSTALL] failed: $_"
    }
} else {
    $result.uninstall = 'skipped'
}

# ============ 9. EMIT result.json ============
$result | ConvertTo-Json -Depth 8 | Out-File (Join-Path $OutDir 'result.json') -Encoding UTF8
$result.scenarios | ForEach-Object { "scenario $($_.index) [$($_.title)] buttons: $($_.buttons.Count)" } | Write-Host
Log "[DONE]"

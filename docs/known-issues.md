# Known issues

## Environment-broken samples (7)

These samples build and deploy fine, but UWP host crashes immediately on launch with `0xc000027b` (`STATUS_APPLICATION_FAILED_DELAYED_LOAD`).

### Root cause (revised 2026-05-25 after retest on local console)

Earlier notes attributed these crashes to RDP camera redirection / missing Surface Dial / missing background-task host. A retry on a **local console session with two physical Lenovo T27hv-30 webcams enumerable in `Get-PnpDevice -Class Camera`** still reproduced the same crashes in the same place across **all four still-broken camera samples**:

```
Faulting module name: twinapi.appcore.dll, version: 10.0.26100.8246
Exception code:       0xc000027b   (STATUS_APPLICATION_FAILED_DELAYED_LOAD)
Fault offset:         0x0000000000070a33
```

Meanwhile `Microsoft.WindowsCamera` (the built-in Camera app) launches and uses the same webcams normally on the same machine — so the system camera stack and physical hardware are fine.

What was ruled out:

- Console session (`$env:SESSIONNAME = "Console"`, not RDP)
- HKLM + HKCU `ConsentStore\webcam = Allow`, no policy override under `HKLM\SOFTWARE\Policies\...\AppPrivacy`
- `camsvc` (`Capability Access Manager Service`) running; per-user `UserDataSvc_*` running
- Manual launch via `Shell:AppsFolder!<PFN>!App` crashes with no consent UI ever shown — so it isn't the per-package consent prompt
- Two physical webcams visible to `Get-PnpDevice -Class Camera` and usable by `Microsoft.WindowsCamera`

The shared symptom across **all** affected samples: every `Package.appxmanifest` declares

```xml
<TargetDeviceFamily Name="Windows.Universal"
                    MinVersion="10.0.22621.0"
                    MaxVersionTested="10.0.22621.0" />
```

…with csproj `TargetPlatformVersion = TargetPlatformMinVersion = 10.0.22621.0`, but the host OS is build **10.0.26100** (Windows 11 24H2 / Server 2025). The fail-fast at `twinapi.appcore.dll+0x70a33` is the AppModel host failing a delayed-load import into the host `twinapi.appcore.dll`, where the WinRT activation factories the sample uses (`MediaCapture` and friends, bound against 22621 contracts) no longer line up with the 26100 export table.

So this is a **24H2 binary-compat issue with old UWP samples**, not RDP / camera privacy / Surface Dial / consent UI / background-host. RDP camera redirection is still relevant if you happen to be on an RDP session (see footnote below) but it is not the root cause on console.

### Group A — Camera samples — 24H2 binary-compat crash

Of 9 total Camera samples, **4 still crash** (one more captures the main page briefly via Plan A before crashing, one captures the main page only):

| Sample | Current state | Notes |
|---|---|---|
| `CameraAdvancedCapture`     | `crashed`     | `twinapi.appcore.dll+0x70a33` fail-fast before MainPage paints |
| `CameraFaceDetection`       | `crashed`     | same |
| `CameraStarterKit`          | `crashed`     | same |
| `CameraVideoStabilization`  | `crashed`     | same |
| `CameraManualControls`      | `partial` or `crashed` (run-to-run) | Same fail-fast; sometimes the window paints just long enough for Plan A to grab a 1-PNG main-page capture |
| `CameraGetPreviewFrame`     | `ok-generic`  | Main page captures (1 PNG); live preview can't render |
| `CameraFrames`              | `ok` (3 PNGs) | Main page is informational; no implicit MediaCapture init |
| `CameraProfile`             | `ok` (6 PNGs) | Pure metadata enumeration, no live capture |
| `CameraResolution`          | `ok` (7 PNGs) | same |

**Workaround (no upstream change)**: re-run the pipeline on a **Windows 11 22H2 host (build 22621)** that matches the samples' `MaxVersionTested`. The delayed-load resolves there.

> *RDP footnote, kept from previous notes*: if you do run over RDP, camera redirection sends the device through the `RDCamera` class (`Remote Desktop Camera Bus`), which UWP's `DeviceClass.VideoCapture` enumeration does not see. The client (mstsc) must opt into the modern camera redirection: edit the `.rdp` file to add `camerastoredirect:s:*`, then reconnect; the camera then registers under the real `Camera` PnP class on the remote side. This is **independent** of the 24H2 binary-compat crash above and only matters once that root cause is fixed.

### Group B — Other 24H2-affected (2)

| Sample | Notes |
|---|---|
| `BackgroundMediaPlayback` | Same `0xc000027b`, but faults later in `Windows.UI.Xaml.dll+0x8fa113` — window appears briefly so Plan A captures a 1-PNG main page on local console (`capture=ok-generic`). |
| `RadialController`        | Crashes in `Windows.UI.Xaml.dll`. Almost certainly needs Surface Dial / pen support; not retried on the test machine since it lacks one. |

### Suggested upstream fix (attempted, requires source changes)

Bumping `Package.appxmanifest`'s `MaxVersionTested` alone has no effect — that field in the built `AppxManifest.xml` is regenerated from the csproj's `TargetPlatformVersion` / `TargetPlatformMinVersion`, not copied from the source manifest.

A direct attempt to retarget `CameraStarterKit` to 26100 hit two cascading blockers:

1. The csproj has `<SDKReference Include="WindowsMobile, Version=$(TargetPlatformVersion)">`. The WindowsMobile Extension SDK was deprecated and only ships up to `10.0.22621`. Pointing `TargetPlatformVersion` at `10.0.26100.0` breaks the reference (`MSB3774: Could not find SDK "WindowsMobile, Version=10.0.26100.0"`).
2. Pinning the SDKReference to `10.0.22621.0` while keeping `TargetPlatformVersion=10.0.26100.0` then fails compilation at `MainPage.xaml.cs:181` with `CS0731 / CS1069` — the type `Windows.Phone.UI.Input.CameraEventArgs` (Windows 10 Mobile hardware shutter-button event) is type-forwarded but the forward target no longer exists in the 26100 umbrella `Windows` metadata.

A real fix therefore requires editing the sample source: remove or guard the `Windows.Phone.UI.Input.CameraEventArgs` (hardware camera button) handler, drop the `WindowsMobile` `SDKReference`, and likely bump `Microsoft.NETCore.UniversalWindowsPlatform` from `5.0.0` (2015) to a current version. This is upstream-sample-maintenance work, not pipeline work, and was reverted after diagnosis. The `qiutongMS/uwp-samples-standalone` `Samples/` tree is left clean.

For a reproduction matrix of what was tried:

```xml
<!-- before (crashes on 26100 at twinapi.appcore.dll+0x70a33) -->
<TargetPlatformVersion>10.0.22621.0</TargetPlatformVersion>
<TargetPlatformMinVersion>10.0.22621.0</TargetPlatformMinVersion>
<SDKReference Include="WindowsMobile, Version=$(TargetPlatformVersion)" />

<!-- attempt 1: bump both → MSB3774 (no WindowsMobile 26100 SDK) -->
<TargetPlatformVersion>10.0.26100.0</TargetPlatformVersion>
<TargetPlatformMinVersion>10.0.26100.0</TargetPlatformMinVersion>

<!-- attempt 2: pin SDKRef to 22621 → CS0731/CS1069 (Windows.Phone.UI.Input.CameraEventArgs gone) -->
<TargetPlatformVersion>10.0.26100.0</TargetPlatformVersion>
<SDKReference Include="WindowsMobile, Version=10.0.22621.0" />
```

> **Note — the dead phone code is *not* the runtime crash cause.** A controlled experiment confirmed this: in `CameraStarterKit`, removing only the `using Windows.Phone.UI.Input;` directive + the `HardwareButtons_CameraPressed` handler + the two `ApiInformation.IsTypePresent("Windows.Phone.UI.Input.HardwareButtons")` register/unregister blocks (leaving csproj `TargetPlatformVersion=22621` and NuGet `Microsoft.NETCore.UniversalWindowsPlatform 5.0.0` untouched) still compiles cleanly, produces a freshly-built `.exe` (PE timestamp changes), and crashes at the **identical** `twinapi.appcore.dll+0x70a33` on launch. The dead phone code is only a *compile-time* blocker on the SDK-upgrade path; at runtime `IsTypePresent` returns false on desktop, so the handler is never wired up. The runtime crash is the separate, deeper 22621→26100 WinRT activation-factory mismatch described above.

## Upstream patches required (4 samples)

These patches are *not* checked into `qiutongMS/uwp-samples-standalone` — they're surgical fixes to make the samples build with current SDKs. The next maintainer needs to apply them once after cloning.

### 1. `Samples/ApplicationData/cs/` — Scenarios 1-5 reference missing files

```diff
# In ApplicationData.csproj, remove:
- <Compile Include="Scenario1_HelloRoaming.xaml.cs" ... />
- <Compile Include="Scenario2_HelloLocal.xaml.cs" ... />
- ... (Scenarios 1-5)
- <Page Include="Scenario1_HelloRoaming.xaml" ... />
- ... (Scenarios 1-5)
- <Content Include="Assets\hello-globe.png" ... />
- <Content Include="Assets\hello-house.png" ... />
- <Content Include="Assets\hello-roam.png" ... />

# In SampleConfiguration.cs, keep ONLY Scenario6 + Scenario7.
# Redirect the Styles.xaml reference path to the actual location.
```

After: Scenario6 (LocalSettings) + Scenario7 (RoamingSettings) build and run cleanly.

### 2. `Samples/RadialController/cs/` — Missing font file reference

```diff
# In RadialController.csproj, remove:
- <Content Include="Assets\Symbols.ttf" />
```

(The actual font file isn't in the upstream tree.) After this the sample compiles, but it still crashes on launch — see Group B above.

### 3. `Samples/XamlMasterDetail/cs/` — Manifest filename mismatch

```diff
# In Package.appxmanifest:
- StoreLogo="Assets\StoreLogo.png"
+ StoreLogo="Assets\storelogo-sdk.png"
```

(The file is shipped as `storelogo-sdk.png`; manifest references `StoreLogo.png` which doesn't exist.)

### 4. `Samples/XamlTailoredMultipleViews/cs/` — Manifest filename mismatch + recursive csproj search

```diff
# In Package.appxmanifest:
- ...smalltile_sdk.png
+ ...smalltile-sdk.png

# In XamlTailoredMultipleViews.csproj — replace literal asset paths with a
# wildcard glob so any naming variant is picked up.
```

## Sample-specific pre-existing bugs

### `XamlBind` scenario 5 null-ref

Scenario 5 throws a `NullReferenceException` during data-binding refresh. This is a pre-existing bug in the sample itself — not the pipeline.

With **Plan D** (popup capture) timing, the bug fires earlier (at scenario 5) and we capture 16 PNGs total. Without Plan D it would get to scenario 6 but skip dialog captures entirely (~15 PNGs). Net trade-off is positive (more useful captures overall).

This is logged as `capture: partial` in `_status.csv`.

## Pipeline-design caveats

### Some samples don't use `ScenarioControl` ListBox

About 6 samples define their own MainPage instead of the SDK template. The pipeline detects this and falls back to **Plan A** (generic enumeration of Buttons/ListItems/Hyperlinks). Resulting `capture: ok-generic`. See `docs/architecture.md` for details.

### The window-class filter is opt-in

`FindWindowsByTitle` defaults to `preferAppFrame=$true` and filters to `class = ApplicationFrameWindow`. There's a fallback that accepts any class if no ApplicationFrameWindow matches the title. If a future Windows version changes the UWP host class (Win32WindowsAppRuntime, etc.), this will need updating.

### `PrintWindow` doesn't capture layered surfaces

If a sample uses `XamlCompositionBrush`, `AcrylicBrush` with backdrop, or DirectComposition surfaces, parts may capture as black/white. The fix would be to switch to **Windows.Graphics.Capture** API (WGC), which is more complex but reliable. Not yet implemented.

### Cleaning up after a crashed run

If `Run-All` is interrupted mid-sample, you might have:
- a half-deployed appx (`Add-AppxPackage -Register` succeeded but uninstall didn't run)
- an orphaned `ApplicationFrameHost.exe` instance still showing the sample

Clean up with:
```powershell
Get-AppxPackage *_8wekyb3d8bbwe* | Where-Object PackageUserInformation -match $env:USERNAME | Remove-AppxPackage
# Optionally also:
Stop-Process -Name ApplicationFrameHost -Force -ErrorAction SilentlyContinue
```

(Be careful — these patterns match Microsoft-signed UWPs in general, not just our samples. Tighten by `PublisherId` or by enumerating our specific `PackageFamilyName` list from `_status.csv` first.)

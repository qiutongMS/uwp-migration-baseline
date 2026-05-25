# Known issues

## Environment-broken samples (7)

These samples build and deploy fine, but UWP host crashes immediately on launch with `0xc000027b` (`STATUS_APPLICATION_FAILED_DELAYED_LOAD`). Cause is environmental — the system DLL the sample lazy-loads is unavailable in the current session.

### Group A — Camera samples (6) — need physical camera, RDP redirects don't satisfy

| Sample | Notes |
|---|---|
| `CameraAdvancedCapture`        | uses `MediaCapture` extension methods that require local DirectShow filters |
| `CameraFaceDetection`          | same |
| `CameraFrames`                 | same — but managed to capture 3 PNGs on some runs |
| `CameraManualControls`         | same |
| `CameraStarterKit`             | same |
| `CameraVideoStabilization`     | same |
| `CameraProfile`                | works (no live capture, just enumerates profile metadata) — 6 PNGs |
| `CameraResolution`             | works — 7 PNGs |
| `CameraGetPreviewFrame`        | ok-generic — 1 PNG (main page only; live preview can't render under RDP) |

**Workaround**: re-run on a local console session with a physical camera plugged in.

### Group B — Other env-broken (2)

| Sample | Notes |
|---|---|
| `BackgroundMediaPlayback` | Crashes in `twinapi.appcore.dll`. Probably needs a background-task host that isn't present in the current session. |
| `RadialController`        | Crashes in `Windows.UI.Xaml.dll`. Probably needs Surface Dial / pen support that the current machine lacks. |

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

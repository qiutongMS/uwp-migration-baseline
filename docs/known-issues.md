# Known issues

## M12 update — May 2026 (pipeline hardening + 5 sample fixes + LinguisticServices port)

A second pass on the 89-sample refilter baseline brought the count from
65 → 71 `ok`. Net `_status.csv` summary: **71 ok / 10 ok-generic / 6 failed / 1 pending / 1 crashed**.

### What was fixed

**Upstream patches** (committed in `qiutongMS/uwp-samples-standalone`
branch `refilter-102-samples`):

| Sample | Patch |
|---|---|
| `ApplicationResources` | `Package.appxmanifest`: `Square150x150Logo` and `Square44x44Logo` were both pointing at `Images\logo.png`, whose `contrast-*_scale-100` variants are 150×150 — wrong for `Square44x44Logo`. Manifest now references `Assets\SquareTile-sdk.png` / `Assets\SmallTile-sdk.png` (50×50 and 44×44 from `SharedContent\media`). Two new `<Content Include="$(SharedContentDir)\media\...">` items with `<Link>Assets\...</Link>` added to the csproj. |
| `NetworkConnectivity` | Removed `<uap:LockScreen BadgeLogo="Assets\smalltile-sdk.png" .../>` from the manifest — `BadgeLogo` requires a 24×24 asset; `smalltile-sdk.png` is 44×44. The lock-screen badge isn't core to the sample's demonstration. |
| `MobileHotspot` | `TargetPlatformVersion` `10.0.25336.0` (Insider-only SDK) → `10.0.26100.0`. The 22621.0 SDK doesn't expose `TetheringWiFiAuthenticationKind` which the sample uses. |
| `PersonalDataEncryption` | `TargetPlatformVersion` and `TargetPlatformMinVersion` `10.0.22000.0` → `10.0.22621.0` (the 22000.0 SDK isn't installed and isn't required by the sample's API surface). |
| `LinguisticServices` | Ported the missing C++/WinRT `RuntimeComponent\` sister project (10 files: `LinguisticServices.cpp/.h/.idl`, `RuntimeComponent.{vcxproj,vcxproj.filters,def,sln}`, `pch.{h,cpp}`, `packages.config`) from `microsoft/Windows-universal-samples` HEAD `4eb2fcb4`. The component exposes `Sample.LinguisticServices` (a C++/WinRT runtime class with `RecognizeTextLanguages` / `RecognizeTextScripts` / `TransliterateFromCyrillicToLatin` static methods) which the four C# scenarios consume via `using Sample;`. The cs csproj already had the `<ProjectReference Include="..\RuntimeComponent\RuntimeComponent.vcxproj">` line; the port just supplied the missing target. NuGet `Microsoft.Windows.CppWinRT 2.0.200615.7` is restored automatically by the pipeline's per-vcxproj `packages.config` lookup (fix #4 below). Build now succeeds; capture is `ok` with 9 PNGs across 4 scenarios. |

**Pipeline robustness fixes** (`scripts/Process-Sample.ps1`):

1. **Window-finder accepts CamelCase-spaced sample names.** Many UWP
   manifests declare `DisplayName="ms-resource:appDisplayNameCS"` —
   the literal `ms-resource:` string never matches a real window
   title. The pipeline now builds a candidate list:
   *(a)* the manifest `DisplayName` literal (if it's not an
   `ms-resource:` indirection), *(b)* the `$SampleName` as-is, and
   *(c)* a CamelCase-split variant (`ApplicationResources` →
   `Application Resources`). All three are tried each iteration of
   the 25 s find loop. Fixed `ApplicationResources` and is a
   pre-condition for any future sample whose live window title
   doesn't match the project folder name exactly.
2. **Per-scenario null-check in the iteration helper.** When a sample
   doesn't expose `ScenarioControl` or the `ListBox` doesn't enumerate,
   `FindAll(...).Select(...)` was throwing
   `You cannot call a method on a null-valued expression`. Defensive
   `$null` checks now skip cleanly. Fixed `AdvancedCasting`
   (`partial` → `ok`, 14 shots) and `HotspotAuthentication`
   (`partial` → `ok`, 3 shots).
3. **`Get-ScenarioList` retries on UIA timeout.** UI Automation
   occasionally throws `HRESULT 0x80131505 (UIA timed out)` on the
   first traversal of a freshly-launched app. We now retry up to
   3 times with a 500 ms backoff. Fixed `PlayReady`
   (`partial` → `ok`, 7 shots).
4. **Native sub-project NuGet restore (`packages.config` style).**
   Modern `nuget restore <sln>` doesn't recurse into `vcxproj`
   projects whose `packages.config` lives next to the `vcxproj`
   (rather than at the sln root). The pipeline now scans every
   detected `*.vcxproj` for a sibling `packages.config` and runs
   `nuget restore <packages.config> -PackagesDirectory <sln-dir>\packages`
   explicitly. **Fixes `CameraOpenCV.build`** (was `failed`, now `ok`).
5. **MIDI / package-conflict cleanup before re-deploy.** When
   `Add-AppxPackage -Register` returns `HRESULT 0x80073CF3` with a
   "Package failed updates, dependency or conflict validation"
   message that's *purely* a conflict (not a missing framework), we
   now `Get-AppxPackage -Name <id> | Remove-AppxPackage` both
   `-AllUsers` and current-user, then retry once.
   *(Does **not** help MIDI — see below — but is the right cleanup
   step in general.)*

### What's still not OK after M12

| Sample | State | Why |
|---|---|---|
| `CameraOpenCV` | `capture: crashed` (build / deploy / launch OK) | App crashes inside `Windows.UI.Xaml.dll+0x8fa113` immediately after the splash, exit code `0xc000027b` (STATUS_APP_CALLBACK_EXCEPTION — unhandled .NET exception in a XAML callback). Build now succeeds (NuGet restore fix), but `OpenCV.Win.*` 3.10.6.1's old `.targets` aren't fully compatible with the modern UAP build — `OpenCVBridge.dll` likely throws `DllNotFoundException` during `MainPage` activation. Not pipeline-fixable. |
| `MIDI` | `deploy: failed` | `Microsoft.Midi.GmDls` framework package is not installed on this machine. The MIDI sample's manifest declares `<PackageDependency Name="Microsoft.Midi.GmDls" />`; without the framework appx, deployment can never succeed. Not a sample bug — the framework either ships with Windows or has to be installed separately. |
| `BluetoothAdvertisement`, `BluetoothLE` | `capture: failed` | No Bluetooth adapter on this Hyper-V host. App processes never even start (`IApplicationActivationManager` returns "the app didn't start"). Pipeline window-find correctly times out. Hardware-environment-broken. |
| `MobileHotspot`, `NetworkConnectivity`, `OnDemandHotspot` | `capture: failed` | Build now OK. Apps launch but the UI thread never paints a window (no real WiFi adapter on this Hyper-V host; `OnDemandHotspot` additionally requires Microsoft's custom-capability descriptor for `Microsoft.onDemandHotspotControl`). Hardware-environment-broken. |
| `RadioManager` | `capture: failed` | Needs a `RadioManager` device class enumerable via `Windows.Devices.Radios` — none on this host. Hardware-environment-broken. |

The 7 hardware-environment-broken cases above (Bluetooth ×2, network ×3,
radio ×1, and CameraOpenCV's runtime DLL load) are environmental, not
pipeline or source bugs. Re-running on a host with a Bluetooth adapter,
a real Wi-Fi NIC, and a Surface-class Radio device should pick them up
without any pipeline change.

---

## Camera samples — FIXED upstream (5 samples)

Five Camera samples used to crash immediately on launch on Windows 11
24H2 (build 26100) with:

```
Faulting module name: twinapi.appcore.dll, version: 10.0.26100.8246
Exception code:       0xc000027b   (STATUS_APPLICATION_FAILED_DELAYED_LOAD)
Fault offset:         0x0000000000070a33
```

Affected samples: `CameraStarterKit`, `CameraAdvancedCapture`,
`CameraFaceDetection`, `CameraManualControls`, `CameraVideoStabilization`.

The fault happens before XAML loads (only ~44 modules mapped at crash
time; no `Windows.UI.Xaml.dll` yet) and reproduces both on RDP and on
a local console session.

### Root cause

Each csproj declared the deprecated WindowsMobile Extension SDK:

```xml
<ItemGroup>
  <SDKReference Include="WindowsMobile, Version=$(TargetPlatformVersion)">
    <Name>...</Name>
  </SDKReference>
</ItemGroup>
```

The `WindowsMobile` platform is deprecated and was never re-published
beyond `10.0.22621`. On Windows 11 24H2 the AppModel host fails the
delayed-load resolution for it inside `twinapi.appcore.dll+0x70a33`
before the app process can register with DCOM or initialize XAML.

### Fix (committed upstream in `qiutongMS/uwp-samples-standalone`)

Commit `7ebb7a1` removes, from each of the five samples:

1. The `<SDKReference Include="WindowsMobile, ...">` `<ItemGroup>` in
   the csproj.
2. The dead `using Windows.Phone.UI.Input;` directive.
3. The `HardwareButtons_CameraPressed` method.
4. The two `if (ApiInformation.IsTypePresent("Windows.Phone.UI.Input.HardwareButtons"))`
   register/unregister guards.
5. The two `if (ApiInformation.IsTypePresent("Windows.UI.ViewManagement.StatusBar"))`
   `HideAsync()` / `ShowAsync()` guards.

Items 2–5 are dead code paths that only ran on Windows 10 Mobile, but
they compile-blocked removing the `SDKReference` in isolation — so all
five edits land together.

`TargetPlatformVersion` (`10.0.22621.0`), `TargetPlatformMinVersion`
(`10.0.22621.0`) and `Microsoft.NETCore.UniversalWindowsPlatform`
(`5.0.0`) are intentionally **left unchanged**. The fix is code-surgery
only — no toolchain bumps required.

Verified by full build / deploy / launch / screenshot of each sample
on Windows 11 24H2; live camera preview confirmed in
`CameraStarterKit` (`Lenovo T27hv-30` redirected webcam under the
`RDCamera` PnP class on the test machine, enumerable by
`DeviceClass.VideoCapture`).

### What this fix is NOT

Earlier revisions of this document attributed the crash to a
"22621 → 26100 WinRT activation-factory binary-compat mismatch" and
proposed bumping `TargetPlatformVersion` to `10.0.26100.0` and
`Microsoft.NETCore.UniversalWindowsPlatform` to `6.2.15`. **That
hypothesis was wrong**:

- The fault is in `twinapi.appcore.dll`'s delayed-load resolver, which
  runs before any WinRT activation. The WER report shows ~44 modules
  mapped at fault time and no `Windows.UI.Xaml.dll` — there is no
  activation factory call in scope yet.
- Removing only the `WindowsMobile` `SDKReference` (and the dead
  Phone/StatusBar code that blocks its removal) with the toolchain
  pinned at `TPV=22621` / `NetCore.UWP=5.0.0` is sufficient. Verified
  end-to-end with a freshly-built `.exe` (PE timestamp changes) and
  reproducible launch + screenshot of MainPage.
- An earlier "controlled experiment" that appeared to disprove the
  code-surgery fix was contaminated by stale `bin/` and `obj/` from a
  prior NetCore.UWP 6.2.15 attempt. With a clean rebuild, code surgery
  alone is sufficient.
- Bumping `Microsoft.NETCore.UniversalWindowsPlatform` to `6.2.15`
  *introduces* a separate failure: the `FilterCoreFrameworkPayloadFromNuGet`
  target in 6.2.15 strips runtime DLLs from the build output when
  `TargetPlatformMinVersion >= 10.0.16299.0`, expecting them from a
  framework `PackageDependency`. The framework appx installs but the
  app still fails to start with `0xe0434352` very early in CLR init.
  This path was abandoned.

### Camera samples — current status

Of 9 Camera samples, **all 9 now produce useful baseline captures** on
Windows 11 24H2:

| Sample | Capture | Notes |
|---|---|---|
| `CameraStarterKit`         | `ok-generic` | MainPage paints; live preview frames render when a camera device is enumerable |
| `CameraAdvancedCapture`    | `ok-generic` | same |
| `CameraFaceDetection`      | `ok-generic` | same |
| `CameraManualControls`     | `ok-generic` | same |
| `CameraVideoStabilization` | `ok-generic` | same |
| `CameraGetPreviewFrame`    | `ok-generic` | same |
| `CameraFrames`             | `ok` (3 PNGs) | informational page; no implicit `MediaCapture` init |
| `CameraProfile`            | `ok` (6 PNGs) | metadata enumeration only |
| `CameraResolution`         | `ok` (7 PNGs) | metadata enumeration only |

> **RDP / camera-class footnote**: on the test machine the redirected
> `Lenovo T27hv-30` webcam shows up under PnP class `RDCamera`
> (`Remote Desktop Camera Bus`), and UWP's `DeviceClass.VideoCapture`
> enumeration *does* see it — `CameraStarterKit` shows live preview
> over RDP in this setup. If your RDP session predates modern camera
> redirection or you didn't opt in, the device won't enumerate and
> live preview won't render (MainPage still paints). Fix by editing
> the `.rdp` to add `camerastoredirect:s:*` and reconnecting.

## Remaining environment-broken samples (1)

This sample also crashes with `0xc000027b`, but the cause is **different**
from the `WindowsMobile` SDKRef story above and it has not been fixed in
source:

| Sample | Status | Notes |
|---|---|---|
| `BackgroundMediaPlayback` | `ok-generic` on local console; crashes on RDP | Fault is in `Windows.UI.Xaml.dll+0x8fa113`, not the AppModel host. On a console session the window paints just long enough for Plan A to capture a 1-PNG MainPage. No source change needed — this is an RDP-environment-only crash. |

> Previously this section also listed `RadialController` (needs Surface
> Dial / pen input). After the `refilter-102-samples` refresh,
> `RadialController` was dropped from the upstream sample list and is no
> longer part of this baseline.

## New failure categories from the 102-sample refresh

When the upstream sample set grew from 38 → 89 (the `refilter-102-samples`
branch), four new failure shapes appeared. None of them invalidate the
baseline — each row in `_status.csv` accurately reflects how far the
pipeline got — but they are worth recording so the next maintainer
knows what's surgical vs. what's environmental.

### Build failures — 6 samples (`capture: pending`, `build: failed`)

| Sample | Cause |
|---|---|
| `CameraOpenCV` | Native sub-project `OpenCVBridge.vcxproj` needs the `OpenCV.Win.Core.310.6.1` NuGet package. `msbuild /restore` only restores the C# top-level project, not the C++ sub-project, so the build fails before reaching code generation. Recoverable by running `nuget restore` (Classic) against the `.sln` first, or by adding a top-level `<RestoreSources>`/`PackageReference` shim. Not yet automated. |
| `ApplicationResources` | `Package.appxmanifest` references `Images\logo.png` for `Square44x44Logo`, but `shared/images/logo.contrast-*_scale-100.png` has the wrong dimensions. Upstream content bug in the vendored shared assets. |
| `LinguisticServices`, `MobileHotspot`, `NetworkConnectivity`, `PersonalDataEncryption` | Build fails due to other missing or mis-pathed shared assets / resources. Not investigated in depth; treat as build-time content bugs analogous to the four upstream patches already applied (see "Upstream patches" below). |

### Capture failures — 4 samples (`capture: failed`, `build`/`deploy`/`launch: ok`)

The app launches successfully but the pipeline's `FindWindowsByTitle`
fails because the running window's title doesn't match the canonical
`"<SampleName> C# Sample"` / `"<SampleName> C# SDK Sample"` format the
pipeline expects:

- `BluetoothAdvertisement` — actual title: `"Bluetooth Advertisement C# Sample"` (extra space)
- `BluetoothLE` — actual title: `"Bluetooth Low Energy C# sample"` (different capitalization + wording)
- `OnDemandHotspot` — actual title: differs from `"OnDemandHotspot C# Sample"`
- `RadioManager` — actual title: differs from `"RadioManager C# SDK Sample"`

Recoverable by adding a `<SampleName, ActualTitle>` mapping to
`Process-Sample.ps1` or by relaxing the title match to substring /
`StartsWith`. Not yet implemented.

### Partial captures — 3 samples (`capture: partial`)

Plus the existing `XamlBind` scenario-5 case documented below.

- `AdvancedCasting` — null-ref during `Invoke-ScenarioIteration`
- `HotspotAuthentication` — same shape (null-ref during scenario iteration)
- `PlayReady` — UIA `FindFirst` exception during scenario walk; got some scenarios before the failure

These are mid-iteration faults: the pipeline captured the main page and
some scenarios before the loop crashed. The errors look pipeline-side
(null-ref in PS) rather than app-side, so the right fix is in the
iteration helper, not the samples.

### Deploy failure — 1 sample (`capture: pending`, `deploy: failed`)

- `MIDI` — `Add-AppxPackage -Register` fails with HRESULT `0x80073CF3`
  (PACKAGE_DEPLOYMENT_FAILED — likely an identity/signing conflict with
  a previous deployment of the same `PackageFamilyName`). Workaround:
  fully remove any pre-existing `MIDI*` packages
  (`Get-AppxPackage *MIDI* | Remove-AppxPackage`) before re-running.

## Upstream patches (now committed)

Four samples had build-time issues from missing referenced files in the
standalone repo's vendored `SharedContent`. These are now fixed upstream
in commit `920b26c` of `qiutongMS/uwp-samples-standalone`. The next
maintainer does **not** need to re-apply them after cloning.

For reference, the four patches were:

1. **`Samples/ApplicationData/cs/`** — Scenarios 1–5 referenced
   `.xaml`/`.xaml.cs` files that aren't in the upstream tree. The
   csproj and `SampleConfiguration.cs` were trimmed to keep only
   Scenarios 6 (`ClearScenario`) and 7 (`SetVersion`). The
   `Styles.xaml` reference was redirected from the missing local
   `..\shared\Styles.xaml` to `$(SharedContentDir)\xaml\Styles.xaml`.
   Three asset PNG references (`appDataLocal.png`,
   `appDataRoaming.png`, `appDataTemp.png`) were dropped because the
   sources aren't in the vendored shared content.

2. **`Samples/RadialController/cs/`** — dropped the `Content` reference
   to `$(SharedContentDir)\js\Microsoft.WinJS\fonts\Symbols.ttf`; the
   WinJS fonts directory isn't part of the vendored shared content.
   (The sample now compiles, but still crashes on launch — see the
   "Remaining environment-broken samples" table above.)

3. **`Samples/XamlMasterDetail/cs/Package.appxmanifest`** — fixed
   `<Logo>` filename from `Assets\StoreLogo.png` to
   `Assets\storelogo-sdk.png` to match the file actually present in
   the project's `Assets/` folder.

4. **`Samples/XamlTailoredMultipleViews/cs/.../Package.appxmanifest`** —
   fixed `Square44x44Logo` filename from `Assets\smalltile_sdk.png` to
   `Assets\smalltile-sdk.png` (underscore → hyphen) to match the file
   on disk.
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

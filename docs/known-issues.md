# Known issues

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

## Remaining environment-broken samples (2)

These also crash with `0xc000027b`, but the cause is **different** from
the `WindowsMobile` SDKRef story above and they have not been fixed in
source:

| Sample | Status | Notes |
|---|---|---|
| `BackgroundMediaPlayback` | `ok-generic` on local console; crashes on RDP | Fault is in `Windows.UI.Xaml.dll+0x8fa113`, not the AppModel host. On a console session the window paints just long enough for Plan A to capture a 1-PNG MainPage. No source change needed — this is an RDP-environment-only crash. |
| `RadialController` | `crashed` everywhere tested | Needs a Surface Dial / pen input device. Not retested with one. |

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

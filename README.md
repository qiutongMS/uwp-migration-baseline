# uwp-migration-baseline

A PowerShell-based pipeline that **builds, deploys, launches, screenshots and uninstalls** every C# UWP sample in a target repo so the captured artifacts can serve as a **behavioral baseline** for a future architecture migration.

The pipeline was originally written against
[`qiutongMS/uwp-samples-standalone`](https://github.com/qiutongMS/uwp-samples-standalone) (89 samples on the `refilter-102-samples` branch), but the scripts are generic — point them at any directory of UWP sample projects and they will iterate.

## What you get out of it

For each sample, in a single per-sample folder, you get:

- `info.md` — human-readable summary: purpose, scenarios (from README), namespaces used, build / deploy / capture / uninstall status, **main-page screenshot**, per-scenario UI elements, code behavior, **initial + after-click + dialog/popup screenshots**.
- `static.json` — machine-readable static-analysis result.
- `result.json` — machine-readable runtime result (every step, every screenshot path).
- `msbuild.log` / `process.log` / `_run_stdout.log` / `_run_stderr.log` — diagnostics.
- `screenshots/*.png` — PNGs (`00_main.png`, `NN_<scenario>__initial.png`, `NN_<scenario>__after_<button>.png`, `NN_<scenario>__popup_<button>.png`).

At the repo level you also get `_index.md`, `_status.csv`, and `_progress.log` for batch overviews.

## Where is the baseline I just captured?

The last full batch (89 samples, 508 PNGs) is checked into [`baseline/`](baseline/). Start at [`baseline/_index.md`](baseline/_index.md) for the per-sample table.

If you want to **reproduce** the baseline (or re-run after the migration), follow [Quickstart](#quickstart) below — the scripts will regenerate this entire `baseline/` directory.

## Status as of last full batch (89 samples)

| Capture state | Count | Meaning |
|---|---:|---|
| `ok`            | 71 | Standard scenario iteration succeeded end-to-end |
| `ok-generic`    | 10 | No standard `ScenarioControl` found → fell back to enumerating main-page Buttons/ListItems/Hyperlinks (Plan A) |
| `failed`        | 6  | App launched but the UI thread never paints a window — all six are hardware-environment-broken on the test host (`BluetoothAdvertisement`, `BluetoothLE` — no Bluetooth adapter; `MobileHotspot`, `NetworkConnectivity`, `OnDemandHotspot` — no real Wi-Fi NIC / Hotspot capability; `RadioManager` — no enumerable `RadioManager` device). Build / deploy / launch all OK; capture times out because the app doesn't render. |
| `pending`       | 1  | Build / deploy failed before reaching capture: `MIDI` (manifest declares `<PackageDependency Name="Microsoft.Midi.GmDls" />`; that framework appx is not installed on the host). |
| `crashed`       | 1  | `CameraOpenCV` — build/deploy/launch OK, but the app crashes inside `Windows.UI.Xaml.dll` (`0xc000027b`) immediately after splash. `OpenCV.Win.* 3.10.6.1` native bindings load but their old `.targets` aren't fully compatible with the modern UAP build. Not pipeline-fixable. |

550 PNG screenshots total. See [`docs/known-issues.md`](docs/known-issues.md) for the env-broken-sample list and the recipe (now committed upstream) that fixed the 5 Camera samples previously in this bucket.

## Prerequisites

- Windows 11 (10.0.22000+)
- Visual Studio 2022 (Community / Pro / Enterprise) with the **Universal Windows Platform development** workload
- Windows SDK 10.0.22621 *and* 10.0.26100 (samples reference both)
- PowerShell 7+ (host) **and** Windows PowerShell 5.1 (the Process-Sample script invokes it for `System.Drawing.Common` compatibility)
- Developer Mode ON  (`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\AllowDevelopmentWithoutDevLicense = 1`) and `AllowAllTrustedApps = 1`
- `Microsoft.VCLibs.140.00.Debug` installed system-wide (needed for unsigned Debug `Add-AppxPackage -Register`). Install once via VS or via the [VCLibs Debug appx](https://learn.microsoft.com/en-us/troubleshoot/developer/visualstudio/cpp/libraries/c-runtime-packages-desktop-bridge#how-to-install-and-update-desktop-framework-packages).
- Run from a **local/console session, not RDP**, if you want camera samples to work — 6 of them depend on hardware that RDP redirects don't satisfy.

## Quickstart

```powershell
# 1) Clone this repo
git clone <this-repo> uwp-migration-baseline
cd uwp-migration-baseline

# 2) Clone the source samples repo (or use your own)
cd ..
git clone https://github.com/qiutongMS/uwp-samples-standalone.git

# 3) Apply upstream patches (one-time)
#    See docs/known-issues.md for the surgical csproj/manifest patches you need
#    in 4 specific samples. The rest work as-is.

# 4) Run all samples
cd uwp-migration-baseline
pwsh -File .\scripts\Run-All.ps1 `
    -SamplesRoot 'C:\path\to\uwp-samples-standalone\Samples' `
    -OutRoot 'C:\path\to\uwp-samples-analysis'
```

## Run a single sample

```powershell
pwsh -File .\scripts\Run-All.ps1 `
    -SamplesRoot 'C:\path\to\uwp-samples-standalone\Samples' `
    -OutRoot 'C:\path\to\uwp-samples-analysis' `
    -Filter 'XamlMasterDetail'
```

The script merges into the existing `_status.csv` — it will not wipe rows for other samples.

## Docs map

| File | Purpose |
|---|---|
| [`docs/architecture.md`](docs/architecture.md) | Pipeline phases, key design decisions, the two adaptive fallbacks (Plan A / Plan D) |
| [`docs/output-format.md`](docs/output-format.md) | Schemas for `static.json`, `result.json`, `info.md` |
| [`docs/runbook.md`](docs/runbook.md) | Day-to-day operations: fresh run, retry single, debug a failure, regenerate info.md only |
| [`docs/known-issues.md`](docs/known-issues.md) | Env-broken samples, upstream patches required, pre-existing bugs |
| [`HANDOVER.md`](HANDOVER.md) | Full handover for the next maintainer — context, why decisions were made, what's left |

## License & attribution

Pipeline scripts: free to copy/modify. Sample sources are property of their original owners (Microsoft Windows-universal-samples). Captured screenshots are derivatives of those samples.

# uwp-migration-baseline

A PowerShell-based pipeline that **builds, deploys, launches, screenshots and uninstalls** every C# UWP sample in a target repo so the captured artifacts can serve as a **behavioral baseline** for a future architecture migration.

The pipeline was originally written against
[`qiutongMS/uwp-samples-standalone`](https://github.com/qiutongMS/uwp-samples-standalone) (38 samples), but the scripts are generic — point them at any directory of UWP sample projects and they will iterate.

## What you get out of it

For each sample, in a single per-sample folder, you get:

- `info.md` — human-readable summary: purpose, scenarios (from README), namespaces used, build / deploy / capture / uninstall status, **main-page screenshot**, per-scenario UI elements, code behavior, **initial + after-click + dialog/popup screenshots**.
- `static.json` — machine-readable static-analysis result.
- `result.json` — machine-readable runtime result (every step, every screenshot path).
- `msbuild.log` / `process.log` / `_run_stdout.log` / `_run_stderr.log` — diagnostics.
- `screenshots/*.png` — PNGs (`00_main.png`, `NN_<scenario>__initial.png`, `NN_<scenario>__after_<button>.png`, `NN_<scenario>__popup_<button>.png`).

At the repo level you also get `_index.md`, `_status.csv`, and `_progress.log` for batch overviews.

## Status as of last full batch (38 samples)

| Capture state | Count | Meaning |
|---|---:|---|
| `ok`            | 24 | Standard scenario iteration succeeded end-to-end |
| `ok-generic`    | 6  | No standard `ScenarioControl` found → fell back to enumerating main-page Buttons/ListItems/Hyperlinks (Plan A) |
| `partial`       | 1  | Got some scenarios then hit a sample-specific bug (XamlBind scenario 5 has a pre-existing null-ref) |
| `failed` / `crashed` | 7 | UWP launched but immediately crashed with `0xc000027b` (system DLL delayed-load failure) — needs a physical/console session, not RDP |

281 PNG screenshots total. See [`docs/known-issues.md`](docs/known-issues.md) for the env-broken-sample list.

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

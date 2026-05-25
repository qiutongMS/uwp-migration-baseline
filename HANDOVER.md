# Handover

This document gives the next maintainer the **why** behind decisions, not just the **what**.

## The real goal

Establish a **behavioral baseline** for ~38 UWP C# samples so that, after a future architecture migration (e.g. WinUI 3 / WindowsAppSDK / .NET 8+), the same samples can be re-baselined and compared image-for-image and behavior-for-behavior against the originals.

The deliverable per sample is `info.md` plus a `screenshots/` directory. Both are checked into [`baseline/`](baseline/) in this repo — the last full batch (38 samples, 281 PNGs, 12.8 MB) is preserved there as the reference baseline.

## Why a custom pipeline (not just `msbuild`)

- These samples ship as ~38 separate `csproj` projects, each producing a UWP appx. You need to *deploy*, *launch*, *navigate scenarios*, *screenshot*, *uninstall* — `msbuild` alone gets you nowhere past compile.
- UI Automation + `PrintWindow` was the only way to get reliable, headless-friendly captures across all sample patterns.
- One samples in 6 (~17%) uses a non-standard MainPage instead of the SDK ScenarioControl pattern → required a generic enumeration fallback (Plan A).

## Pipeline at a glance

```
For each sample directory containing a "cs/" subdir:
  1. Analyze-Sample.ps1   (PS7)   → static.json + draft info.md
  2. Process-Sample.ps1   (PS5.1) → build → register-deploy → launch
                                  → find ApplicationFrameWindow
                                  → screenshot main
                                  → iterate scenarios (ScenarioControl OR Plan A fallback)
                                  → screenshot per scenario (initial + after each safe button + Plan D popup)
                                  → close + uninstall
                                  → result.json
  3. Run-All.ps1's Compose-Info  → merge static.json + result.json → info.md
  4. Append row to _status.csv + _index.md
```

## Plan A (generic enumeration) — why and when

**Trigger**: UI Automation can't find an element with `AutomationId=ScenarioControl` on the launched window.

**What it does**: Enumerates all top-level `Button`, `ListItem` and `Hyperlink` AutomationElements on the main page, filters chrome (back/min/max/close), dedupes buttons by name only (NOT list items — they often share displayed text), invokes up to 8 of them in turn, captures after each.

**Where**: `Process-Sample.ps1` → `Invoke-GenericIteration` function.

**Why this design**:
- Samples like `XamlMasterDetail`, `XamlStateTriggers`, `XamlTailoredMultipleViews` don't have a ScenarioControl ListBox; they ARE the demo.
- The `ApplicationFrameWindow` window class filter is critical — without it, `FindWindowsByTitle` matches my own PowerShell terminal which echoed the sample name in its title.
- Filename pattern `01_MainPage__{NN}_{Kind}_{Name}.png` uses ordinal index because XamlMasterDetail's 4 list items all return `MasterDetailApp.ViewModels.ItemViewModel` from `Name` (ViewModel doesn't override ToString).

## Plan D (popup capture) — why and when

**Trigger**: After invoking a button, a new top-level window appears (Open dialog, Save As dialog, Folder Picker, etc.).

**What it does**: Detects the new largest visible popup by area, brings it forward, screenshots it, **then** sends ESC to dismiss it before continuing.

**Where**: Helper function `Capture-LargestPopup` in `Process-Sample.ps1`. Wired into both the standard scenario iteration loop AND the Plan A loop.

**Why this design**:
- Without it, samples like `FilePicker`, `FileAccess`, `FolderEnumeration`, `Clipboard` would show *only the main page* — the actual content (the dialog itself) was being dismissed before we screenshot.
- `area > 5000 px²` filter excludes invisible helper windows.
- `SetForegroundWindow(popup) + 400ms` is needed before capturing so the dialog content has been painted.
- After dismissal, `SetForegroundWindow(main) + 300ms` restores focus to the sample window so subsequent scenarios still work.

## Why two PowerShell versions

- `System.Drawing.Common` (used for `PrintWindow` + PNG encoding) is unreliable in PS7 on Windows because PS7 ships its own `System.Drawing.Common` that fights Windows GDI+.
- Solution: `Run-All.ps1` runs in PS7 (host), but it shells out to `Process-Sample.ps1` via **Windows PowerShell 5.1** (`powershell.exe`), which uses the in-box GDI+ binding that works.

## Why `Add-AppxPackage -Register` instead of building an appxbundle

- We don't need a signed package for one-shot screenshotting; the register-from-manifest path is faster and avoids cert provisioning.
- Requires `AppxPackageSigningEnabled=false`, `UseDotNetNativeToolchain=false`, `AppxBundle=Never` (configured in Process-Sample.ps1).

## Known regressions / open questions

1. **`XamlBind` scenario 5 null-ref**: Pre-existing sample bug (not pipeline bug). Plan D timing shifted *when* the bug fires (used to get to scenario 6, now only 5). Net: still better than the original baseline.
2. **`Package` flipped from `ok-generic/1` → `ok/6`** between batches in an earlier session. Probably a UIA-find timing thing. Not investigated.
3. **`maxInvoke=8` in Plan A** is somewhat arbitrary. Lower numbers miss content; higher numbers risk timeout.

## What this repo intentionally doesn't contain

- The upstream sample sources (`uwp-samples-standalone/`) — that's a separate repo.
- Build artifacts (`bin/`, `obj/`) — they're regenerated on each run.
- Per-run diagnostics (`msbuild.log`, `process.log`, `_run_*.log`) — stripped from `baseline/` because they're noisy and don't help baseline comparison.

The 281 captured PNGs and 38 `info.md` files **are** included under [`baseline/`](baseline/) as the reference baseline.

## File layout

```
uwp-migration-baseline/
├── README.md                  ← Start here
├── HANDOVER.md                ← This file
├── scripts/
│   ├── Run-All.ps1            ← Master orchestrator (PS7). One-stop entry point.
│   ├── Process-Sample.ps1     ← Per-sample build+deploy+launch+capture+uninstall. PS5.1.
│   ├── Analyze-Sample.ps1     ← README/XAML/.cs static analysis → static.json.
│   └── Capture-Sample.ps1     ← Legacy standalone screenshot helper (kept for reference).
├── docs/
│   ├── architecture.md        ← Pipeline phases, decisions, data flow
│   ├── output-format.md       ← JSON / Markdown schemas
│   ├── runbook.md             ← Common operations
│   └── known-issues.md        ← Env-broken samples + required upstream patches
├── baseline/                  ← The actual captured baseline (281 PNGs, 38 info.md, 12.8 MB)
│   ├── README.md              ← How to read this baseline; status summary
│   ├── _index.md              ← Per-sample table with links + status
│   ├── _status.csv            ← Machine-readable status row per sample
│   ├── _progress.log          ← Phase-transition log from the batch run
│   └── <Sample>/              ← One directory per sample
│       ├── info.md            ← The main per-sample artifact
│       ├── static.json        ← Static-analysis output
│       ├── result.json        ← Runtime output (which scenarios, which screenshots)
│       └── screenshots/*.png  ← All captures for this sample
└── .gitignore
```

## If you're picking this up cold

1. Read `README.md` first (5 min) — understand the goal and quickstart.
2. Read `docs/architecture.md` (10 min) — understand the phases.
3. Read `docs/known-issues.md` (5 min) — know which 7 samples won't work without hardware and which 4 samples need upstream patches.
4. Try running one sample end-to-end with `-Filter 'Calendar'` (should produce 6 PNGs and an `info.md` in ~2 minutes).
5. If that works, run the full batch (~30-45 minutes).
6. Skim `docs/runbook.md` for "how do I retry / debug / regen-only?" recipes.

## Future ideas (not yet attempted)

- Replace PrintWindow with WGC (Windows Graphics Capture) for layered/transparent windows.
- Auto-detect "this sample needs hardware" up front and mark skip-with-reason instead of running and crashing.
- Detect more dialog types (e.g. MessageDialog, ContentDialog with custom chrome).
- Compare two `info.md` baselines automatically and produce a diff report — the actual migration-verification step.

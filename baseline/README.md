# Baseline (captured 2026-05-25, expanded 2026-05-27, M13 expansion 2026-06-12)

This directory is the **reference baseline**: 96 UWP C# samples captured before any architecture migration. After the migration, re-run the pipeline (see top-level [`README.md`](../README.md)) and diff against this directory to verify behavioral parity.

## Read this first

Open [`_index.md`](_index.md) for the full table. Each row links to a per-sample `info.md`.

## Summary

| Capture state | Samples | PNGs |
|---|---:|---:|
| `ok` (standard scenario iteration)         | 78 | 702 |
| `ok-generic` (main-page enumeration fallback) | 10 | 13 |
| `failed` (window-title mismatch or runtime iteration null-ref) | 6 | 0 |
| `crashed` (deploy/launch broke — env or asset) | 1 | 0 |
| `pending` (not yet attempted)                | 1 | 0 |
| **Total**                                    | **96** | **715** |

See `../docs/known-issues.md` for which samples are env-broken and why.

### Schema note (multi-app samples)
Most samples are single-app: row name = sample folder name (e.g. `Accelerometer`).
Two samples ship multiple UWP apps in one tree — each app becomes its own baseline row using the form `<Sample>_<SubAppName>`:

| Sample              | Apps captured                                            |
|---------------------|----------------------------------------------------------|
| `AppServices`     | `AppServices_AppServicesClient` + `AppServices_AppServicesProvider` |
| `AudioCategory`   | `AudioCategory_AudioCategory` + `AudioCategory_AudioCategoryCompanion` |

## Per-sample directory contents

| File | What it is |
|---|---|
| `info.md`     | Human-readable summary. **Start here.** |
| `static.json` | Static analysis: scenarios, controls, handlers, namespaces |
| `result.json` | Runtime result: every step, every screenshot path |
| `screenshots/*.png` | The actual captures |

## Repo-level files

| File | What it is |
|---|---|
| `_index.md`    | Markdown table of all 96 samples with status + links |
| `_status.csv`  | Machine-readable status — one row per sample |
| `_progress.log` | Timestamped phase-transition log from the batch run |

## What's NOT in here

Per-run diagnostics (`msbuild.log`, `process.log`, `_run_stdout.log`, `_run_stderr.log`) were stripped because they're noisy and not useful for baseline comparison. To regenerate them, re-run the pipeline against a fresh `OutRoot`.

## To compare against this baseline after migration

```powershell
# 1. Re-run the pipeline on the migrated samples
pwsh -File ..\scripts\Run-All.ps1 `
    -SamplesRoot 'C:\path\to\migrated-samples\Samples' `
    -OutRoot 'C:\path\to\post-migration-baseline'

# 2. Diff the post-migration output against this baseline
#    For now: visual review of screenshots + manual info.md comparison.
#    Future: an automated comparator that reports per-sample regressions.
```

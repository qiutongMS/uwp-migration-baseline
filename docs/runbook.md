# Runbook

Day-to-day operations.

## Fresh full run

```powershell
pwsh -File .\scripts\Run-All.ps1 `
    -SamplesRoot 'C:\path\to\uwp-samples-standalone\Samples' `
    -OutRoot 'C:\path\to\uwp-samples-analysis'
```

Takes 30-60 minutes for 38 samples. Watch `_progress.log` while it runs.

## Retry / re-run a single sample

```powershell
pwsh -File .\scripts\Run-All.ps1 `
    -SamplesRoot 'C:\...\Samples' `
    -OutRoot 'C:\...\uwp-samples-analysis' `
    -Filter 'XamlBind'
```

Only `XamlBind`'s row in `_status.csv` will be updated — the other 37 are preserved. `_index.md` is also incrementally updated.

## Re-analyze (static) without running anything

```powershell
pwsh -File .\scripts\Run-All.ps1 `
    -SamplesRoot 'C:\...\Samples' `
    -OutRoot 'C:\...\uwp-samples-analysis' `
    -OnlyAnalyze
```

Faster for iterating on the static analyzer.

## Skip build, reuse the existing `AppxManifest.xml` in `bin\x64\Debug\`

```powershell
pwsh -File .\scripts\Run-All.ps1 ... -SkipBuild
```

## Regenerate `info.md` after editing the Compose-Info template (no re-run)

Compose-Info is defined inside `Run-All.ps1`. Dot-source it and iterate over existing JSON outputs:

```powershell
. .\scripts\Run-All.ps1 -SamplesRoot 'C:\...\Samples' -OutRoot 'C:\...\uwp-samples-analysis' -Filter '__no_match__'

Get-ChildItem 'C:\...\uwp-samples-analysis' -Directory | ForEach-Object {
    $sj = Join-Path $_.FullName 'static.json'
    $rj = Join-Path $_.FullName 'result.json'
    $info = Join-Path $_.FullName 'info.md'
    if ((Test-Path $sj) -and (Test-Path $rj)) {
        Compose-Info -staticJsonPath $sj -resultJsonPath $rj -outPath $info
    }
}
```

The `-Filter '__no_match__'` makes Run-All execute its function definitions and immediately exit with zero samples to process.

## Audit: every PNG on disk has a reference in info.md (and vice versa)

```powershell
$root = 'C:\...\uwp-samples-analysis'
Get-ChildItem $root -Directory | ForEach-Object {
    $shotsDir = Join-Path $_.FullName 'screenshots'
    $info = Join-Path $_.FullName 'info.md'
    if (-not (Test-Path $info)) { return }
    $pngs = @(); if (Test-Path $shotsDir) { $pngs = Get-ChildItem $shotsDir -Filter '*.png' | Select-Object -ExpandProperty Name }
    $md = Get-Content $info -Raw
    $refs = [regex]::Matches($md, 'screenshots/([^)\s]+\.png)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
    $missing = $pngs | Where-Object { $refs -notcontains $_ }
    $broken  = $refs | Where-Object { $pngs -notcontains $_ }
    if ($missing -or $broken) {
        [pscustomobject]@{ Sample = $_.Name; Missing = $missing; Broken = $broken }
    }
}
```

## Debug a single sample's process step-by-step

Process-Sample writes verbose logs:
- `process.log` — phase-level (BUILD, DEPLOY, LAUNCH, CAPTURE)
- `_run_stdout.log` / `_run_stderr.log` — full child-process output
- `msbuild.log` — build log (zero-padded so it's there even on success)

If launch succeeds but capture fails:
1. `result.json` will show `capture: failed` or `crashed`.
2. Check `process.log` for `[CAPTURE]` lines — what window class did we find? did `PrintWindow` return null?
3. Re-run with the sample manually launched and only the capture loop attached:

```powershell
& 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' `
    -ExecutionPolicy Bypass `
    -File .\scripts\Process-Sample.ps1 `
    -SamplePath 'C:\...\Samples\Calendar\cs' `
    -SampleName 'Calendar' `
    -OutDir 'C:\...\uwp-samples-analysis\Calendar' `
    -SkipBuild
```

(Process-Sample is invoked from Run-All this way internally; you can run it directly to iterate faster.)

## Force a re-build (clear `bin/obj`)

```powershell
Get-ChildItem 'C:\...\Samples' -Recurse -Directory -Include bin,obj | Remove-Item -Recurse -Force
```

## See which samples in last batch were ok / partial / failed / crashed

```powershell
Import-Csv 'C:\...\uwp-samples-analysis\_status.csv' |
    Group-Object capture |
    Select-Object Name, Count
```

## "It ran but produced 0 screenshots"

Most likely causes:
1. **App crashed on launch** (`0xc000027b`). Check `result.json.capture == 'crashed'`. → That sample needs hardware / non-RDP session.
2. **Window class filter rejected the real window**. Check `process.log` for what class names were enumerated. → File an issue / temporarily relax the filter.
3. **App built but didn't register**. Check `result.json.deploy`. → Inspect `process.log` for `Add-AppxPackage` error.

## "I want to add a new UWP sample to baseline"

1. Drop its `cs/` directory under `SamplesRoot/<NewSample>/cs/`.
2. Run with `-Filter 'NewSample'`.
3. If `capture == partial`, look at `process.log` to see where it stopped.
4. If `capture == ok-generic`, the analyzer didn't find a standard scenario pattern — usually fine, the Plan A fallback covered it.

## "I just changed `Run-All.ps1` while the batch was running"

You can't. PowerShell loads scripts once. You'd need to stop and re-start the batch.

`Process-Sample.ps1` is invoked fresh per sample, so changes there *do* apply mid-batch (from the next sample onwards).

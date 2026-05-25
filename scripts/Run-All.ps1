<#
.SYNOPSIS
  Orchestrate analyze + build/run/capture + info.md composition for every C# UWP sample.

.PARAMETER SamplesRoot   e.g. C:\...\uwp-samples-standalone\Samples
.PARAMETER OutRoot       e.g. C:\...\uwp-samples-analysis
.PARAMETER Filter        Optional name filter (wildcard)
.PARAMETER SkipBuild     Skip msbuild step (assume already built)
.PARAMETER SkipCapture   Run only static analysis (no app launch)
.PARAMETER OnlyAnalyze   Alias for SkipCapture + SkipBuild
#>
param(
    [string] $SamplesRoot,
    [string] $OutRoot,
    [string] $Filter      = '*',
    [switch] $SkipBuild,
    [switch] $SkipCapture,
    [switch] $OnlyAnalyze
)

if (-not $SamplesRoot) {
    throw "SamplesRoot is required. Example: -SamplesRoot 'C:\path\to\uwp-samples-standalone\Samples'"
}
if (-not $OutRoot) {
    throw "OutRoot is required. Example: -OutRoot 'C:\path\to\uwp-samples-analysis'"
}
if (-not (Test-Path $SamplesRoot)) {
    throw "SamplesRoot does not exist: $SamplesRoot"
}

$ErrorActionPreference = 'Continue'
$ProgressPreference    = 'SilentlyContinue'

$scriptDir = Split-Path -Parent $PSCommandPath
$AnalyzeScript = Join-Path $scriptDir 'Analyze-Sample.ps1'
$ProcessScript = Join-Path $scriptDir 'Process-Sample.ps1'

if ($OnlyAnalyze) { $SkipBuild = $true; $SkipCapture = $true }

New-Item -ItemType Directory -Force -Path $OutRoot | Out-Null

# Progress log: one line per phase boundary, timestamped, also echoed to console
$progressLog = Join-Path $OutRoot '_progress.log'
$statusPath  = Join-Path $OutRoot '_status.csv'
$ixPath      = Join-Path $OutRoot '_index.md'
function Log-Progress([string]$msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $msg
    Write-Host $line
    Add-Content -Path $progressLog -Value $line -Encoding UTF8
}

# Enumerate samples that have a cs/ subdirectory
$samples = Get-ChildItem $SamplesRoot -Directory | Where-Object {
    (Test-Path (Join-Path $_.FullName 'cs')) -and ($_.Name -like $Filter)
} | Sort-Object Name

Log-Progress "=== RUN-ALL START: $($samples.Count) sample(s) matching '$Filter' ==="

# When the user runs a filtered subset (e.g. -Filter 'XamlMasterDetail'), we want to
# UPDATE the entries for those samples in the existing _status.csv rather than wipe
# the rows for the 37 unfiltered samples. Pre-load any existing status.
$status = @()
$existingByName = @{}
if (Test-Path $statusPath) {
    try {
        $existing = @(Import-Csv $statusPath)
        foreach ($e in $existing) { $existingByName[$e.sample] = $e }
        Log-Progress "Loaded $($existing.Count) existing entries from _status.csv"
    } catch {
        Log-Progress "[WARN] failed to load existing _status.csv: $_"
    }
}

function Compose-Info([string]$staticJsonPath, [string]$resultJsonPath, [string]$outPath, [string]$sampleName) {
    if (-not (Test-Path $staticJsonPath)) { return }
    $stat = Get-Content $staticJsonPath -Raw | ConvertFrom-Json
    $run  = if (Test-Path $resultJsonPath) { Get-Content $resultJsonPath -Raw | ConvertFrom-Json } else { $null }
    # Fall back to the sample name embedded in static.json when caller didn't supply one
    if (-not $sampleName) { $sampleName = $stat.sample }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("# $sampleName (C#)")
    [void]$sb.AppendLine()
    $bt = [char]0x60
    [void]$sb.AppendLine("> **Source**: ${bt}Samples\$sampleName\cs\${bt}  ")
    if ($stat.feature_name)        { [void]$sb.AppendLine("> **Feature**: $($stat.feature_name)  ") }
    if ($run -and $run.aumid)      { [void]$sb.AppendLine("> **AUMID**: ${bt}$($run.aumid)${bt}  ") }
    if ($run -and $run.package_family_name) { [void]$sb.AppendLine("> **PackageFamilyName**: ${bt}$($run.package_family_name)${bt}  ") }
    [void]$sb.AppendLine()

    if ($stat.readme_description) {
        [void]$sb.AppendLine('## Sample purpose')
        [void]$sb.AppendLine($stat.readme_description)
        [void]$sb.AppendLine()
    }
    if ($stat.readme_bullets -and $stat.readme_bullets.Count -gt 0) {
        [void]$sb.AppendLine('## Scenarios demonstrated (from README)')
        foreach ($b in $stat.readme_bullets) { [void]$sb.AppendLine("- $b") }
        [void]$sb.AppendLine()
    }
    if ($stat.api_namespaces -and $stat.api_namespaces.Count -gt 0) {
        [void]$sb.AppendLine('## Top-level UWP namespaces used')
        foreach ($n in $stat.api_namespaces) { [void]$sb.AppendLine("- ``$n``") }
        [void]$sb.AppendLine()
    }

    # Run status block
    if ($run) {
        [void]$sb.AppendLine('## Build / deploy / capture status')
        [void]$sb.AppendLine("- build: $($run.build)")
        [void]$sb.AppendLine("- deploy: $($run.deploy)")
        [void]$sb.AppendLine("- launch: $($run.launch)")
        [void]$sb.AppendLine("- capture: $($run.capture)")
        [void]$sb.AppendLine("- uninstall: $($run.uninstall)")
        if ($run.error) { [void]$sb.AppendLine("- error: $($run.error)") }
        [void]$sb.AppendLine()

        # Main page
        $shotDir = 'screenshots'
        $mainShot = Join-Path (Split-Path $resultJsonPath -Parent) 'screenshots\00_main.png'
        if (Test-Path $mainShot) {
            [void]$sb.AppendLine('## Main page')
            [void]$sb.AppendLine("![Main page]($shotDir/00_main.png)")
            [void]$sb.AppendLine()
        }
    }

    # Per-scenario block - prefer static scenarios; fall back to runtime scenarios
    # (used when generic-mode iteration synthesized a "MainPage (generic)" pseudo-scenario)
    $runScenariosByIdx = @{}
    if ($run -and $run.scenarios) {
        foreach ($rs in $run.scenarios) { $runScenariosByIdx["$($rs.index)"] = $rs }
    }
    $hasStaticScenarios = ($stat.scenarios -and $stat.scenarios.Count -gt 0)
    $scenarioSource = if ($hasStaticScenarios) { $stat.scenarios } else { @() }
    foreach ($s in $scenarioSource) {
        [void]$sb.AppendLine("---")
        [void]$sb.AppendLine()
        [void]$sb.AppendLine("## Scenario $($s.index) - $($s.title)")
        if ($s.description -and $s.description -ne $s.title) {
            [void]$sb.AppendLine()
            [void]$sb.AppendLine("**Description**: $($s.description)")
        }
        [void]$sb.AppendLine()

        # UI controls
        if ($s.controls -and $s.controls.Count -gt 0) {
            [void]$sb.AppendLine('### UI elements')
            foreach ($c in $s.controls) {
                $hasContent = $c.name -or $c.x_name -or $c.content -or $c.text -or $c.inner_text -or $c.handlers
                if (-not $hasContent) { continue }
                $label = $c.type
                $extras = @()
                if ($c.name)       { $extras += "name=`"$($c.name)`"" }
                if ($c.x_name)     { $extras += "x:Name=`"$($c.x_name)`"" }
                if ($c.content)    { $extras += "content=`"$($c.content)`"" }
                if ($c.text)       { $extras += "text=`"$($c.text)`"" }
                if ($c.inner_text) { $extras += "text=`"$($c.inner_text)`"" }
                if ($c.handlers) {
                    $hs = @()
                    foreach ($p in $c.handlers.PSObject.Properties) { $hs += "$($p.Name)=$($p.Value)" }
                    if ($hs.Count -gt 0) { $extras += ('events: ' + ($hs -join ', ')) }
                }
                $line = "- **$label**"
                if ($extras.Count -gt 0) { $line += '  - ' + ($extras -join '; ') }
                [void]$sb.AppendLine($line)
            }
            [void]$sb.AppendLine()
        }

        # Code behavior
        $eventHandlers = @($s.handlers | Where-Object { $_.name -ne $s.class -and $_.api_refs.Count -gt 0 })
        if ($eventHandlers.Count -gt 0) {
            [void]$sb.AppendLine('### Code behavior')
            foreach ($h in $eventHandlers) {
                [void]$sb.AppendLine("- **``$($h.name)``**")
                if ($h.namespaces_used.Count -gt 0) {
                    [void]$sb.AppendLine("    - namespaces: " + (($h.namespaces_used | ForEach-Object { "``$_``" }) -join ', '))
                }
                if ($h.new_types.Count -gt 0) {
                    [void]$sb.AppendLine("    - instantiates: " + (($h.new_types | ForEach-Object { "``$_``" }) -join ', '))
                }
                if ($h.api_refs.Count -gt 0) {
                    $apis = $h.api_refs | Select-Object -First 30
                    [void]$sb.AppendLine("    - API refs: " + (($apis | ForEach-Object { "``$_``" }) -join ', '))
                }
                if ($h.ui_sets.Count -gt 0) {
                    [void]$sb.AppendLine("    - updates UI: " + (($h.ui_sets | ForEach-Object { "``$_``" }) -join ', '))
                }
            }
            [void]$sb.AppendLine()
        }

        # Screenshots
        $rs = $runScenariosByIdx["$($s.index)"]
        if ($rs) {
            [void]$sb.AppendLine('### Screenshots')
            if ($rs.initial_capture) {
                [void]$sb.AppendLine("Initial state:")
                [void]$sb.AppendLine()
                [void]$sb.AppendLine("![initial](screenshots/$($rs.initial_capture))")
                [void]$sb.AppendLine()
            }
            if ($rs.buttons -and $rs.buttons.Count -gt 0) {
                foreach ($b in $rs.buttons) {
                    if ($b.popup_capture) {
                        $popupTitle = if ($b.popup_title) { " (popup: $($b.popup_title))" } else { ' (popup)' }
                        [void]$sb.AppendLine("After click **$($b.name)**${popupTitle}:")
                        [void]$sb.AppendLine()
                        [void]$sb.AppendLine("![popup_$($b.name)](screenshots/$($b.popup_capture))")
                        [void]$sb.AppendLine()
                    }
                    if ($b.capture) {
                        [void]$sb.AppendLine("After click **$($b.name)**:")
                        [void]$sb.AppendLine()
                        [void]$sb.AppendLine("![after_$($b.name)](screenshots/$($b.capture))")
                        [void]$sb.AppendLine()
                    } elseif ($b.skipped_reason -and -not $b.popup_capture) {
                        [void]$sb.AppendLine("> Button **$($b.name)** skipped ($($b.skipped_reason))")
                        [void]$sb.AppendLine()
                    }
                }
            }
        }
    }

    # If there were no static scenarios but the run captured some, emit a section
    # using runtime-only data. This covers both:
    #   - generic-mode (Plan A) where a synthetic "MainPage" pseudo-scenario was iterated
    #   - standard ScenarioControl iteration on samples whose static analyzer found no scenarios
    #     (e.g. BasicInput / Clipboard / XamlBind / XamlFocusVisuals)
    if (-not $hasStaticScenarios -and $run -and $run.scenarios -and $run.scenarios.Count -gt 0) {
        $isGeneric = ($run.capture -eq 'ok-generic')
        foreach ($rs in $run.scenarios) {
            [void]$sb.AppendLine("---")
            [void]$sb.AppendLine()
            if ($isGeneric) {
                [void]$sb.AppendLine("## $($rs.title)")
                [void]$sb.AppendLine()
                [void]$sb.AppendLine("This sample did not expose a standard scenario list. Captures below come from a generic enumeration of buttons / list items / hyperlinks on the main page.")
            } else {
                [void]$sb.AppendLine("## Scenario $($rs.index) - $($rs.title)")
            }
            [void]$sb.AppendLine()

            $sectionHeader = if ($isGeneric) { '### Interaction captures' } else { '### Screenshots' }
            $needHeader = $true
            if ($rs.initial_capture) {
                [void]$sb.AppendLine($sectionHeader); $needHeader = $false
                [void]$sb.AppendLine("Initial state:")
                [void]$sb.AppendLine()
                [void]$sb.AppendLine("![initial](screenshots/$($rs.initial_capture))")
                [void]$sb.AppendLine()
            }
            if ($rs.buttons -and $rs.buttons.Count -gt 0) {
                if ($needHeader) { [void]$sb.AppendLine($sectionHeader); $needHeader = $false }
                foreach ($b in $rs.buttons) {
                    if ($b.popup_capture) {
                        $popupTitle = if ($b.popup_title) { " (popup: $($b.popup_title))" } else { ' (popup)' }
                        [void]$sb.AppendLine("After click **$($b.name)**${popupTitle}:")
                        [void]$sb.AppendLine()
                        [void]$sb.AppendLine("![popup_$($b.name)](screenshots/$($b.popup_capture))")
                        [void]$sb.AppendLine()
                    }
                    if ($b.capture) {
                        [void]$sb.AppendLine("After click **$($b.name)**:")
                        [void]$sb.AppendLine()
                        [void]$sb.AppendLine("![after_$($b.name)](screenshots/$($b.capture))")
                        [void]$sb.AppendLine()
                    } elseif ($b.skipped_reason -and -not $b.popup_capture) {
                        [void]$sb.AppendLine("> Button **$($b.name)** skipped ($($b.skipped_reason))")
                        [void]$sb.AppendLine()
                    }
                }
            }
        }
    }

    # MainPage block (for single-page samples that have no Scenario*.xaml.cs).
    # Rendered after status block / scenarios so readers see the same structure as
    # multi-scenario samples: UI elements + Code behavior, but without screenshot
    # subsections (those would have already been emitted by the runtime branch above
    # when capture succeeded, e.g. via Plan A).
    if ($stat.main_page -and -not $hasStaticScenarios) {
        $mp = $stat.main_page
        $hasContent = ($mp.controls -and $mp.controls.Count -gt 0) -or
                      ($mp.handlers -and $mp.handlers.Count -gt 0)
        if ($hasContent) {
            [void]$sb.AppendLine("---")
            [void]$sb.AppendLine()
            [void]$sb.AppendLine('## MainPage (static analysis)')
            [void]$sb.AppendLine()
            [void]$sb.AppendLine("This sample is a single-page app (no scenario list). The MainPage covers the entire functionality.")
            [void]$sb.AppendLine()
            if ($mp.controls -and $mp.controls.Count -gt 0) {
                [void]$sb.AppendLine('### UI elements')
                foreach ($c in $mp.controls) {
                    $hasC = $c.name -or $c.x_name -or $c.content -or $c.text -or $c.inner_text -or $c.handlers
                    if (-not $hasC) { continue }
                    $extras = @()
                    if ($c.name)       { $extras += "name=`"$($c.name)`"" }
                    if ($c.x_name)     { $extras += "x:Name=`"$($c.x_name)`"" }
                    if ($c.content)    { $extras += "content=`"$($c.content)`"" }
                    if ($c.text)       { $extras += "text=`"$($c.text)`"" }
                    if ($c.inner_text) { $extras += "text=`"$($c.inner_text)`"" }
                    if ($c.handlers) {
                        $hs = @()
                        foreach ($p in $c.handlers.PSObject.Properties) { $hs += "$($p.Name)=$($p.Value)" }
                        if ($hs.Count -gt 0) { $extras += ('events: ' + ($hs -join ', ')) }
                    }
                    $line = "- **$($c.type)**"
                    if ($extras.Count -gt 0) { $line += '  - ' + ($extras -join '; ') }
                    [void]$sb.AppendLine($line)
                }
                [void]$sb.AppendLine()
            }
            $codeHandlers = @($mp.handlers | Where-Object { $_.api_refs.Count -gt 0 })
            if ($codeHandlers.Count -gt 0) {
                [void]$sb.AppendLine('### Code behavior')
                foreach ($h in $codeHandlers | Select-Object -First 30) {
                    [void]$sb.AppendLine("- **``$($h.name)``**")
                    if ($h.namespaces_used.Count -gt 0) {
                        [void]$sb.AppendLine("    - namespaces: " + (($h.namespaces_used | ForEach-Object { "``$_``" }) -join ', '))
                    }
                    if ($h.new_types.Count -gt 0) {
                        [void]$sb.AppendLine("    - instantiates: " + (($h.new_types | ForEach-Object { "``$_``" }) -join ', '))
                    }
                    if ($h.api_refs.Count -gt 0) {
                        $apis = $h.api_refs | Select-Object -First 20
                        [void]$sb.AppendLine("    - API refs: " + (($apis | ForEach-Object { "``$_``" }) -join ', '))
                    }
                    if ($h.ui_sets.Count -gt 0) {
                        [void]$sb.AppendLine("    - updates UI: " + (($h.ui_sets | ForEach-Object { "``$_``" }) -join ', '))
                    }
                }
                [void]$sb.AppendLine()
            }
        }
    }

    [System.IO.File]::WriteAllText($outPath, $sb.ToString(), [System.Text.UTF8Encoding]::new($false))
}

function Write-IndexMd {
    param([array]$statusList, [string]$outRoot, [int]$total)
    $ixPath = Join-Path $outRoot '_index.md'
    $ix = New-Object System.Text.StringBuilder
    [void]$ix.AppendLine('# UWP Samples - Migration Baseline')
    [void]$ix.AppendLine()
    [void]$ix.AppendLine("Last update: $(Get-Date -Format 'u')  (progress: $($statusList.Count)/$total)")
    [void]$ix.AppendLine()
    [void]$ix.AppendLine('| # | Sample | Build | Deploy | Launch | Capture | Scenarios | Shots | Time(s) | Error |')
    [void]$ix.AppendLine('|---|--------|-------|--------|--------|---------|-----------|-------|---------|-------|')
    $i = 0
    foreach ($r in $statusList) {
        $i++
        $err  = if ($r.error) { ($r.error -replace '\|','/' -replace '\r?\n',' ').Substring(0, [Math]::Min(80, ($r.error).Length)) } else { '' }
        $name = $r.sample
        $elapsed = if ($r.PSObject.Properties['elapsed_sec']) { $r.elapsed_sec } else { '' }
        [void]$ix.AppendLine("| $i | [$name](./$name/info.md) | $($r.build) | $($r.deploy) | $($r.launch) | $($r.capture) | $($r.scenarios_n) | $($r.captures_n) | $elapsed | $err |")
    }
    [System.IO.File]::WriteAllText($ixPath, $ix.ToString(), [System.Text.UTF8Encoding]::new($false))
}

$idx = 0
foreach ($s in $samples) {
    $idx++
    $name = $s.Name
    $sampleOut = Join-Path $OutRoot $name
    New-Item -ItemType Directory -Force -Path $sampleOut | Out-Null
    $sampleStart = Get-Date
    Log-Progress "[$idx/$($samples.Count)] >>> $name START"

    $rec = [ordered]@{
        sample        = $name
        analyze       = 'pending'
        build         = 'skipped'
        deploy        = 'skipped'
        launch        = 'skipped'
        capture       = 'skipped'
        uninstall     = 'skipped'
        scenarios_n   = 0
        captures_n    = 0
        elapsed_sec   = 0
        error         = $null
    }

    # 1) STATIC ANALYSIS
    try {
        & $AnalyzeScript -SamplePath $s.FullName -OutDir $sampleOut 2>&1 | Out-Null
        if (Test-Path (Join-Path $sampleOut 'static.json')) {
            $rec.analyze = 'ok'
            $stat = Get-Content (Join-Path $sampleOut 'static.json') -Raw | ConvertFrom-Json
            $rec.scenarios_n = $stat.scenarios.Count
        } else {
            $rec.analyze = 'failed'
        }
    } catch {
        $rec.analyze = 'failed'
        $rec.error = "analyze: $_"
    }
    Log-Progress "    analyze=$($rec.analyze) scenarios=$($rec.scenarios_n)"

    # 2) BUILD / DEPLOY / LAUNCH / CAPTURE / UNINSTALL
    if (-not $SkipCapture) {
        $procArgs = @(
            '-NoProfile','-NonInteractive','-ExecutionPolicy','Bypass','-File',$ProcessScript,
            '-SamplePath',(Join-Path $s.FullName 'cs'),
            '-OutDir',$sampleOut,
            '-SampleName',$name
        )
        if ($SkipBuild) { $procArgs += '-SkipBuild' }

        Log-Progress "    build+deploy+launch+capture+uninstall START..."
        # Avoid Start-Process -Wait -RedirectStandardOutput (VBCSCompiler keeps the
        # redirected handle and hangs the parent). & + Out-Null behaves correctly.
        & powershell.exe @procArgs 2>&1 | Out-Null
        $exitCode = $LASTEXITCODE

        $resultPath = Join-Path $sampleOut 'result.json'
        if (Test-Path $resultPath) {
            $r = Get-Content $resultPath -Raw | ConvertFrom-Json
            $rec.build      = $r.build
            $rec.deploy     = $r.deploy
            $rec.launch     = $r.launch
            $rec.capture    = $r.capture
            $rec.uninstall  = $r.uninstall
            if ($r.error)   { $rec.error = $r.error }
            # Count actual PNGs on disk (robust against generic-mode initial_capture
            # pointing back at 00_main.png, which would otherwise be double-counted).
            $shotsDir = Join-Path $sampleOut 'screenshots'
            if (Test-Path $shotsDir) {
                $rec.captures_n = (Get-ChildItem $shotsDir -Filter '*.png' -ErrorAction SilentlyContinue).Count
            } else {
                $rec.captures_n = 0
            }
        } else {
            $rec.build = 'failed'
            $rec.error = "Process-Sample emitted no result.json (exit $exitCode)"
        }
        Log-Progress "    build=$($rec.build) deploy=$($rec.deploy) launch=$($rec.launch) capture=$($rec.capture) shots=$($rec.captures_n)"
    }

    # 3) Compose info.md
    $statPath = Join-Path $sampleOut 'static.json'
    $resPath  = Join-Path $sampleOut 'result.json'
    $infoMd   = Join-Path $sampleOut 'info.md'
    Compose-Info -staticJsonPath $statPath -resultJsonPath $resPath -outPath $infoMd -sampleName $name

    $rec.elapsed_sec = [int]((Get-Date) - $sampleStart).TotalSeconds
    $status += [pscustomobject]$rec
    # Track which samples we just (re)ran so the merge step knows to use the fresh row
    $existingByName[$name] = [pscustomobject]$rec

    Log-Progress "[$idx/$($samples.Count)] <<< $name DONE in $($rec.elapsed_sec)s"

    # Incrementally refresh _status.csv + _index.md so user can monitor progress.
    # MERGE with existing rows so a filtered run (e.g. `-Filter Calendar`) updates
    # only that row instead of wiping the other 37.
    try {
        $merged = @($existingByName.Values | Sort-Object sample)
        $merged | Export-Csv -Path $statusPath -NoTypeInformation -Encoding UTF8
        Write-IndexMd -statusList $merged -outRoot $OutRoot -total $merged.Count
    } catch {
        Log-Progress "    [WARN] failed to refresh status: $_"
    }
}

# Final summary
Log-Progress "=== RUN-ALL COMPLETE: $($status.Count) samples ==="
$built = ($status | Where-Object { $_.build -eq 'ok' }).Count
$captured = ($status | Where-Object { $_.capture -eq 'ok' }).Count
$totalShots = ($status | Measure-Object -Property captures_n -Sum).Sum
Log-Progress "Built: $built / $($status.Count); Captured: $captured / $($status.Count); Total screenshots: $totalShots"
Log-Progress "Status: $statusPath"
Log-Progress "Index : $ixPath"

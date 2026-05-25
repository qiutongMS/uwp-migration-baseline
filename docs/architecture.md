# Architecture

## Phases

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Run-All.ps1 (PS7)                          │
│  - enumerates SamplesRoot for any dir with a "cs/" subdir           │
│  - merges with existing _status.csv (so -Filter is safe)            │
│  - for each sample: Phase A → Phase B → Phase C                     │
│  - writes _status.csv + _index.md + _progress.log                   │
└─────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌────────────────────────────────────────┐
│ Phase A — Analyze-Sample.ps1 (PS7)     │
│  Read README.md → purpose + scenarios  │
│  Read SampleConfiguration.cs → order   │
│  Parse Scenario*.xaml → UI controls    │
│  Parse Scenario*.xaml.cs → handlers,   │
│    namespaces, instantiations, ui sets │
│  → static.json                         │
└────────────────────────────────────────┘
        │
        ▼
┌────────────────────────────────────────────────────────────────────┐
│ Phase B — Process-Sample.ps1 (PS 5.1 sub-process)                  │
│                                                                    │
│  1. msbuild /restore /t:Build                                      │
│       AppxPackageSigningEnabled=false, AppxBundle=Never,           │
│       UseDotNetNativeToolchain=false                               │
│  2. Add-AppxPackage -Register bin\x64\Debug\AppxManifest.xml       │
│  3. IApplicationActivationManager::ActivateApplication → PID       │
│  4. Find window: EnumWindows + title match                         │
│     filtered to class = ApplicationFrameWindow                     │
│  5. Screenshot main page (PrintWindow PW_RENDERFULLCONTENT)        │
│  6. Try standard iteration:                                        │
│       Find AutomationElement with AutomationId=ScenarioControl     │
│       For each ListItem:                                           │
│         SelectionItemPattern.Select()                              │
│         wait 1.5s                                                  │
│         capture initial.png                                        │
│         enumerate safe buttons → for each:                         │
│            Invoke()                                                │
│            if popup appears → Capture-LargestPopup (Plan D)        │
│            ESC                                                     │
│            capture after_<button>.png                              │
│                                                                    │
│  6'. If ScenarioControl not found:                                 │
│       Invoke-GenericIteration (Plan A):                            │
│         enumerate Button / ListItem / Hyperlink on main page       │
│         dedupe Buttons by name, keep all ListItems / Hyperlinks    │
│         filter chrome buttons (close/min/max/back)                 │
│         for each (up to maxInvoke=8):                              │
│            Invoke()                                                │
│            if popup appears → Capture-LargestPopup                 │
│            ESC                                                     │
│            capture 01_MainPage__NN_<Kind>_<Name>.png               │
│                                                                    │
│  7. Stop-Process; Remove-AppxPackage <PackageFullName>             │
│  → result.json                                                     │
└────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌────────────────────────────────────────┐
│ Phase C — Compose-Info (in Run-All)    │
│  Merge static.json + result.json       │
│  Render to info.md:                    │
│    headers (purpose, scenarios)        │
│    main page screenshot                │
│    per-scenario:                       │
│      UI elements (from static)         │
│      Code behavior (from static)       │
│      Screenshots (from result):        │
│        initial + popups + afters       │
└────────────────────────────────────────┘
```

## Key design decisions

### 1. Why `ApplicationFrameWindow` class filter

UWP apps are hosted by a `Windows.UI.ApplicationFrameHost` process. The top-level window class is `ApplicationFrameWindow`; the actual app's `CoreWindow` is a child.

Without this filter, `FindWindowsByTitle("Camera profile sample")` would happily also match:
- the PowerShell terminal (where `Write-Host "=== Camera profile sample ==="` echoed the name into the title)
- a VS Code instance with the sample's README open
- the File Explorer window pointed at the sample folder

`GetClassName` P/Invoke + filter `class -eq 'ApplicationFrameWindow'` makes this robust.

### 2. Why `PrintWindow` with `PW_RENDERFULLCONTENT` (flag=2)

- Standard `PrintWindow` (flag=0) often returns a black bitmap for UWP / DirectComposition windows.
- Flag=2 forces a render including layered content. Required for XAML-based windows.

### 3. Why retry on null bitmap

Some samples take longer than expected to render initial content. The first `PrintWindow` returns a valid HBITMAP but `Bitmap.FromHbitmap` returns null. Retry: re-find the window, wait 1s, try again. If still null → mark `capture='crashed'` (this catches the `0xc000027b` env crashes cleanly).

### 4. Why `IApplicationActivationManager` for launch, not `start shell:appsFolder\<AUMID>`

- `ActivateApplication` returns the PID directly. `start` returns immediately and the actual app PID is unrelated.
- Fallback to `explorer.exe shell:appsFolder\<AUMID>` only when `ActivateApplication` returns `HR=0x80040904` (CO_E_SERVER_EXEC_FAILURE). `RadialController` needed this.

### 5. Why ESC after every button click

- Many samples open a modal dialog (Open / Save As / Folder Picker / MessageDialog) which would otherwise block further iteration.
- ESC is the universal cancel for these dialogs.
- We screenshot the dialog FIRST (Plan D), THEN press ESC.

### 6. Why ordinal-indexed filenames in Plan A

XamlMasterDetail has 4 list items, all returning `MasterDetailApp.ViewModels.ItemViewModel` as `Name` (ViewModel doesn't override `ToString()`). Without ordinal indices, all 4 would collide on a single filename.

Format: `01_MainPage__{NN:02}_{Kind}_{Name}.png`

### 7. Why we keep a separate Capture-Sample.ps1

It was the original prototype before being absorbed into Process-Sample.ps1. Kept in `scripts/` for reference and because it's a minimal standalone capture helper that can be useful for debugging a single sample without the full deploy pipeline.

## Data flow

```
SamplesRoot/
  Calendar/
    cs/
      Calendar.csproj
      MainPage.xaml.cs
      SampleConfiguration.cs           ────────┐
      Scenario1_DisplayCalendar.xaml            │
      Scenario1_DisplayCalendar.xaml.cs         │  Analyze
      ...                                       │
                                                ▼
OutRoot/
  Calendar/
    static.json   ←── Analyze-Sample.ps1 output
    result.json   ←── Process-Sample.ps1 output
    msbuild.log
    process.log
    _run_stdout.log
    _run_stderr.log
    screenshots/
      00_main.png
      01_1_Display_calendar__initial.png
      01_1_Display_calendar__after_Calendar_to_now.png
      ...
    info.md       ←── Compose-Info (Run-All.ps1) merges static.json + result.json
  Calendar/
  ...
  _status.csv     ←── one row per sample
  _index.md       ←── rendered table + per-sample links
  _progress.log   ←── one line per phase transition, timestamped
```

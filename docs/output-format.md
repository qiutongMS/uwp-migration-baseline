# Output formats

## `static.json` — Analyze-Sample.ps1 output

```jsonc
{
  "sample": "Calendar",
  "feature": "Calendar sample",
  "purpose": "Shows how to use the Windows.Globalization.Calendar class...",
  "namespaces": ["Windows.Globalization", "Windows.Globalization.NumberFormatting"],
  "scenarios": [
    {
      "index": 1,
      "title": "Display calendar",
      "class": "Calendar.Scenario1_DisplayCalendar",
      "description": "Shows how to create a Calendar, set its...",
      "controls": [
        { "type": "Button",   "name": "currentCalendar", "content": "Calendar to now",      "handlers": { "Click": "OnNow_Click" } },
        { "type": "TextBlock", "x_name": "OutputText" }
      ],
      "handlers": [
        {
          "name": "OnNow_Click",
          "namespaces_used": ["Windows.Globalization.Calendar"],
          "new_types": ["Calendar"],
          "api_refs": ["Calendar.SetToNow", "Calendar.YearAsString"],
          "ui_sets": ["OutputText.Text"]
        }
      ]
    }
  ]
}
```

Notes:
- `scenarios` is an empty array when the analyzer can't find a `SampleConfiguration.cs` pattern (~4 samples). The runtime can still iterate via Plan A in that case.
- `controls`, `handlers` are best-effort regex extraction — not a real XAML / C# parser.

## `result.json` — Process-Sample.ps1 output

```jsonc
{
  "sample": "Calendar",
  "build":   "ok | failed | skipped",
  "deploy":  "ok | failed",
  "launch":  "ok | failed",
  "capture": "ok | ok-generic | partial | failed | crashed",
  "uninstall": "ok | failed",
  "error": null,
  "aumid":  "Microsoft.SDKSamples.Calendar.CS_8wekyb3d8bbwe!App",
  "package_family_name": "Microsoft.SDKSamples.Calendar.CS_8wekyb3d8bbwe",
  "package_full_name":   "Microsoft.SDKSamples.Calendar.CS_8wekyb3d8bbwe_x64__...",
  "pid": 12345,
  "main_capture": "00_main.png",
  "scenarios": [
    {
      "index": 1,
      "title": "1) Display calendar",
      "initial_capture": "01_1_Display_calendar__initial.png",
      "buttons": [
        {
          "name": "Calendar to now",
          "invoked": true,
          "skipped_reason": null,
          "capture": "01_1_Display_calendar__after_Calendar_to_now.png",
          "popup_capture": null,
          "popup_title": null
        },
        {
          "name": "Select image and copy",
          "invoked": true,
          "skipped_reason": "opened_popup",
          "capture": "02_..._after_Select_image_and_copy.png",
          "popup_capture": "02_..._popup_Select_image_and_copy.png",
          "popup_title": "Open"
        }
      ]
    }
  ]
}
```

### `capture` value semantics

| Value | Meaning |
|---|---|
| `ok`         | Standard `ScenarioControl` iteration finished; main + initial + after captures present |
| `ok-generic` | Plan A fired; runtime contains a single synthesized "MainPage" pseudo-scenario with N interaction captures |
| `partial`    | Captured *some* scenarios then hit an error; rest are missing. See `error` field for cause |
| `failed`     | Couldn't capture anything past the main page (or even that) due to a hard error |
| `crashed`    | UWP host crashed early (typically `0xc000027b` delayed-load failure). Distinct from `failed` because the pipeline detected it and stopped cleanly instead of timing out |

## `info.md` — Compose-Info output

Two layouts depending on whether `static.scenarios` is non-empty:

### When `static.scenarios` is non-empty (the common case)

```markdown
# <Sample> (C#)

> **Source**: `Samples\<Sample>\cs\`
> **Feature**: ...
> **AUMID**: ...
> **PackageFamilyName**: ...

## Sample purpose
<README first paragraph>

## Scenarios demonstrated (from README)
- **Scenario 1 title:** description...
- **Scenario 2 title:** description...

## Top-level UWP namespaces used
- `Windows.Globalization`
- ...

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: ok
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - <title>

**Description**: ...

### UI elements
- **Button**  - content="Calendar to now"; events: Click=OnNow_Click
- **TextBlock**  - x:Name="OutputText"

### Code behavior
- **`OnNow_Click`**
    - namespaces: `Windows.Globalization.Calendar`
    - instantiates: `Calendar`
    - API refs: `Calendar.SetToNow`, `Calendar.YearAsString`
    - updates UI: `OutputText.Text`

### Screenshots
Initial state:

![initial](screenshots/01_1_Display_calendar__initial.png)

After click **Calendar to now**:

![after_Calendar_to_now](screenshots/01_1_Display_calendar__after_Calendar_to_now.png)

---
... (more scenarios)
```

### When `static.scenarios` is empty (generic-mode samples)

```markdown
# ...
## Main page
![Main page](screenshots/00_main.png)

---

## MainPage (generic)

This sample did not expose a standard scenario list. Captures below come from a generic enumeration of buttons / list items / hyperlinks on the main page.

### Interaction captures
After click **ListItem: Lorem ipsum**:

![after_ListItem: Lorem ipsum](screenshots/01_MainPage__01_ListItem_Lorem_ipsum.png)
... etc
```

The fallback path also handles the case where `static.scenarios` is empty but `result.scenarios` has *real* standard-iteration scenarios (BasicInput / Clipboard / XamlBind / XamlFocusVisuals) — it just uses scenario titles from runtime.

## `_status.csv`

```csv
sample,build,deploy,launch,capture,uninstall,scenarios_n,captures_n,note
AdaptiveStreaming,skipped,ok,ok,ok,ok,7,29,
BasicInput,skipped,ok,ok,ok,ok,5,8,
...
```

`captures_n` is the count of PNGs on disk (after Run-All scans `screenshots/`).

## `_index.md`

A markdown table with one row per sample, columns matching `_status.csv`, plus a link to each `info.md`.

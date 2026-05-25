# XamlFocusVisuals (C#)

> **Source**: `Samples\XamlFocusVisuals\cs\`  
> **Feature**: Focus Visuals Sample  
> **AUMID**: `Microsoft.SDKSamples.FocusVisualsSample.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.FocusVisualsSample.CS_8wekyb3d8bbwe`  

## Sample purpose
Shows how to use system drawn focus visuals, or to create your own custom focus visuals if the system drawn ones do not fit your needs.

## Scenarios demonstrated (from README)
- **Use the system focus visuals in custom controls:** By using UseSystemFocusVisuals and the attached property Control.IsTemplateFocusTarget, you can specify which piece of your control template should draw the focus visuals.
- **Create your own focus visuals:** Add back the focus visual states from Windows 8.1 (included in the sample), and set UseSystemFocusVisuals to false to specify your own visuals.

## Top-level UWP namespaces used
- `Windows.System.Launcher.LaunchUriAsync`

## Build / deploy / capture status
- build: skipped
- deploy: ok
- launch: ok
- capture: ok
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - 1) Using custom focus visuals

### Screenshots
Initial state:

![initial](screenshots/01_1_Using_custom_focus_visuals__initial.png)

---

## Scenario 2 - 2) Applying to custom controls

### Screenshots
Initial state:

![initial](screenshots/02_2_Applying_to_custom_controls__initial.png)

---

## MainPage (static analysis)

This sample is a single-page app (no scenario list). The MainPage covers the entire functionality.

### UI elements
- **Image**  - x:Name="WindowsLogo"
- **TextBlock**  - x:Name="Header"; text="Windows platform sample"
- **TextBlock**  - x:Name="SampleTitle"; text="Sample Title Here"
- **ListBox**  - x:Name="ScenarioControl"; events: SelectionChanged=ScenarioControl_SelectionChanged
- **TextBlock**  - text="{Binding Converter={StaticResource ScenarioConverter}}"
- **TextBlock**  - x:Name="Copyright"; text="© Microsoft Corporation. All rights reserved."
- **HyperlinkButton**  - content="Trademarks"; events: Click=Footer_Click
- **TextBlock**  - text="|"
- **HyperlinkButton**  - x:Name="PrivacyLink"; content="Privacy"; events: Click=Footer_Click
- **ToggleButton**  - events: Click=Button_Click

### Code behavior
- **`MainPage`**
    - API refs: `SampleTitle.Text`
- **`OnNavigatedTo`**
    - API refs: `ScenarioControl.ItemsSource`, `Window.Current`, `Bounds.Width`, `ScenarioControl.SelectedIndex`
- **`ScenarioControl_SelectionChanged`**
    - API refs: `ScenarioFrame.Navigate`, `Window.Current`, `Bounds.Width`, `Splitter.IsPaneOpen`
- **`Footer_Click`**
    - namespaces: `Windows.System.Launcher.LaunchUriAsync`
    - instantiates: `Uri`
    - API refs: `Windows.System`, `Launcher.LaunchUriAsync`, `Tag.ToString`
- **`Button_Click`**
    - API refs: `Splitter.IsPaneOpen`
- **`Convert`**
    - API refs: `MainPage.Current`, `Scenarios.IndexOf`


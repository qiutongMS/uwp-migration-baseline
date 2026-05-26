# XamlDataVirtualization (C#)

> **Source**: `Samples\XamlDataVirtualization\cs\`  
> **Feature**: Data Virtualization Sample  
> **AUMID**: `Microsoft.SDKSamples.DataVirtualization.CS_8wekyb3d8bbwe!DataVirtualization.App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.DataVirtualization.CS_8wekyb3d8bbwe`  

## Top-level UWP namespaces used
- `Windows.UI.Colors.Green`
- `Windows.UI.Colors.Red`
- `Windows.System.Launcher.LaunchUriAsync`

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: ok
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - 1) Data Virtualization

### Screenshots
Initial state:

![initial](screenshots/01_1_Data_Virtualization__initial.png)

---

## Scenario 2 - 2) Selection Management

### Screenshots
Initial state:

![initial](screenshots/02_2_Selection_Management__initial.png)

After click **Force a reset**:

![after_Force a reset](screenshots/02_2_Selection_Management__after_Force_a_reset.png)

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
- **TextBlock**  - x:Name="StatusLabel"; text="Status:"
- **TextBlock**  - x:Name="StatusBlock"
- **ToggleButton**  - events: Click=Button_Click

### Code behavior
- **`MainPage`**
    - API refs: `SampleTitle.Text`
- **`OnNavigatedTo`**
    - API refs: `ScenarioControl.ItemsSource`, `Window.Current`, `Bounds.Width`, `ScenarioControl.SelectedIndex`
- **`ScenarioControl_SelectionChanged`**
    - API refs: `String.Empty`, `NotifyType.StatusMessage`, `ScenarioFrame.Navigate`, `Window.Current`, `Bounds.Width`, `Splitter.IsPaneOpen`, `StatusBorder.Visibility`, `Visibility.Collapsed`
- **`NotifyUser`**
    - namespaces: `Windows.UI.Colors.Green`, `Windows.UI.Colors.Red`
    - instantiates: `SolidColorBrush`
    - API refs: `NotifyType.StatusMessage`, `StatusBorder.Background`, `Windows.UI`, `Colors.Green`, `NotifyType.ErrorMessage`, `Colors.Red`, `StatusBlock.Text`, `StatusBorder.Visibility`, `String.Empty`, `Visibility.Visible`, `Visibility.Collapsed`
- **`Footer_Click`**
    - namespaces: `Windows.System.Launcher.LaunchUriAsync`
    - instantiates: `Uri`
    - API refs: `Windows.System`, `Launcher.LaunchUriAsync`, `Tag.ToString`
- **`Button_Click`**
    - API refs: `Splitter.IsPaneOpen`, `StatusBorder.Visibility`, `Visibility.Collapsed`
- **`Convert`**
    - API refs: `MainPage.Current`, `Scenarios.IndexOf`


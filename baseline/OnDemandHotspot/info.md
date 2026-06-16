# OnDemandHotspot (C#)

> **Source**: `Samples\OnDemandHotspot\cs\`  
> **Feature**: OnDemandHotspot C# Sample  
> **AUMID**: `Microsoft.SDKSamples.OnDemandHotspot.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.OnDemandHotspot.CS_8wekyb3d8bbwe`  

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: failed
- uninstall: pending
- error: Could not find main window (looked for 'OnDemandHotspot C# Sample')

---

## Scenario 1 - Manage Hotspot

**Description**: To create an on-demand hotspot, register a background task to provide information about the hotspot when the system shows a list of Wi-Fi networks, and another to turn on the hotspot when the user selects it. You probably also want to register a background task to detect when the hotspot is in range so you can update its availability and other properties.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="This sample does not control a physical hotspot device, so we will simulate it by displaying a toast message instructing you to turn on your mobile phone's hotspot."
- **Button**  - name="RegisterButton"; content="Register tasks"; events: Click=RegisterTasks_Click
- **Button**  - name="UnregisterButton"; content="Unregister tasks"; events: Click=UnregisterTasks_Click
- **TextBlock**  - text="DisplayName:"
- **TextBox**  - x:Name="DisplayNameText"
- **TextBlock**  - text="Available:"
- **ToggleSwitch**  - x:Name="AvailableToggle"
- **TextBlock**  - text="Cellular bars:"
- **ToggleSwitch**  - x:Name="CellularBarsToggle"
- **Slider**  - x:Name="CellularBarsSlider"
- **TextBlock**  - text="Battery percentage: "
- **ToggleSwitch**  - x:Name="BatteryPercentageToggle"
- **Slider**  - x:Name="BatteryPercentageSlider"
- **TextBlock**  - text="SSID:"
- **TextBox**  - x:Name="SsidText"
- **TextBlock**  - text="Password:"
- **PasswordBox**  - x:Name="PasswordText"
- **Button**  - name="ApplyNowButton"; content="Update now"; events: Click=UpdateNowButton_Click
- **Button**  - content="Update when user opens Wi-Fi network list"; events: Click=UpdateOnDemandButton_Click

### Code behavior
- **`IsBackgroundTaskName`**
    - API refs: `Constants.MetadataUpdateTaskName`, `Constants.DeviceWatcherTaskName`, `Constants.ConnectTaskName`
- **`OnNavigatedTo`**
    - API refs: `WiFiOnDemandHotspotNetwork.GetOrCreateById`, `Constants.SampleHotspotGuid`, `DisplayNameText.Text`, `AvailableToggle.IsOn`, `WiFiOnDemandHotspotAvailability.Available`, `CellularBarsToggle.IsOn`, `Debug.Assert`, `WiFiOnDemandHotspotCellularBars.ZeroBars`, `WiFiOnDemandHotspotCellularBars.OneBar`, `WiFiOnDemandHotspotCellularBars.TwoBars`, `WiFiOnDemandHotspotCellularBars.ThreeBars`, `WiFiOnDemandHotspotCellularBars.FourBars`, `WiFiOnDemandHotspotCellularBars.FiveBars`, `CellularBarsSlider.Value`, `BatteryPercentageToggle.IsOn`, `BatteryPercentageSlider.Value`, `SsidText.Text`, `PasswordText.Password`, `String.Empty`, `BackgroundTaskRegistration.AllTasks`, `Value.Name`, `VisualStateManager.GoToState`
- **`RegisterTasks_Click`**
    - instantiates: `WiFiOnDemandHotspotUpdateMetadataTrigger`, `BackgroundTaskBuilder`, `WiFiOnDemandHotspotConnectTrigger`, `List`
    - API refs: `Constants.MetadataUpdateTaskName`, `Constants.MetadataUpdateEntryPoint`, `Constants.ConnectTaskName`, `Constants.ConnectEntryPoint`, `DeviceInformation.CreateWatcher`, `Contoso.Devices`, `OnDemandHotSpot.GetDeviceSelector`, `DeviceWatcherEventKind.Add`, `DeviceWatcherEventKind.Remove`, `DeviceWatcherEventKind.Update`, `Constants.DeviceWatcherTaskName`, `Constants.DeviceWatcherEntryPoint`, `VisualStateManager.GoToState`
- **`UnregisterTasks_Click`**
    - API refs: `BackgroundTaskRegistration.AllTasks`, `Value.Name`, `Value.Unregister`, `VisualStateManager.GoToState`
- **`SavePropertiesForBackgroundTask`**
    - API refs: `NotifyType.StatusMessage`, `AvailableToggle.IsOn`, `String.IsNullOrEmpty`, `DisplayNameText.Text`, `NotifyType.ErrorMessage`, `SsidText.Text`, `PasswordText.Password`, `ApplicationData.Current`, `LocalSettings.Values`, `CellularBarsToggle.IsOn`, `CellularBarsSlider.Value`, `BatteryPercentageToggle.IsOn`, `BatteryPercentageSlider.Value`, `Constants.SampleHotspotGuid`
- **`UpdateNowButton_Click`**
    - API refs: `AvailableToggle.IsOn`, `WiFiOnDemandHotspotAvailability.Available`, `WiFiOnDemandHotspotAvailability.Unavailable`, `DisplayNameText.Text`, `CellularBarsToggle.IsOn`, `CellularBarsSlider.Value`, `BatteryPercentageToggle.IsOn`, `BatteryPercentageSlider.Value`, `SsidText.Text`, `PasswordText.Password`


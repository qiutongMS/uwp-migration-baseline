# MobileHotspot (C#)

> **Source**: `Samples\MobileHotspot\cs\`  
> **Feature**: MobileHotspot C# Sample  

## Build / deploy / capture status
- build: failed
- deploy: pending
- launch: pending
- capture: pending
- uninstall: pending
- error: msbuild exit 1, see msbuild.log

---

## Scenario 1 - Configure Mobile Hotspot

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="View and edit Mobile Hotspot settings."
- **TextBlock**  - x:Name="SsidLabel"; text="SSID:"
- **TextBox**  - x:Name="SsidTextBox"
- **TextBlock**  - x:Name="PassphraseLabel"; text="Passphrase:"
- **TextBox**  - x:Name="PassphraseTextBox"
- **TextBlock**  - x:Name="BandLabel"; text="Band:"
- **ComboBox**  - x:Name="BandComboBox"
- **TextBlock**  - x:Name="AuthenticationLabel"; text="Authentication:"
- **ComboBox**  - x:Name="AuthenticationComboBox"
- **Button**  - content="Apply changes"; events: Click=ApplyChanges_Click
- **Button**  - content="Discard changes"; events: Click=DiscardChanges_Click

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `Helpers.TryGetCurrentNetworkOperatorTetheringManager`, `HotspotPanel.Visibility`, `Visibility.Visible`
- **`AddComboBoxItem`**
    - API refs: `BandComboBox.Items`, `BandComboBox.SelectedItem`
- **`InitializeTetheringControls`**
    - API refs: `SsidTextBox.Text`, `PassphraseTextBox.Text`, `BandComboBox.Items`, `TetheringWiFiBand.Auto`, `TetheringWiFiBand.SixGigahertz`, `Helpers.IsBandSupported`, `Helpers.GetFriendlyName`, `BandComboBox.SelectedIndex`, `AuthenticationComboBox.Items`, `TetheringWiFiAuthenticationKind.Wpa2`, `TetheringWiFiAuthenticationKind.Wpa3`, `Helpers.IsAuthenticationKindSupported`, `AuthenticationComboBox.SelectedIndex`
    - updates UI: `SsidTextBox.Text`, `PassphraseTextBox.Text`
- **`ApplyChanges_Click`**
    - API refs: `SsidTextBox.Text`, `PassphraseTextBox.Text`, `BandComboBox.SelectedItem`, `AuthenticationComboBox.SelectedItem`

---

## Scenario 2 - Toggle Mobile Hotspot

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Turn Mobile Hotspot on or off."
- **TextBlock**  - x:Name="MobileHotspotLabel"; text="Mobile Hotspot:"
- **ToggleSwitch**  - x:Name="MobileHotspotToggle"; events: Toggled=MobileHotspotToggle_Toggled
- **TextBlock**  - text="SSID:"
- **TextBlock**  - text="Password:"
- **TextBlock**  - text="Band:"
- **TextBlock**  - text="Authentication:"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `MainPage.Current`, `NotifyType.StatusMessage`, `Helpers.TryGetCurrentNetworkOperatorTetheringManager`, `SsidRun.Text`, `PasswordRun.Text`, `BandRun.Text`, `Helpers.GetFriendlyName`, `AuthenticationRun.Text`, `TetheringOperationalState.On`, `MobileHotspotToggle.IsOn`, `HotspotPanel.Visibility`, `Visibility.Visible`
- **`MobileHotspotToggle_Toggled`**
    - API refs: `MainPage.Current`, `NotifyType.StatusMessage`, `TetheringOperationalState.On`, `MobileHotspotToggle.IsOn`, `TetheringOperationStatus.Success`, `TetheringOperationStatus.WiFiDeviceOff`, `NotifyType.ErrorMessage`


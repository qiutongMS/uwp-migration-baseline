# Magnetometer (C#)

> **Source**: `Samples\Magnetometer\cs\`  
> **Feature**: Magnetometer  
> **AUMID**: `Microsoft.SDKSamples.MagnetometerCS.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.MagnetometerCS.CS_8wekyb3d8bbwe`  

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: ok
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - Data Events

### UI elements
- **TextBlock**  - x:Name="InputTextBlock"; text="Registers an event listener for magnetometer data and displays the X, Y and Z magnetic field values as they are reported."
- **Button**  - x:Name="ScenarioEnableButton"; content="Enable"; events: Click=ScenarioEnable
- **Button**  - x:Name="ScenarioDisableButton"; content="Disable"; events: Click=ScenarioDisable
- **TextBlock**  - text="X:"
- **TextBlock**  - text="Y:"
- **TextBlock**  - text="Z:"
- **TextBlock**  - x:Name="ScenarioOutput_X"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Y"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Z"; text="No data"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`
- **`OnNavigatingFrom`**
    - API refs: `ScenarioDisableButton.IsEnabled`, `Window.Current`
- **`VisibilityChanged`**
    - API refs: `ScenarioDisableButton.IsEnabled`
- **`ReadingChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `ScenarioOutput_X.Text`, `String.Format`, `ScenarioOutput_Y.Text`, `ScenarioOutput_Z.Text`
- **`ScenarioEnable`**
    - API refs: `Window.Current`, `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`, `NotifyType.ErrorMessage`
- **`ScenarioDisable`**
    - API refs: `Window.Current`, `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`

### Screenshots
Initial state:

![initial](screenshots/01_1_Data_Events__initial.png)

After click **Enable**:

![after_Enable](screenshots/01_1_Data_Events__after_Enable.png)

---

## Scenario 2 - Polling

### UI elements
- **TextBlock**  - x:Name="InputTextBlock"; text="Polls for magnetometer data and displays the X, Y and Z magnetic field values at a set interval."
- **Button**  - x:Name="ScenarioEnableButton"; content="Enable"; events: Click=ScenarioEnable
- **Button**  - x:Name="ScenarioDisableButton"; content="Disable"; events: Click=ScenarioDisable
- **TextBlock**  - text="X:"
- **TextBlock**  - text="Y:"
- **TextBlock**  - text="Z:"
- **TextBlock**  - x:Name="ScenarioOutput_X"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Y"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Z"; text="No data"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`
- **`OnNavigatingFrom`**
    - API refs: `ScenarioDisableButton.IsEnabled`, `Window.Current`
- **`VisibilityChanged`**
    - API refs: `ScenarioDisableButton.IsEnabled`
- **`DisplayCurrentReading`**
    - API refs: `ScenarioOutput_X.Text`, `String.Format`, `ScenarioOutput_Y.Text`, `ScenarioOutput_Z.Text`
- **`ScenarioEnable`**
    - API refs: `Window.Current`, `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`, `NotifyType.ErrorMessage`
- **`ScenarioDisable`**
    - API refs: `Window.Current`, `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`

### Screenshots
Initial state:

![initial](screenshots/02_2_Polling__initial.png)

After click **Enable**:

![after_Enable](screenshots/02_2_Polling__after_Enable.png)


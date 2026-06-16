# Compass (C#)

> **Source**: `Samples\Compass\cs\`  
> **Feature**: Compass  
> **AUMID**: `Microsoft.SDKSamples.Compass.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.Compass.CS_8wekyb3d8bbwe`  

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
- **TextBlock**  - x:Name="InputTextBlock"; text="Registers an event listener for compass data and displays the heading values as they are reported."
- **Button**  - x:Name="ScenarioEnableButton"; content="Enable"; events: Click=ScenarioEnable
- **Button**  - x:Name="ScenarioDisableButton"; content="Disable"; events: Click=ScenarioDisable
- **TextBlock**  - text="Magnetic North: "
- **TextBlock**  - text="True North: "
- **TextBlock**  - text="Heading Accuracy: "
- **TextBlock**  - x:Name="ScenarioOutput_MagneticNorth"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_TrueNorth"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_HeadingAccuracy"; text="No data"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`
- **`OnNavigatingFrom`**
    - instantiates: `WindowVisibilityChangedEventHandler`, `TypedEventHandler`
    - API refs: `ScenarioDisableButton.IsEnabled`, `Window.Current`
- **`VisibilityChanged`**
    - instantiates: `TypedEventHandler`
    - API refs: `ScenarioDisableButton.IsEnabled`
- **`ReadingChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `ScenarioOutput_MagneticNorth.Text`, `String.Format`, `ScenarioOutput_TrueNorth.Text`, `MagnetometerAccuracy.Unknown`, `ScenarioOutput_HeadingAccuracy.Text`, `MagnetometerAccuracy.Unreliable`, `MagnetometerAccuracy.Approximate`, `MagnetometerAccuracy.High`
- **`ScenarioEnable`**
    - instantiates: `WindowVisibilityChangedEventHandler`, `TypedEventHandler`
    - API refs: `Window.Current`, `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`, `NotifyType.ErrorMessage`
- **`ScenarioDisable`**
    - instantiates: `WindowVisibilityChangedEventHandler`, `TypedEventHandler`
    - API refs: `Window.Current`, `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`

### Screenshots
Initial state:

![initial](screenshots/01_1_Data_Events__initial.png)

After click **Enable**:

![after_Enable](screenshots/01_1_Data_Events__after_Enable.png)

---

## Scenario 2 - Polling

### UI elements
- **TextBlock**  - x:Name="InputTextBlock"; text="Polls for compass data and displays the heading values at a set interval."
- **Button**  - x:Name="ScenarioEnableButton"; content="Enable"; events: Click=ScenarioEnable
- **Button**  - x:Name="ScenarioDisableButton"; content="Disable"; events: Click=ScenarioDisable
- **TextBlock**  - text="Magnetic North: "
- **TextBlock**  - text="True North: "
- **TextBlock**  - text="Heading Accuracy: "
- **TextBlock**  - x:Name="ScenarioOutput_MagneticNorth"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_TrueNorth"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_HeadingAccuracy"; text="No data"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`
- **`OnNavigatingFrom`**
    - instantiates: `WindowVisibilityChangedEventHandler`
    - API refs: `ScenarioDisableButton.IsEnabled`, `Window.Current`
- **`VisibilityChanged`**
    - API refs: `ScenarioDisableButton.IsEnabled`
- **`DisplayCurrentReading`**
    - API refs: `ScenarioOutput_MagneticNorth.Text`, `String.Format`, `ScenarioOutput_TrueNorth.Text`, `MagnetometerAccuracy.Unknown`, `ScenarioOutput_HeadingAccuracy.Text`, `MagnetometerAccuracy.Unreliable`, `MagnetometerAccuracy.Approximate`, `MagnetometerAccuracy.High`
- **`ScenarioEnable`**
    - instantiates: `WindowVisibilityChangedEventHandler`
    - API refs: `Window.Current`, `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`, `NotifyType.ErrorMessage`
- **`ScenarioDisable`**
    - instantiates: `WindowVisibilityChangedEventHandler`
    - API refs: `Window.Current`, `ScenarioEnableButton.IsEnabled`, `ScenarioDisableButton.IsEnabled`

### Screenshots
Initial state:

![initial](screenshots/02_2_Polling__initial.png)

After click **Enable**:

![after_Enable](screenshots/02_2_Polling__after_Enable.png)

---

## Scenario 3 - Calibration

### UI elements
- **TextBlock**  - x:Name="InputTextBlock"; text="Simulates the current sensor accuracy. Setting to 'Unreliable' will invoke the calibration bar until accuracy improves or 30 seconds passes. The calibration bar will not be shown again for at least 5 minutes, even when accuracy returns to 'Unreliable'."
- **TextBlock**  - text="Heading Accuracy: "
- **RadioButton**  - content="High"; events: Click=OnHighAccuracy
- **RadioButton**  - content="Approximate"; events: Click=OnApproximateAccuracy
- **RadioButton**  - content="Unreliable"; events: Click=OnUnreliableAccuracy

### Code behavior
- **`OnUnreliableAccuracy`**
    - API refs: `MagnetometerAccuracy.Unreliable`

### Screenshots
Initial state:

![initial](screenshots/03_3_Calibration__initial.png)


# NetworkConnectivity (C#)

> **Source**: `Samples\NetworkConnectivity\cs\`  
> **Feature**: NetworkingConnectivity  
> **AUMID**: `Microsoft.SDKSamples.NetworkConnectivity.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.NetworkConnectivity.CS_8wekyb3d8bbwe`  

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: failed
- uninstall: pending
- error: Could not find main window (looked for 'NetworkConnectivity C# Sample')

---

## Scenario 1 - Query network connectivity

### UI elements
- **TextBlock**  - text="This scenario shows how to query network connectivity, with or without opt-in network usage charges."
- **TextBlock**  - text="Use the network even if it may incur charges"
- **ToggleSwitch**  - x:Name="OptedInToNetworkUsageToggle"
- **Button**  - content="Check network connectivity"; events: Click=QueryCurrentNetworkConnectivityButton_Click
- **TextBlock**  - x:Name="ResultsText"

### Code behavior
- **`QueryCurrentNetworkConnectivityButton_Click`**
    - API refs: `ResultsText.Text`, `NetworkInformation.GetInternetConnectionProfile`, `NetworkConnectivityLevel.None`, `Helpers.AppendLine`, `Helpers.ShouldAttemptToConnectToInternet`, `Helpers.EvaluateCostAndConnectAsync`, `OptedInToNetworkUsageToggle.IsOn`

---

## Scenario 2 - Get network cost information

### UI elements
- **TextBlock**  - text="This scenario shows how to get network cost and how apps should respond to different cost types."
- **Button**  - content="Get network cost"; events: Click=GetNetworkCost_Click
- **TextBlock**  - x:Name="ResultsText"

### Code behavior
- **`GetNetworkCost_Click`**
    - API refs: `ResultsText.Text`, `NetworkInformation.GetInternetConnectionProfile`, `Helpers.AppendLine`, `Helpers.EvaluateAndReportConnectionCost`

---

## Scenario 3 - Listen to connectivity changes

### UI elements
- **TextBlock**  - text="This scenario registers for the NetworkStatusChanged event to track changes in network status and network cost, with or without opt-in network usage charges."
- **TextBlock**  - text="Use the network even if it may incur charges"
- **ToggleSwitch**  - x:Name="OptedInToNetworkUsageToggle"
- **Button**  - x:Name="RegisterUnregisterButton"; events: Click=RegisterUnregisterButton_Click
- **TextBlock**  - x:Name="EventStatusText"
- **TextBlock**  - x:Name="ResultsText"

### Code behavior
- **`UpdateNetworkStatus`**
    - API refs: `ResultsText.Text`, `NetworkInformation.GetInternetConnectionProfile`, `NetworkConnectivityLevel.None`, `Helpers.AppendLine`, `Helpers.ShouldAttemptToConnectToInternet`, `Helpers.EvaluateCostAndConnectAsync`, `OptedInToNetworkUsageToggle.IsOn`
- **`OnNetworkStatusChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`RegisterNetworkStatusChanged`**
    - API refs: `NetworkInformation.NetworkStatusChanged`
- **`UnregisterNetworkStatusChanged`**
    - API refs: `NetworkInformation.NetworkStatusChanged`
- **`UpdateButtonStates`**
    - API refs: `VisualStateManager.GoToState`


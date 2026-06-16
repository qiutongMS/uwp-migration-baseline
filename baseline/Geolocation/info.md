# Geolocation (C#)

> **Source**: `Samples\Geolocation\cs\`  
> **Feature**: Geolocation  
> **AUMID**: `Microsoft.SDKSamples.Geolocation.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.Geolocation.CS_8wekyb3d8bbwe`  

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: ok-generic
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - Track position

### UI elements
- **TextBlock**  - text="Geolocation API allows application to continuously track the position of the device either distance-based or periodic-based."
- **Button**  - x:Name="StartTrackingButton"; content="Start Tracking"; events: Click=StartTracking
- **Button**  - x:Name="StopTrackingButton"; content="Stop Tracking"; events: Click=StopTracking
- **TextBlock**  - text="Status: "
- **TextBlock**  - text="Latitude: "
- **TextBlock**  - text="Longitude: "
- **TextBlock**  - text="Accuracy: "
- **TextBlock**  - text="Source: "
- **TextBlock**  - text="IsRemoteSource: "
- **TextBlock**  - x:Name="ScenarioOutput_Status"; text="Unknown"
- **TextBlock**  - x:Name="ScenarioOutput_Latitude"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Longitude"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Accuracy"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Source"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_IsRemoteSource"; text="No data"
- **TextBlock**  - x:Name="LocationDisabledMessage"; text="Application is not able to get location data. Go to Settings to check the location permissions."

### Code behavior
- **`StartTracking`**
    - API refs: `Geolocator.RequestAccessAsync`, `GeolocationAccessStatus.Allowed`, `NotifyType.StatusMessage`, `LocationDisabledMessage.Visibility`, `Visibility.Collapsed`, `StartTrackingButton.IsEnabled`, `StopTrackingButton.IsEnabled`, `GeolocationAccessStatus.Denied`, `NotifyType.ErrorMessage`, `Visibility.Visible`, `GeolocationAccessStatus.Unspecified`
- **`StopTracking`**
    - API refs: `StartTrackingButton.IsEnabled`, `StopTrackingButton.IsEnabled`, `NotifyType.StatusMessage`
- **`OnPositionChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `NotifyType.StatusMessage`
- **`OnStatusChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `LocationDisabledMessage.Visibility`, `Visibility.Collapsed`, `PositionStatus.Ready`, `ScenarioOutput_Status.Text`, `NotifyType.StatusMessage`, `PositionStatus.Initializing`, `PositionStatus.NoData`, `NotifyType.ErrorMessage`, `PositionStatus.Disabled`, `Visibility.Visible`, `PositionStatus.NotInitialized`, `PositionStatus.NotAvailable`
- **`UpdateLocationData`**
    - API refs: `ScenarioOutput_Latitude.Text`, `ScenarioOutput_Longitude.Text`, `ScenarioOutput_Accuracy.Text`, `ScenarioOutput_Source.Text`, `ScenarioOutput_IsRemoteSource.Text`, `Coordinate.Point`, `Position.Latitude`, `Position.Longitude`, `Coordinate.Accuracy`, `Coordinate.PositionSource`, `Coordinate.IsRemoteSource`

### Screenshots
Initial state:

![initial](screenshots/00_main.png)

---

## Scenario 2 - Get position

### UI elements
- **TextBlock**  - text="Geolocation API allows application to take a one-shot reading of the current position."
- **TextBlock**  - text="DesiredAccuracy (meters): "
- **TextBox**  - x:Name="DesiredAccuracyInMeters"; text="0"
- **TextBlock**  - text="(Set accuracy = 0 to use system default.)"
- **Button**  - x:Name="GetGeolocationButton"; content="Get Geolocation"; events: Click=GetGeolocationButtonClicked
- **Button**  - x:Name="CancelGetGeolocationButton"; content="Cancel"; events: Click=CancelGetGeolocationButtonClicked
- **TextBlock**  - text="Latitude: "
- **TextBlock**  - text="Longitude: "
- **TextBlock**  - text="Accuracy: "
- **TextBlock**  - text="Source: "
- **TextBlock**  - text="IsRemoteSource: "
- **TextBlock**  - x:Name="Label_DilutionOfPrecision"; text="Dilution Of Precision (DOP): "
- **TextBlock**  - x:Name="Label_PosPrecision"; text="Position DOP: "
- **TextBlock**  - x:Name="Label_HorzPrecision"; text="Horizontal DOP: "
- **TextBlock**  - x:Name="Label_VertPrecision"; text="Vertical DOP: "
- **TextBlock**  - x:Name="Label_GeomPrecision"; text="Geometric DOP: "
- **TextBlock**  - x:Name="Label_TimePrecision"; text="Time DOP: "
- **TextBlock**  - x:Name="ScenarioOutput_Latitude"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Longitude"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Accuracy"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Source"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_IsRemoteSource"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_PosPrecision"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_HorzPrecision"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_VertPrecision"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_GeomPrecision"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_TimePrecision"; text="No data"
- **TextBlock**  - x:Name="LocationDisabledMessage"; text="Application is not able to get location data. Go to Settings to check the location permissions."

### Code behavior
- **`GetGeolocationButtonClicked`**
    - instantiates: `CancellationTokenSource`
    - API refs: `GetGeolocationButton.IsEnabled`, `CancelGetGeolocationButton.IsEnabled`, `LocationDisabledMessage.Visibility`, `Visibility.Collapsed`, `Geolocator.RequestAccessAsync`, `GeolocationAccessStatus.Allowed`, `NotifyType.StatusMessage`, `DesiredAccuracy.Default`, `DesiredAccuracyInMeters.Text`, `GeolocationAccessStatus.Denied`, `NotifyType.ErrorMessage`, `Visibility.Visible`, `GeolocationAccessStatus.Unspecified`
- **`CancelGetGeolocationButtonClicked`**
    - API refs: `GetGeolocationButton.IsEnabled`, `CancelGetGeolocationButton.IsEnabled`
- **`UpdateLocationData`**
    - API refs: `ScenarioOutput_Latitude.Text`, `ScenarioOutput_Longitude.Text`, `ScenarioOutput_Accuracy.Text`, `ScenarioOutput_Source.Text`, `ScenarioOutput_IsRemoteSource.Text`, `Coordinate.Point`, `Position.Latitude`, `Position.Longitude`, `Coordinate.Accuracy`, `Coordinate.PositionSource`, `Coordinate.IsRemoteSource`, `PositionSource.Satellite`, `ScenarioOutput_PosPrecision.Text`, `Coordinate.SatelliteData`, `PositionDilutionOfPrecision.ToString`, `ScenarioOutput_HorzPrecision.Text`, `HorizontalDilutionOfPrecision.ToString`, `ScenarioOutput_VertPrecision.Text`, `VerticalDilutionOfPrecision.ToString`, `ScenarioOutput_GeomPrecision.Text`, `GeometricDilutionOfPrecision.ToString`, `ScenarioOutput_TimePrecision.Text`, `TimeDilutionOfPrecision.ToString`
- **`ShowSatelliteData`**
    - API refs: `Visibility.Visible`, `Visibility.Collapsed`, `ScenarioOutput_PosPrecision.Visibility`, `ScenarioOutput_HorzPrecision.Visibility`, `ScenarioOutput_VertPrecision.Visibility`, `ScenarioOutput_GeomPrecision.Visibility`, `ScenarioOutput_TimePrecision.Visibility`

---

## Scenario 3 - Background position

### UI elements
- **TextBlock**  - x:Name="InputTextBlock"; text="Registers a background task to read geolocation on a periodic timer. Displayed position will be updated periodically when the background task runs (set in the sample to every 15 minutes)."
- **Button**  - x:Name="RegisterBackgroundTaskButton"; content="Register"; events: Click=RegisterBackgroundTask
- **Button**  - x:Name="UnregisterBackgroundTaskButton"; content="Unregister"; events: Click=UnregisterBackgroundTask
- **TextBlock**  - text="Latitude: "
- **TextBlock**  - text="Longitude: "
- **TextBlock**  - text="Accuracy: "
- **TextBlock**  - x:Name="ScenarioOutput_Latitude"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Longitude"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Accuracy"; text="No data"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `MainPage.LookupBackgroundTask`
- **`RegisterBackgroundTask`**
    - instantiates: `BackgroundTaskBuilder`, `TimeTrigger`
    - API refs: `MainPage.CheckBackgroundAndRequestLocationAccess`
- **`UnregisterBackgroundTask`**
    - API refs: `ScenarioOutput_Latitude.Text`, `ScenarioOutput_Longitude.Text`, `ScenarioOutput_Accuracy.Text`, `NotifyType.StatusMessage`
- **`OnCompleted`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `MainPage.ReportSavedStatus`, `ScenarioOutput_Latitude.Text`, `MainPage.LookupSavedString`, `ScenarioOutput_Longitude.Text`, `ScenarioOutput_Accuracy.Text`, `NotifyType.ErrorMessage`
- **`UpdateButtonStates`**
    - API refs: `RegisterBackgroundTaskButton.IsEnabled`, `UnregisterBackgroundTaskButton.IsEnabled`

---

## Scenario 4 - Foreground geofencing

### UI elements
- **TextBlock**  - text="Geofence API allows applications to add, list and remove geofences that will be monitored by the system."
- **TextBlock**  - text="*"
- **TextBlock**  - text="Indicates Required Fields"
- **TextBlock**  - text="Name"
- **TextBlock**  - text="*"
- **TextBox**  - x:Name="Id"
- **TextBlock**  - text="up to 64 characters"
- **Button**  - x:Name="SetPositionToHereButton"; content="Set to Here"; events: Click=OnSetPositionToHere
- **ProgressBar**  - x:Name="SetPositionProgressBar"
- **TextBlock**  - text="Latitude"
- **TextBlock**  - text="*"
- **TextBox**  - x:Name="Latitude"
- **TextBlock**  - text="-90 to 90 degrees"
- **TextBlock**  - text="Longitude"
- **TextBlock**  - text="*"
- **TextBox**  - name="Longitude"
- **TextBlock**  - text="-180 to 180 degrees"
- **TextBlock**  - text="Radius"
- **TextBlock**  - text="*"
- **TextBox**  - x:Name="Radius"
- **TextBlock**  - text=".1 to 10018754.3 m"
- **TextBlock**  - text="Dwell Time"
- **TextBox**  - x:Name="DwellTime"
- **TextBlock**  - text="Format: d:hh:mm:ss"
- **TextBlock**  - text="Leading zeros may be omitted."
- **TextBlock**  - text="Start Time"
- **RadioButton**  - x:Name="StartImmediately"
- **RadioButton**  - x:Name="StartAtSpecificTime"
- **DatePicker**  - x:Name="StartDate"
- **TimePicker**  - x:Name="StartTime"
- **TextBlock**  - text="Duration"
- **TextBox**  - name="Duration"
- **TextBlock**  - text="If 0, then infinite duration."
- **TextBlock**  - text="Format: d:hh:mm:ss"
- **TextBlock**  - text="Leading zeros may be omitted."
- **CheckBox**  - x:Name="SingleUse"; content="Single Use"
- **Button**  - x:Name="CreateGeofenceButton"; content="Create Geofence"; events: Click=OnCreateGeofence
- **TextBlock**  - text="Registered geofences"
- **ListBox**  - x:Name="RegisteredGeofenceListBox"; events: SelectionChanged=OnRegisteredGeofenceListBoxSelectionChanged
- **Button**  - x:Name="RemoveGeofenceItem"; content="Remove Geofence"; events: Click=OnRemoveGeofenceItem
- **TextBlock**  - text="Events"
- **ListBox**  - x:Name="GeofenceEventsListBox"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `Window.Current`, `DateTime.Now`, `StartDate.Date`, `StartTime.Time`, `Geolocator.RequestAccessAsync`, `GeolocationAccessStatus.Allowed`, `GeofenceMonitor.Current`, `NotifyType.ErrorMessage`, `GeolocationAccessStatus.Denied`, `GeolocationAccessStatus.Unspecified`
- **`OnNavigatedFrom`**
    - API refs: `Window.Current`
- **`OnGeofenceStatusChanged`**
    - API refs: `DateTime.Now`, `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`OnGeofenceStateChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `DateTime.Now`, `GeofenceState.Removed`, `RemovalReason.ToString`, `Geofences.Remove`, `RegisteredGeofenceListBox.Items`, `GeofenceState.Entered`, `GeofenceState.Exited`
- **`OnRemoveGeofenceItem`**
    - API refs: `RegisteredGeofenceListBox.SelectedItem`, `Geofences.Remove`, `RegisteredGeofenceListBox.Items`
- **`GenerateGeofence`**
    - instantiates: `Geocircle`, `Geofence`
    - API refs: `NotifyType.StatusMessage`, `Id.Text`, `NotifyType.ErrorMessage`, `SingleUse.IsChecked`, `MonitoredGeofenceStates.Entered`, `MonitoredGeofenceStates.Exited`, `MonitoredGeofenceStates.Removed`, `DwellTime.Text`, `Duration.Text`, `TimeSpan.Zero`, `StartImmediately.IsChecked`, `DateTimeOffset.Now`, `StartDate.Date`, `StartTime.Time`
- **`OnRegisteredGeofenceListBoxSelectionChanged`**
    - API refs: `AddedItems.Count`, `RemoveGeofenceItem.IsEnabled`, `RegisteredGeofenceListBox.SelectedItem`
- **`RefreshControlsFromGeofence`**
    - API refs: `Id.Text`, `Latitude.Text`, `Center.Latitude`, `Longitude.Text`, `Center.Longitude`, `Radius.Text`, `Radius.ToString`, `SingleUse.IsChecked`, `TimeSpan.Zero`, `DwellTime.Text`, `DwellTime.ToString`, `Duration.Text`, `Duration.ToString`, `StartImmediately.IsChecked`, `StartAtSpecificTime.IsChecked`, `StartDate.Date`, `StartTime.Date`, `StartTime.Time`, `StartTime.TimeOfDay`
- **`ParseDoubleFromTextBox`**
    - API refs: `Double.TryParse`, `NotifyType.StatusMessage`
- **`AddGeofenceToRegisteredGeofenceListBox`**
    - API refs: `Center.Latitude`, `Center.Longitude`, `RegisteredGeofenceListBox.Items`
- **`OnSetPositionToHere`**
    - instantiates: `CancellationTokenSource`, `Geolocator`
    - API refs: `SetPositionProgressBar.Visibility`, `Visibility.Visible`, `SetPositionToHereButton.IsEnabled`, `Latitude.IsEnabled`, `Longitude.IsEnabled`, `PositionAccuracy.High`, `Latitude.Text`, `Coordinate.Point`, `Position.Latitude`, `Longitude.Text`, `Position.Longitude`, `NotifyType.StatusMessage`, `NotifyType.ErrorMessage`, `Visibility.Collapsed`
- **`OnCreateGeofence`**
    - API refs: `Geofences.Add`, `NotifyType.ErrorMessage`
- **`AddEventDescription`**
    - API refs: `GeofenceEventsListBox.Items`
- **`ParseTimeSpan`**
    - API refs: `TimeSpan.Zero`, `Array.Reverse`, `TimeSpan.FromDays`, `TimeSpan.FromHours`, `TimeSpan.FromMinutes`, `TimeSpan.FromSeconds`

---

## Scenario 5 - Background geofencing

### UI elements
- **TextBlock**  - text="Control registration of a background task to receive geofencing events. Geofences need to be created using the Foreground Geofencing scenario before background geofence events can occur."
- **Button**  - x:Name="RegisterBackgroundTaskButton"; content="Register"; events: Click=RegisterBackgroundTask
- **Button**  - x:Name="UnregisterBackgroundTaskButton"; content="Unregister"; events: Click=UnregisterBackgroundTask
- **TextBlock**  - text="Geofence events"
- **ListBox**  - name="GeofenceBackgroundEventsListBox"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `MainPage.LookupBackgroundTask`
- **`RegisterBackgroundTask`**
    - instantiates: `BackgroundTaskBuilder`, `LocationTrigger`, `SystemCondition`
    - API refs: `LocationTriggerType.Geofence`, `SystemConditionType.UserPresent`, `SystemConditionType.InternetAvailable`, `MainPage.CheckBackgroundAndRequestLocationAccess`
- **`UnregisterBackgroundTask`**
    - API refs: `NotifyType.StatusMessage`
- **`OnCompleted`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `MainPage.ReportSavedStatus`, `NotifyType.ErrorMessage`
- **`UpdateButtonStates`**
    - API refs: `RegisterBackgroundTaskButton.IsEnabled`, `UnregisterBackgroundTaskButton.IsEnabled`
- **`FillEventListBoxWithExistingEvents`**
    - API refs: `MainPage.FillItemsFromSavedJson`

---

## Scenario 6 - Get last visit

### UI elements
- **TextBlock**  - text="Geolocation API allows application to get the last visit report."
- **Button**  - x:Name="GetLastVisitButton"; content="Get last Visit"; events: Click=GetLastVisitButtonClicked
- **TextBlock**  - text="State change: "
- **TextBlock**  - text="Timestamp: "
- **TextBlock**  - text="Latitude: "
- **TextBlock**  - text="Longitude: "
- **TextBlock**  - text="Accuracy: "
- **TextBlock**  - text="IsRemoteSource: "
- **TextBlock**  - x:Name="ScenarioOutput_VisitStateChange"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Timestamp"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Latitude"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Longitude"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Accuracy"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_IsRemoteSource"; text="No data"
- **TextBlock**  - x:Name="LocationDisabledMessage"; text="Application is not able to get location data. Go to Settings to check the location permissions."

### Code behavior
- **`GetLastVisitButtonClicked`**
    - API refs: `GetLastVisitButton.IsEnabled`, `LocationDisabledMessage.Visibility`, `Visibility.Collapsed`, `Geolocator.RequestAccessAsync`, `GeolocationAccessStatus.Allowed`, `NotifyType.StatusMessage`, `GeovisitMonitor.GetLastReportAsync`, `GeolocationAccessStatus.Denied`, `NotifyType.ErrorMessage`, `Visibility.Visible`, `GeolocationAccessStatus.Unspecified`
- **`UpdateLastVisit`**
    - API refs: `ScenarioOutput_Latitude.Text`, `ScenarioOutput_Longitude.Text`, `ScenarioOutput_Accuracy.Text`, `ScenarioOutput_Timestamp.Text`, `ScenarioOutput_VisitStateChange.Text`, `StateChange.ToString`, `Timestamp.ToString`, `ScenarioOutput_IsRemoteSource.Text`, `Position.Coordinate`, `Point.Position`, `Latitude.ToString`, `Longitude.ToString`, `Accuracy.ToString`, `IsRemoteSource.ToString`

---

## Scenario 7 - Foreground visit monitoring

### UI elements
- **TextBlock**  - text="Geolocation API allows application to monitor user's visits in the foreground."
- **Button**  - x:Name="StartMonitoringButton"; content="Start Monitoring"; events: Click=StartMonitoring
- **Button**  - x:Name="StopMonitoringButton"; content="Stop Monitoring"; events: Click=StopMonitoring
- **TextBlock**  - text="State change: "
- **TextBlock**  - text="Timestamp: "
- **TextBlock**  - text="Latitude: "
- **TextBlock**  - text="Longitude: "
- **TextBlock**  - text="Accuracy: "
- **TextBlock**  - text="IsRemoteSource: "
- **TextBlock**  - x:Name="ScenarioOutput_VisitStateChange"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Timestamp"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Latitude"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Longitude"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_Accuracy"; text="No data"
- **TextBlock**  - x:Name="ScenarioOutput_IsRemoteSource"; text="No data"
- **TextBlock**  - x:Name="LocationDisabledMessage"; text="Application is not able to get location data. Go to Settings to check the location permissions."

### Code behavior
- **`StartMonitoring`**
    - instantiates: `GeovisitMonitor`
    - API refs: `Geolocator.RequestAccessAsync`, `GeolocationAccessStatus.Allowed`, `VisitMonitoringScope.Venue`, `LocationDisabledMessage.Visibility`, `Visibility.Collapsed`, `NotifyType.StatusMessage`, `StartMonitoringButton.IsEnabled`, `StopMonitoringButton.IsEnabled`, `GeolocationAccessStatus.Denied`, `NotifyType.ErrorMessage`, `Visibility.Visible`, `GeolocationAccessStatus.Unspecified`
- **`StopMonitoring`**
    - API refs: `StartMonitoringButton.IsEnabled`, `StopMonitoringButton.IsEnabled`, `NotifyType.StatusMessage`
- **`OnVisitStateChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `NotifyType.StatusMessage`
- **`UpdateVisitData`**
    - API refs: `ScenarioOutput_VisitStateChange.Text`, `StateChange.ToString`, `ScenarioOutput_Timestamp.Text`, `Timestamp.ToString`, `ScenarioOutput_Latitude.Text`, `ScenarioOutput_Longitude.Text`, `ScenarioOutput_Accuracy.Text`, `ScenarioOutput_IsRemoteSource.Text`, `Position.Coordinate`, `Point.Position`, `Latitude.ToString`, `Longitude.ToString`, `Accuracy.ToString`, `IsRemoteSource.ToString`

---

## Scenario 8 - Background visit monitoring

### UI elements
- **TextBlock**  - x:Name="InputTextBlock"; text="Control registration of a background task to receive Visit state change events."
- **Button**  - x:Name="RegisterBackgroundTaskButton"; content="Register"; events: Click=RegisterBackgroundTask
- **Button**  - x:Name="UnregisterBackgroundTaskButton"; content="Unregister"; events: Click=UnregisterBackgroundTask
- **TextBlock**  - text="Visit events"
- **ListBox**  - name="VisitBackgroundEventsListBox"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `MainPage.LookupBackgroundTask`
- **`RegisterBackgroundTask`**
    - instantiates: `BackgroundTaskBuilder`, `GeovisitTrigger`, `SystemCondition`
    - API refs: `BackgroundExecutionManager.RequestAccessAsync`, `VisitMonitoringScope.Venue`, `SystemConditionType.UserPresent`, `SystemConditionType.InternetAvailable`, `MainPage.CheckBackgroundAndRequestLocationAccess`
- **`UnregisterBackgroundTask`**
    - API refs: `NotifyType.StatusMessage`
- **`OnCompleted`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `MainPage.ReportSavedStatus`, `NotifyType.ErrorMessage`
- **`UpdateButtonStates`**
    - API refs: `RegisterBackgroundTaskButton.IsEnabled`, `UnregisterBackgroundTaskButton.IsEnabled`
- **`FillEventListBoxWithExistingEvents`**
    - API refs: `MainPage.FillItemsFromSavedJson`


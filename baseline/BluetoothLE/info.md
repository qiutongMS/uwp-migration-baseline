# BluetoothLE (C#)

> **Source**: `Samples\BluetoothLE\cs\`  
> **Feature**: Bluetooth Low Energy C# Sample  
> **AUMID**: `Microsoft.SDKSamples.BluetoothLE.CS_8wekyb3d8bbwe!BluetoothLE.App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.BluetoothLE.CS_8wekyb3d8bbwe`  

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: failed
- uninstall: pending
- error: Could not find main window (looked for 'Bluetooth Low Energy C# sample')

---

## Scenario 1 - Client: Discover servers

### UI elements
- **TextBlock**  - text="Name:"
- **TextBlock**  - text="IsPaired: , IsConnected: , IsConnectable:"
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Discover GATT servers"
- **TextBlock**  - text="Enumerate nearby Bluetooth Low Energy devices, then select and pair a device, so that it can be used in the next scenario."
- **Button**  - x:Name="EnumerateButton"; content="Start enumerating"; events: Click=EnumerateButton_Click
- **Button**  - x:Name="PairButton"; content="Pair"; events: Click=PairButton_Click
- **ListView**  - x:Name="ResultsListView"

### Code behavior
- **`OnNavigatedFrom`**
    - API refs: `ResultsListView.SelectedItem`
- **`EnumerateButton_Click`**
    - API refs: `EnumerateButton.Content`, `NotifyType.StatusMessage`
- **`StartBleDeviceWatcher`**
    - API refs: `System.Devices`, `Aep.DeviceAddress`, `Aep.IsConnected`, `Aep.Bluetooth`, `Le.IsConnectable`, `Aep.ProtocolId`, `DeviceInformation.CreateWatcher`, `DeviceInformationKind.AssociationEndpoint`, `KnownDevices.Clear`
- **`DeviceWatcher_Added`**
    - instantiates: `BluetoothLEDeviceDisplay`
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `Debug.WriteLine`, `String.Format`, `KnownDevices.Add`
- **`DeviceWatcher_Updated`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `Debug.WriteLine`, `String.Format`, `KnownDevices.Add`
- **`DeviceWatcher_Removed`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `Debug.WriteLine`, `String.Format`, `KnownDevices.Remove`
- **`DeviceWatcher_EnumerationCompleted`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `KnownDevices.Count`, `NotifyType.StatusMessage`
- **`DeviceWatcher_Stopped`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `DeviceWatcherStatus.Aborted`, `NotifyType.ErrorMessage`, `NotifyType.StatusMessage`
- **`PairButton_Click`**
    - API refs: `NotifyType.StatusMessage`, `ResultsListView.SelectedItem`, `DeviceInformation.Pairing`, `DevicePairingResultStatus.Paired`, `DevicePairingResultStatus.AlreadyPaired`, `NotifyType.ErrorMessage`

---

## Scenario 2 - Client: Connect to a server

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Query services from GATT server"
- **TextBlock**  - text="This scenario connects to the Bluetooth Low Energy device selected in the "Discover GATT Servers" scenario and communicates with the device."
- **TextBlock**  - text="Selected device:"
- **Button**  - x:Name="ConnectButton"; content="Connect"; events: Click=ConnectButton_Click
- **ComboBox**  - x:Name="ServiceList"; events: SelectionChanged=ServiceList_SelectionChanged
- **ComboBox**  - x:Name="CharacteristicList"; events: SelectionChanged=CharacteristicList_SelectionChanged
- **Button**  - x:Name="CharacteristicReadButton"; content="Read Value"; events: Click=CharacteristicReadButton_Click
- **Button**  - x:Name="ValueChangedSubscribeToggle"; content="Subscribe to value changes"; events: Click=ValueChangedSubscribeToggle_Click
- **TextBox**  - x:Name="CharacteristicWriteValue"
- **Button**  - content="Write Value as Number"; events: Click=CharacteristicWriteButtonInt_Click
- **Button**  - content="Write Value as UTF-8"; events: Click=CharacteristicWriteButton_Click
- **TextBlock**  - x:Name="CharacteristicLatestValue"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `SelectedDeviceRun.Text`, `ConnectButton.IsEnabled`
- **`ClearBluetoothLEDeviceAsync`**
    - API refs: `GattClientCharacteristicConfigurationDescriptorValue.None`, `GattCommunicationStatus.Success`, `NotifyType.ErrorMessage`
- **`ConnectButton_Click`**
    - API refs: `ConnectButton.IsEnabled`, `ServiceList.Visibility`, `Visibility.Collapsed`, `BluetoothLEDevice.FromIdAsync`, `BluetoothLEDevice.GattServices`, `BluetoothCacheMode.Uncached`, `GattCommunicationStatus.Success`, `String.Format`, `NotifyType.StatusMessage`, `ServiceList.Items`, `DisplayHelpers.GetServiceName`, `ConnectButton.Visibility`, `Visibility.Visible`, `Utilities.FormatGattCommunicationStatus`, `NotifyType.ErrorMessage`
- **`ServiceList_SelectionChanged`**
    - API refs: `CharacteristicList.Items`, `CharacteristicList.Visibility`, `Visibility.Collapsed`, `ServiceList.SelectedItem`, `NotifyType.ErrorMessage`, `DeviceAccessStatus.Allowed`, `BluetoothCacheMode.Uncached`, `GattCommunicationStatus.Success`, `Utilities.FormatGattCommunicationStatus`, `DisplayHelpers.GetCharacteristicName`, `Visibility.Visible`
- **`AddValueChangedHandler`**
    - API refs: `ValueChangedSubscribeToggle.Content`
- **`RemoveValueChangedHandler`**
    - API refs: `ValueChangedSubscribeToggle.Content`
- **`CharacteristicList_SelectionChanged`**
    - API refs: `CharacteristicList.SelectedItem`, `GattCharacteristicProperties.None`, `NotifyType.ErrorMessage`, `BluetoothCacheMode.Uncached`, `GattCommunicationStatus.Success`, `Utilities.FormatGattCommunicationStatus`
- **`SetVisibility`**
    - API refs: `Visibility.Visible`, `Visibility.Collapsed`
- **`EnableCharacteristicPanels`**
    - API refs: `GattCharacteristicProperties.Read`, `GattCharacteristicProperties.Write`, `GattCharacteristicProperties.WriteWithoutResponse`, `CharacteristicWriteValue.Text`, `GattCharacteristicProperties.Indicate`, `GattCharacteristicProperties.Notify`, `ValueChangedSubscribeToggle.IsEnabled`
- **`CharacteristicReadButton_Click`**
    - API refs: `BluetoothCacheMode.Uncached`, `GattCommunicationStatus.Success`, `NotifyType.StatusMessage`, `Utilities.FormatGattCommunicationStatus`, `NotifyType.ErrorMessage`
- **`CharacteristicWriteButton_Click`**
    - API refs: `String.IsNullOrEmpty`, `CharacteristicWriteValue.Text`, `CryptographicBuffer.ConvertStringToBinary`, `BinaryStringEncoding.Utf8`, `NotifyType.ErrorMessage`
- **`CharacteristicWriteButtonInt_Click`**
    - API refs: `Int32.TryParse`, `CharacteristicWriteValue.Text`, `BufferHelpers.BufferFromInt32`, `NotifyType.ErrorMessage`
- **`WriteBufferToSelectedCharacteristicAsync`**
    - API refs: `GattCommunicationStatus.Success`, `NotifyType.StatusMessage`, `Utilities.FormatGattCommunicationStatus`, `NotifyType.ErrorMessage`
- **`ValueChangedSubscribeToggle_Click`**
    - API refs: `GattClientCharacteristicConfigurationDescriptorValue.None`, `CharacteristicProperties.HasFlag`, `GattCharacteristicProperties.Indicate`, `GattClientCharacteristicConfigurationDescriptorValue.Indicate`, `GattCharacteristicProperties.Notify`, `GattClientCharacteristicConfigurationDescriptorValue.Notify`, `GattCommunicationStatus.Success`, `NotifyType.StatusMessage`, `Utilities.FormatGattCommunicationStatus`, `NotifyType.ErrorMessage`
- **`Characteristic_ValueChanged`**
    - API refs: `DisplayHelpers.GetCharacteristicName`, `DateTime.Now`, `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `CharacteristicLatestValue.Text`
- **`FormatValueByPresentation`**
    - API refs: `PresentationFormats.Count`, `CryptographicBuffer.CopyToByteArray`, `GattPresentationFormatTypes.UInt32`, `BitConverter.ToInt32`, `GattPresentationFormatTypes.Utf8`, `Encoding.UTF8`, `CryptographicBuffer.EncodeToHexString`, `Uuid.Equals`, `GattCharacteristicUuids.HeartRateMeasurement`, `GattCharacteristicUuids.BatteryLevel`, `Constants.ResultCharacteristicUuid`, `Constants.BackgroundResultUuid`
- **`ParseHeartRateValue`**
    - API refs: `BitConverter.ToUInt16`

---

## Scenario 3 - Server: Publish foreground

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Publish the calculator service"
- **TextBlock**  - text="This scenario publishes a calculator service. Remote clients (including this sample on another machine) can connect to service , then supply 2 operands and an operator and get a result."
- **TextBlock**  - x:Name="PeripheralWarning"; text="There is no Bluetooth device, or the default Bluetooth device cannot act as a Bluetooth server."
- **CheckBox**  - x:Name="Publishing2MPHY"; events: Click=Publishing2MPHY_Click
- **TextBlock**  - text="Advertising with 2M PHY as secondary PHY"
- **Button**  - x:Name="PublishButton"; content="Start Service"; events: Click=PublishButton_Click
- **TextBox**  - name="Operand1TextBox"; text="0"
- **TextBlock**  - name="Operand1Label"; text="Operand 1 (integer)"
- **TextBox**  - name="OperationTextBox"; text="INV"
- **TextBlock**  - x:Name="OperationLabel"; text="Operator"
- **TextBox**  - name="Operand2TextBox"; text="0"
- **TextBlock**  - name="Operand2Label"; text="Operand 2 (integer)"
- **TextBox**  - name="ResultTextBox"; text="0"
- **TextBlock**  - name="ResultLabel"; text="Result"
- **TextBlock**  - text="Operator codes: 1: addition 2: subtraction 3: multiplication 4: division"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `BluetoothAdapter.GetDefaultAsync`, `ServerPanel.Visibility`, `Visibility.Visible`, `PeripheralWarning.Visibility`, `FeatureDetection.AreExtendedAdvertisingPhysAndScanParametersSupported`, `Publishing2MPHYReasonRun.Text`, `Publishing2MPHY.IsEnabled`
- **`OnNavigatedFrom`**
    - API refs: `GattServiceProviderAdvertisementStatus.Stopped`
- **`PublishButton_Click`**
    - API refs: `PublishButton.Content`, `NotifyType.StatusMessage`, `NotifyType.ErrorMessage`
- **`Publishing2MPHY_Click`**
    - API refs: `Publishing2MPHY.IsChecked`
- **`UpdateUI`**
    - API refs: `CalculatorOperators.Add`, `CalculatorOperators.Subtract`, `CalculatorOperators.Multiply`, `CalculatorOperators.Divide`, `OperationTextBox.Text`, `Operand1TextBox.Text`, `Operand2TextBox.Text`, `ResultTextBox.Text`
    - updates UI: `OperationTextBox.Text`, `Operand1TextBox.Text`, `Operand2TextBox.Text`, `ResultTextBox.Text`
- **`CreateAndAdvertiseServiceAsync`**
    - API refs: `GattServiceProvider.CreateAsync`, `Constants.CalculatorServiceUuid`, `BluetoothError.Success`, `NotifyType.ErrorMessage`, `Service.CreateCharacteristicAsync`, `Constants.Operand1CharacteristicUuid`, `Constants.Operand2CharacteristicUuid`, `Constants.OperatorCharacteristicUuid`, `Constants.ResultCharacteristicUuid`
- **`ResultCharacteristic_SubscribedClientsChanged`**
    - API refs: `SubscribedClients.Count`, `NotifyType.StatusMessage`
- **`ServiceProvider_AdvertisementStatusChanged`**
    - API refs: `NotifyType.StatusMessage`
- **`ResultCharacteristic_ReadRequestedAsync`**
    - API refs: `NotifyType.ErrorMessage`, `BufferHelpers.BufferFromInt32`
- **`ComputeResult`**
    - API refs: `CalculatorOperators.Add`, `CalculatorOperators.Subtract`, `CalculatorOperators.Multiply`, `CalculatorOperators.Divide`, `Int32.MinValue`, `NotifyType.ErrorMessage`
- **`NotifyClientDevices`**
    - API refs: `BufferHelpers.BufferFromInt32`, `NotifyType.StatusMessage`, `GattCommunicationStatus.ProtocolError`
- **`Op1Characteristic_WriteRequestedAsync`**
    - API refs: `CalculatorCharacteristics.Operand1`
- **`Op2Characteristic_WriteRequestedAsync`**
    - API refs: `CalculatorCharacteristics.Operand2`
- **`OperatorCharacteristic_WriteRequestedAsync`**
    - API refs: `CalculatorCharacteristics.Operator`
- **`ProcessWriteCharacteristic`**
    - API refs: `BufferHelpers.Int32FromBuffer`, `GattWriteOption.WriteWithResponse`, `GattProtocolError.InvalidAttributeValueLength`, `CalculatorCharacteristics.Operand1`, `CalculatorCharacteristics.Operand2`, `CalculatorCharacteristics.Operator`, `Enum.IsDefined`, `GattProtocolError.InvalidPdu`, `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`

---

## Scenario 4 - Server: Publish background

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Publish the calculator service"
- **TextBlock**  - x:Name="PeripheralWarning"; text="There is no Bluetooth device, or the default Bluetooth device cannot act as a Bluetooth server."
- **CheckBox**  - x:Name="Publishing2MPHY"; events: Click=Publishing2MPHY_Click
- **TextBlock**  - text="Advertising with 2M PHY as secondary PHY"
- **Button**  - x:Name="PublishButton"; content="Start Service"; events: Click=PublishOrStopButton_Click
- **TextBox**  - name="Operand1TextBox"; text="0"
- **TextBlock**  - name="Operand1Label"; text="Operand 1 (integer)"
- **TextBox**  - name="OperationTextBox"; text="INV"
- **TextBlock**  - x:Name="OperationLabel"; text="Operator"
- **TextBox**  - name="Operand2TextBox"; text="0"
- **TextBlock**  - name="Operand2Label"; text="Operand 2 (integer)"
- **TextBox**  - name="ResultTextBox"; text="0"
- **TextBlock**  - name="ResultLabel"; text="Result"
- **TextBlock**  - text="Operator codes: 1: addition 2: subtraction 3: multiplication 4: division"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `BackgroundTaskRegistration.AllTasks`, `NotifyType.StatusMessage`, `PublishButton.Content`, `BluetoothAdapter.GetDefaultAsync`, `ServerPanel.Visibility`, `Visibility.Visible`, `FeatureDetection.AreExtendedAdvertisingPhysAndScanParametersSupported`, `Publishing2MPHYReasonRun.Text`, `Publishing2MPHY.IsEnabled`, `PeripheralWarning.Visibility`, `Application.Current`
- **`OnNavigatedFrom`**
    - API refs: `Application.Current`
- **`UpdateUI`**
    - API refs: `Operand1TextBox.Text`, `CalculatorOperators.Add`, `CalculatorOperators.Subtract`, `CalculatorOperators.Multiply`, `CalculatorOperators.Divide`, `OperationTextBox.Text`, `Operand2TextBox.Text`, `ResultTextBox.Text`
    - updates UI: `Operand1TextBox.Text`, `OperationTextBox.Text`, `Operand2TextBox.Text`, `ResultTextBox.Text`
- **`OnCalculatorValuesChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`StartUpdatingUI`**
    - API refs: `CalculatorServerBackgroundTask.ValuesChanged`
- **`StopUpdatingUI`**
    - API refs: `CalculatorServerBackgroundTask.ValuesChanged`
- **`Publishing2MPHY_Click`**
    - API refs: `GattServiceProviderConnection.AllServices`, `Publishing2MPHY.IsChecked`
- **`PublishOrStopButton_Click`**
    - API refs: `PublishButton.Content`
- **`CreateBackgroundServiceAsync`**
    - instantiates: `BackgroundTaskBuilder`
    - API refs: `GattServiceProviderTrigger.CreateAsync`, `Constants.BackgroundCalculatorServiceUuid`, `BluetoothError.Success`, `NotifyType.ErrorMessage`, `Service.CreateCharacteristicAsync`, `Constants.BackgroundOperand1Uuid`, `Constants.BackgroundOperand2Uuid`, `Constants.BackgroundOperatorUuid`, `Constants.BackgroundResultUuid`, `Publishing2MPHY.IsChecked`, `BackgroundExecutionManager.RequestAccessAsync`, `BackgroundAccessStatus.AlwaysAllowed`, `BackgroundAccessStatus.AllowedSubjectToSystemPolicy`, `NotifyType.StatusMessage`


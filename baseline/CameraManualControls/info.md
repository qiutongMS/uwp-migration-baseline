# CameraManualControls (C#)

> **Source**: `Samples\CameraManualControls\cs\`  
> **AUMID**: `Microsoft.SDKSamples.CameraManualControls.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.CameraManualControls.CS_8wekyb3d8bbwe`  

## Sample purpose
An end-to-end sample camera app using the Windows.Media.Capture API and orientation sensors.

## Scenarios demonstrated (from README)
- **Manage the MediaCapture object** throughout the lifecycle of the app and through navigation events.
- **Acquire a camera located on a specific side of the device**. In this case, the sample attempts to get the rear camera.
- **Start and stop the preview** to a UI element, including mirroring for front-facing cameras.
- **Take a picture** to a file (taking into account the orientation of the device), and disable the video capture button if the app is running on a device that doesn't support concurrent capturing of photos and video.
- **Record a video** to a file, and disable the photo capture button if the app is running on a device that doesn't support concurrent capturing of photos and video.
- **Discover the capabilities of a device** regarding the following advanced camera controls:
- Flash and video light
- Zoom, including Smooth Zoom if supported by the device
- Focus: manual, continuous, and tap-to-focus
- ISO Speed
- Shutter Speed (Exposure)
- Exposure Value
- White Balance
- **Configure manual camera controls** individually, allowing the user to see the effect the controls would have on the preview (where applicable).
- **Handle rotation events** for both, the device moving in space and the page orientation changing on the screen. Also apply any necessary corrections to the preview stream rotation and user interactions with the CaptureElement.
- **Handle MediaCapture Failed event** to clean up the MediaCapture instance when an error occurs.

## Top-level UWP namespaces used
- `Windows.Devices.Enumeration.Panel.Back`
- `Windows.Devices.Enumeration.Panel.Unknown`
- `Windows.Devices.Enumeration.Panel.Front`
- `Windows.UI.ViewManagement.StatusBar`
- `Windows.UI.ViewManagement.StatusBar.GetForCurrentView`
- `Windows.Phone.UI.Input.HardwareButtons`

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: crashed
- uninstall: ok
- error: App window found (hwnd=788582) but PrintWindow returned null after retry - app likely crashed during startup.

---

## MainPage (static analysis)

This sample is a single-page app (no scenario list). The MainPage covers the entire functionality.

### UI elements
- **CaptureElement**  - name="PreviewControl"; events: Tapped=PreviewControl_Tapped
- **Canvas**  - name="FocusCanvas"
- **Button**  - name="PhotoButton"; events: Click=PhotoButton_Click
- **Button**  - name="VideoButton"; events: Click=VideoButton_Click
- **Button**  - name="FlashButton"; content="Flash"; events: Click=ManualControlButton_Click
- **Button**  - name="ZoomButton"; content="Zoom"; events: Click=ManualControlButton_Click
- **Button**  - name="FocusButton"; content="Focus"; events: Click=ManualControlButton_Click
- **Button**  - name="WbButton"; content="WB"; events: Click=ManualControlButton_Click
- **Button**  - name="IsoButton"; content="ISO"; events: Click=ManualControlButton_Click
- **Button**  - name="ShutterButton"; content="Shutter"; events: Click=ManualControlButton_Click
- **Button**  - name="EvButton"; content="EV"; events: Click=ManualControlButton_Click
- **RadioButton**  - name="FlashOnRadioButton"; content="On"; events: Checked=FlashOnRadioButton_Checked
- **RadioButton**  - name="FlashAutoRadioButton"; content="Auto"; events: Checked=FlashAutoRadioButton_Checked
- **RadioButton**  - name="FlashOffRadioButton"; content="Off"; events: Checked=FlashOffRadioButton_Checked
- **CheckBox**  - name="RedEyeFlashCheckBox"; content="Red Eye"; events: Unchecked=RedEyeFlashCheckBox_CheckedChanged, Checked=RedEyeFlashCheckBox_CheckedChanged
- **CheckBox**  - name="TorchCheckBox"; content="Video Light"; events: Unchecked=TorchCheckBox_CheckedChanged, Checked=TorchCheckBox_CheckedChanged
- **Slider**  - name="ZoomSlider"; events: ValueChanged=ZoomSlider_ValueChanged
- **TextBlock**  - text="{Binding ElementName=ZoomSlider,Path=Value,Converter={StaticResource RoundingConverter}}"
- **Slider**  - name="FocusSlider"; events: ValueChanged=FocusSlider_ValueChanged
- **TextBlock**  - text="{Binding ElementName=FocusSlider,Path=Value,FallbackValue='0'}"
- **RadioButton**  - name="ManualFocusRadioButton"; content="Manual"; events: Checked=ManualFocusRadioButton_Checked
- **RadioButton**  - name="CafFocusRadioButton"; content="CAF"; events: Checked=CafFocusRadioButton_Checked
- **RadioButton**  - name="TapFocusRadioButton"; content="Tap"; events: Checked=TapFocusRadioButton_Checked
- **CheckBox**  - name="FocusLightCheckBox"; content="Assist Light"; events: Unchecked=FocusLightCheckBox_CheckedChanged, Checked=FocusLightCheckBox_CheckedChanged
- **Slider**  - name="WbSlider"; events: ValueChanged=WbSlider_ValueChanged
- **TextBlock**  - name="WbTextBox"; text="{Binding ElementName=WbSlider,Path=Value}"
- **ComboBox**  - name="WbComboBox"; events: SelectionChanged=WbComboBox_SelectionChanged
- **Slider**  - name="IsoSlider"; events: ValueChanged=IsoSlider_ValueChanged
- **TextBlock**  - text="{Binding ElementName=IsoSlider,Path=Value}"
- **CheckBox**  - name="IsoAutoCheckBox"; content="Auto"; events: Unchecked=IsoAutoCheckBox_CheckedChanged, Checked=IsoAutoCheckBox_CheckedChanged
- **Slider**  - name="ShutterSlider"; events: ValueChanged=ShutterSlider_ValueChanged
- **TextBlock**  - name="ShutterTextBlock"; text="0"
- **CheckBox**  - name="ShutterAutoCheckBox"; content="Auto"; events: Unchecked=ShutterCheckBox_CheckedChanged, Checked=ShutterCheckBox_CheckedChanged
- **Slider**  - name="EvSlider"; events: ValueChanged=EvSlider_ValueChanged
- **TextBlock**  - name="EvTextBlock"

### Code behavior
- **`MainPage`**
    - API refs: `NavigationCacheMode.Disabled`, `Application.Current`
- **`Application_Suspending`**
    - API refs: `Frame.CurrentSourcePageType`, `SuspendingOperation.GetDeferral`
- **`Application_Resuming`**
    - API refs: `Frame.CurrentSourcePageType`
- **`SystemMediaControls_PropertyChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `SystemMediaTransportControlsProperty.SoundLevel`, `Frame.CurrentSourcePageType`, `SoundLevel.Muted`
- **`OrientationSensor_OrientationChanged`**
    - API refs: `SimpleOrientation.Faceup`, `SimpleOrientation.Facedown`, `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`DisplayInformation_OrientationChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`PreviewControl_Tapped`**
    - instantiates: `Size`
    - API refs: `TapFocusRadioButton.IsChecked`, `VideoDeviceController.FocusControl`, `MediaCaptureFocusState.Searching`, `Math.Min`, `Window.Current`, `Bounds.Width`, `Bounds.Height`
- **`PreviewControl_ManipulationDelta`**
    - API refs: `ZoomSlider.Value`, `Delta.Scale`
- **`MediaCapture_RecordLimitationExceeded`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`MediaCapture_Failed`**
    - API refs: `Debug.WriteLine`, `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`InitializeCameraAsync`**
    - namespaces: `Windows.Devices.Enumeration.Panel.Back`, `Windows.Devices.Enumeration.Panel.Unknown`, `Windows.Devices.Enumeration.Panel.Front`
    - instantiates: `MediaCapture`
    - API refs: `Debug.WriteLine`, `Windows.Devices`, `Enumeration.Panel`, `EnclosureLocation.Panel`
- **`StartPreviewAsync`**
    - API refs: `PreviewControl.Source`, `PreviewControl.FlowDirection`, `FlowDirection.RightToLeft`, `FlowDirection.LeftToRight`, `FocusCanvas.FlowDirection`
- **`SetPreviewRotationAsync`**
    - API refs: `VideoDeviceController.GetMediaStreamProperties`, `MediaStreamType.VideoPreview`, `Properties.Add`
- **`StopPreviewAsync`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `PreviewControl.Source`
- **`TakePhotoAsync`**
    - instantiates: `InMemoryRandomAccessStream`
    - API refs: `VideoButton.IsEnabled`, `MediaCaptureSettings.ConcurrentRecordAndPhotoSupported`, `VideoButton.Opacity`, `Debug.WriteLine`, `ImageEncodingProperties.CreateJpeg`, `CreationCollisionOption.GenerateUniqueName`
- **`StartRecordingAsync`**
    - API refs: `CreationCollisionOption.GenerateUniqueName`, `MediaEncodingProfile.CreateMp4`, `VideoEncodingQuality.Auto`, `Video.Properties`, `PropertyValue.CreateInt32`, `Debug.WriteLine`
- **`StopRecordingAsync`**
    - API refs: `Debug.WriteLine`
- **`CleanupCameraAsync`**
    - API refs: `Debug.WriteLine`, `MediaCapture.Dispose`
- **`SetupUiAsync`**
    - namespaces: `Windows.UI.ViewManagement.StatusBar`, `Windows.UI.ViewManagement.StatusBar.GetForCurrentView`
    - API refs: `ApiInformation.IsTypePresent`, `Windows.UI`, `ViewManagement.StatusBar`, `StorageLibrary.GetLibraryAsync`, `KnownLibraryId.Pictures`, `ApplicationData.Current`
- **`CleanupUiAsync`**
    - namespaces: `Windows.UI.ViewManagement.StatusBar`, `Windows.UI.ViewManagement.StatusBar.GetForCurrentView`
    - API refs: `ApiInformation.IsTypePresent`, `Windows.UI`, `ViewManagement.StatusBar`
- **`UpdateCaptureControls`**
    - API refs: `PhotoButton.IsEnabled`, `VideoButton.IsEnabled`, `CameraControlsGrid.Visibility`, `Visibility.Visible`, `Visibility.Collapsed`, `StartRecordingIcon.Visibility`, `StopRecordingIcon.Visibility`, `MediaCaptureSettings.ConcurrentRecordAndPhotoSupported`, `PhotoButton.Opacity`
- **`RegisterEventHandlers`**
    - namespaces: `Windows.Phone.UI.Input.HardwareButtons`
    - API refs: `ApiInformation.IsTypePresent`, `Windows.Phone`, `UI.Input`, `HardwareButtons.CameraPressed`
- **`UnregisterEventHandlers`**
    - namespaces: `Windows.Phone.UI.Input.HardwareButtons`
    - API refs: `ApiInformation.IsTypePresent`, `Windows.Phone`, `UI.Input`, `HardwareButtons.CameraPressed`
- **`FindCameraDeviceByPanelAsync`**
    - API refs: `DeviceInformation.FindAllAsync`, `DeviceClass.VideoCapture`, `EnclosureLocation.Panel`
- **`ReencodeAndSavePhotoAsync`**
    - instantiates: `BitmapTypedValue`
    - API refs: `BitmapDecoder.CreateAsync`, `FileAccessMode.ReadWrite`, `BitmapEncoder.CreateForTranscodingAsync`, `System.Photo`, `PropertyType.UInt16`, `BitmapProperties.SetPropertiesAsync`
- **`GetPreviewStreamRectInControl`**
    - instantiates: `Rect`
    - API refs: `DisplayOrientations.Portrait`, `DisplayOrientations.PortraitFlipped`
- **`GetCameraOrientation`**
    - API refs: `SimpleOrientation.NotRotated`, `DisplayOrientations.Portrait`, `SimpleOrientation.Rotated90DegreesCounterclockwise`, `SimpleOrientation.Rotated180DegreesCounterclockwise`, `SimpleOrientation.Rotated270DegreesCounterclockwise`
- **`ConvertDeviceOrientationToDegrees`**
    - API refs: `SimpleOrientation.Rotated90DegreesCounterclockwise`, `SimpleOrientation.Rotated180DegreesCounterclockwise`, `SimpleOrientation.Rotated270DegreesCounterclockwise`, `SimpleOrientation.NotRotated`
- **`ConvertDisplayOrientationToDegrees`**
    - API refs: `DisplayOrientations.Portrait`, `DisplayOrientations.LandscapeFlipped`, `DisplayOrientations.PortraitFlipped`, `DisplayOrientations.Landscape`
- **`ConvertOrientationToPhotoOrientation`**
    - API refs: `SimpleOrientation.Rotated90DegreesCounterclockwise`, `PhotoOrientation.Rotate90`, `SimpleOrientation.Rotated180DegreesCounterclockwise`, `PhotoOrientation.Rotate180`, `SimpleOrientation.Rotated270DegreesCounterclockwise`, `PhotoOrientation.Rotate270`, `SimpleOrientation.NotRotated`, `PhotoOrientation.Normal`


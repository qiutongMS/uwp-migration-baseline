# CameraStarterKit (C#)

> **Source**: `Samples\CameraStarterKit\cs\`  
> **AUMID**: `Microsoft.SDKSamples.CameraStarterKit.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.CameraStarterKit.CS_8wekyb3d8bbwe`  

## Sample purpose
An end-to-end sample camera application.

## Scenarios demonstrated (from README)
- **Manage the MediaCapture object** throughout the lifecycle of the app and through navigation events.
- **Acquire a camera located on a specific side of the device**. In this case, the sample attempts to get the rear camera.
- **Start and stop the preview** to a UI element, including mirroring for front-facing cameras.
- **Take a picture** to a file, and disable the video capture button if the app is running on a device that doesn't support concurrent capturing of photos and video.
- **Record a video** to a file, and disable the photo capture button if the app is running on a device that doesn't support concurrent capturing of photos and video.
- **Handle rotation events** for both, the device moving in space and the page orientation changing on the screen. Also apply any necessary corrections to the preview stream rotation and to captured photos and videos.
- **Handle MediaCapture RecordLimitationExceeded and Failed events** to be notified that video recording needs to be stopped due to a video being too long, or clean up the MediaCapture instance when an error occurs.
- **Handle cameras mounted at an angle in the device enclosure** by inspecting the EnclosureLocation.RotationAngleInDegreesClockwise and adjusting the UI to take it into account.

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
- error: App window found (hwnd=853996) but PrintWindow returned null after retry - app likely crashed during startup.

---

## MainPage (static analysis)

This sample is a single-page app (no scenario list). The MainPage covers the entire functionality.

### UI elements
- **CaptureElement**  - name="PreviewControl"
- **Button**  - name="PhotoButton"; events: Click=PhotoButton_Click
- **Button**  - name="VideoButton"; events: Click=VideoButton_Click

### Code behavior
- **`MainPage`**
    - API refs: `NavigationCacheMode.Disabled`
- **`Application_Suspending`**
    - API refs: `SuspendingOperation.GetDeferral`, `Dispatcher.RunAsync`, `CoreDispatcherPriority.High`
- **`Application_Resuming`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.High`
- **`OnNavigatedTo`**
    - API refs: `Application.Current`, `Window.Current`
- **`OnNavigatingFrom`**
    - API refs: `Application.Current`, `Window.Current`
- **`SystemMediaControls_PropertyChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `SystemMediaTransportControlsProperty.SoundLevel`, `Frame.CurrentSourcePageType`, `SoundLevel.Muted`
- **`MediaCapture_RecordLimitationExceeded`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`MediaCapture_Failed`**
    - API refs: `Debug.WriteLine`, `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`InitializeCameraAsync`**
    - namespaces: `Windows.Devices.Enumeration.Panel.Back`, `Windows.Devices.Enumeration.Panel.Unknown`, `Windows.Devices.Enumeration.Panel.Front`
    - instantiates: `MediaCapture`, `CameraRotationHelper`
    - API refs: `Debug.WriteLine`, `Windows.Devices`, `Enumeration.Panel`, `EnclosureLocation.Panel`
- **`RotationHelper_OrientationChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`UpdateButtonOrientation`**
    - API refs: `CameraRotationHelper.ConvertSimpleOrientationToClockwiseDegrees`, `PhotoButton.RenderTransform`, `VideoButton.RenderTransform`
- **`StartPreviewAsync`**
    - API refs: `PreviewControl.Source`, `PreviewControl.FlowDirection`, `FlowDirection.RightToLeft`, `FlowDirection.LeftToRight`
- **`SetPreviewRotationAsync`**
    - API refs: `VideoDeviceController.GetMediaStreamProperties`, `MediaStreamType.VideoPreview`, `Properties.Add`, `CameraRotationHelper.ConvertSimpleOrientationToClockwiseDegrees`
- **`StopPreviewAsync`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `PreviewControl.Source`
- **`TakePhotoAsync`**
    - instantiates: `InMemoryRandomAccessStream`
    - API refs: `VideoButton.IsEnabled`, `MediaCaptureSettings.ConcurrentRecordAndPhotoSupported`, `VideoButton.Opacity`, `Debug.WriteLine`, `ImageEncodingProperties.CreateJpeg`, `CreationCollisionOption.GenerateUniqueName`, `CameraRotationHelper.ConvertSimpleOrientationToPhotoOrientation`
- **`StartRecordingAsync`**
    - API refs: `CreationCollisionOption.GenerateUniqueName`, `MediaEncodingProfile.CreateMp4`, `VideoEncodingQuality.Auto`, `CameraRotationHelper.ConvertSimpleOrientationToClockwiseDegrees`, `Video.Properties`, `PropertyValue.CreateInt32`, `Debug.WriteLine`
- **`StopRecordingAsync`**
    - API refs: `Debug.WriteLine`
- **`CleanupCameraAsync`**
    - API refs: `Debug.WriteLine`, `MediaCapture.Dispose`
- **`SetUpBasedOnStateAsync`**
    - API refs: `Window.Current`
- **`SetupUiAsync`**
    - namespaces: `Windows.UI.ViewManagement.StatusBar`, `Windows.UI.ViewManagement.StatusBar.GetForCurrentView`
    - API refs: `DisplayInformation.AutoRotationPreferences`, `DisplayOrientations.Landscape`, `ApiInformation.IsTypePresent`, `Windows.UI`, `ViewManagement.StatusBar`, `StorageLibrary.GetLibraryAsync`, `KnownLibraryId.Pictures`, `ApplicationData.Current`
- **`CleanupUiAsync`**
    - namespaces: `Windows.UI.ViewManagement.StatusBar`, `Windows.UI.ViewManagement.StatusBar.GetForCurrentView`
    - API refs: `ApiInformation.IsTypePresent`, `Windows.UI`, `ViewManagement.StatusBar`, `DisplayInformation.AutoRotationPreferences`, `DisplayOrientations.None`
- **`UpdateCaptureControls`**
    - API refs: `PhotoButton.IsEnabled`, `VideoButton.IsEnabled`, `StartRecordingIcon.Visibility`, `Visibility.Collapsed`, `Visibility.Visible`, `StopRecordingIcon.Visibility`, `MediaCaptureSettings.ConcurrentRecordAndPhotoSupported`, `PhotoButton.Opacity`
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


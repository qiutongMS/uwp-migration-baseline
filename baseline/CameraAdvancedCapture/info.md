# CameraAdvancedCapture (C#)

> **Source**: `Samples\CameraAdvancedCapture\cs\`  
> **AUMID**: `Microsoft.SDKSamples.CameraAdvancedCapture.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.CameraAdvancedCapture.CS_8wekyb3d8bbwe`  

## Sample purpose
An end-to-end sample camera app supporting orientation, HDR, low light, and other features.

## Scenarios demonstrated (from README)
- **Manage the MediaCapture object** throughout the lifecycle of the app and through navigation events.
- **Acquire a camera located on a specific side of the device**. In this case, the sample attempts to get the rear camera.
- **Start and stop the preview** to a UI element, including mirroring for front-facing cameras.
- **Take a regular picture** to a file, taking into account the orientation of the device.
- **Manage the Scene Analysis effect**, including creation, activation/deactivation of the HighDynamicRangeAnalyzer, registering for the SceneAnalyzed event, and cleanup. The effect is used throughout the lifetime of the app, and the analysis result is shown to the user.
- **Configure the AdvancedPhotoControl** to capture images, create an instance of the AdvancedCapture, and register for the AllAllPhotosCaptured event, which signals that the camera is ready to capture again, and for the OptionalReferencePhotoCaptured, which will be raised only on devices that support delivering a reference image alongside the processed image, and carries the reference image in the payload.
- **Take an Advanced Capture picture** to a file, taking into account the orientation of the device. This can be an HDR, a Low Light, or a standard picture, depending on the capabilities of the device.
- **Handle rotation events** for both, the device moving in space and the page orientation changing on the screen. Also apply any necessary corrections to the preview stream rotation.
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
- error: App window found (hwnd=592086) but PrintWindow returned null after retry - app likely crashed during startup.

---

## MainPage (static analysis)

This sample is a single-page app (no scenario list). The MainPage covers the entire functionality.

### UI elements
- **CaptureElement**  - name="PreviewControl"
- **Button**  - name="CycleModeButton"
- **TextBlock**  - name="ModeTextBlock"; text="Standard"
- **Button**  - name="PhotoButton"; events: Click=PhotoButton_Click
- **TextBlock**  - text="HDR Analyzer:"
- **ProgressBar**  - name="HdrImpactBar"
- **TextBlock**  - name="SceneTypeTextBlock"

### Code behavior
- **`MainPage`**
    - API refs: `NavigationCacheMode.Disabled`, `Application.Current`, `HdrImpactBar.Maximum`
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
- **`SceneAnalysisEffect_SceneAnalyzed`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `HdrImpactBar.Value`, `Math.Min`, `ResultFrame.HighDynamicRange`, `SceneTypeTextBlock.Text`, `ResultFrame.AnalysisRecommendation`
    - updates UI: `SceneTypeTextBlock.Text`
- **`AdvancedCapture_OptionalReferencePhotoCaptured`**
    - API refs: `CaptureFileName.Replace`, `CreationCollisionOption.GenerateUniqueName`, `Debug.WriteLine`
- **`AdvancedCapture_AllPhotosCaptured`**
    - API refs: `Debug.WriteLine`
- **`MediaCapture_Failed`**
    - API refs: `Debug.WriteLine`, `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`InitializeCameraAsync`**
    - namespaces: `Windows.Devices.Enumeration.Panel.Back`, `Windows.Devices.Enumeration.Panel.Unknown`, `Windows.Devices.Enumeration.Panel.Front`
    - instantiates: `MediaCapture`
    - API refs: `Debug.WriteLine`, `Windows.Devices`, `Enumeration.Panel`, `EnclosureLocation.Panel`
- **`StartPreviewAsync`**
    - API refs: `PreviewControl.Source`, `PreviewControl.FlowDirection`, `FlowDirection.RightToLeft`, `FlowDirection.LeftToRight`
- **`SetPreviewRotationAsync`**
    - API refs: `VideoDeviceController.GetMediaStreamProperties`, `MediaStreamType.VideoPreview`
- **`StopPreviewAsync`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `PreviewControl.Source`
- **`CreateSceneAnalysisEffectAsync`**
    - instantiates: `SceneAnalysisEffectDefinition`
    - API refs: `MediaStreamType.VideoPreview`, `Debug.WriteLine`, `HighDynamicRangeAnalyzer.Enabled`
- **`CleanSceneAnalysisEffectAsync`**
    - API refs: `HighDynamicRangeAnalyzer.Enabled`, `Debug.WriteLine`
- **`EnableAdvancedCaptureAsync`**
    - API refs: `ImageEncodingProperties.CreateJpeg`, `Debug.WriteLine`
- **`CycleAdvancedCaptureMode`**
    - API refs: `VideoDeviceController.AdvancedPhotoControl`, `SupportedModes.Count`, `ModeTextBlock.Text`, `Mode.ToString`
    - updates UI: `ModeTextBlock.Text`
- **`DisableAdvancedCaptureAsync`**
    - API refs: `Debug.WriteLine`
- **`TakeAdvancedCapturePhotoAsync`**
    - API refs: `PhotoButton.IsEnabled`, `CycleModeButton.IsEnabled`, `Debug.WriteLine`, `String.Format`, `DateTime.Now`, `CreationCollisionOption.GenerateUniqueName`
- **`CleanupCameraAsync`**
    - API refs: `Debug.WriteLine`, `MediaCapture.Dispose`
- **`SetupUiAsync`**
    - namespaces: `Windows.UI.ViewManagement.StatusBar`, `Windows.UI.ViewManagement.StatusBar.GetForCurrentView`
    - API refs: `DisplayInformation.AutoRotationPreferences`, `DisplayOrientations.Landscape`, `ApiInformation.IsTypePresent`, `Windows.UI`, `ViewManagement.StatusBar`, `StorageLibrary.GetLibraryAsync`, `KnownLibraryId.Pictures`, `ApplicationData.Current`
- **`CleanupUiAsync`**
    - namespaces: `Windows.UI.ViewManagement.StatusBar`, `Windows.UI.ViewManagement.StatusBar.GetForCurrentView`
    - API refs: `ApiInformation.IsTypePresent`, `Windows.UI`, `ViewManagement.StatusBar`, `DisplayInformation.AutoRotationPreferences`, `DisplayOrientations.None`
- **`UpdateUi`**
    - API refs: `PhotoButton.IsEnabled`, `CycleModeButton.IsEnabled`
- **`RegisterEventHandlers`**
    - namespaces: `Windows.Phone.UI.Input.HardwareButtons`
    - API refs: `ApiInformation.IsTypePresent`, `Windows.Phone`, `UI.Input`, `HardwareButtons.CameraPressed`, `CycleModeButton.Click`
- **`UnregisterEventHandlers`**
    - namespaces: `Windows.Phone.UI.Input.HardwareButtons`
    - API refs: `ApiInformation.IsTypePresent`, `Windows.Phone`, `UI.Input`, `HardwareButtons.CameraPressed`
- **`FindCameraDeviceByPanelAsync`**
    - API refs: `DeviceInformation.FindAllAsync`, `DeviceClass.VideoCapture`, `EnclosureLocation.Panel`
- **`ReencodeAndSavePhotoAsync`**
    - instantiates: `BitmapTypedValue`
    - API refs: `BitmapDecoder.CreateAsync`, `FileAccessMode.ReadWrite`, `BitmapEncoder.CreateForTranscodingAsync`, `System.Photo`, `PropertyType.UInt16`, `BitmapProperties.SetPropertiesAsync`
- **`GetCameraOrientation`**
    - API refs: `SimpleOrientation.NotRotated`, `DisplayOrientations.Portrait`, `SimpleOrientation.Rotated90DegreesCounterclockwise`, `SimpleOrientation.Rotated180DegreesCounterclockwise`, `SimpleOrientation.Rotated270DegreesCounterclockwise`
- **`ConvertDeviceOrientationToDegrees`**
    - API refs: `SimpleOrientation.Rotated90DegreesCounterclockwise`, `SimpleOrientation.Rotated180DegreesCounterclockwise`, `SimpleOrientation.Rotated270DegreesCounterclockwise`, `SimpleOrientation.NotRotated`


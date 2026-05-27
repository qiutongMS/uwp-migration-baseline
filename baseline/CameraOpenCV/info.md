# CameraOpenCV (C#)

> **Source**: `Samples\CameraOpenCV\cs\`  
> **Feature**: CameraOpenCV C# Sample  
> **AUMID**: `Microsoft.SDKSamples.CameraOpenCV.CS_8wekyb3d8bbwe!CameraOpenCV.App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.CameraOpenCV.CS_8wekyb3d8bbwe`  

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: crashed
- uninstall: ok
- error: App window found (hwnd=5245388) but PrintWindow returned null after retry - app likely crashed during startup.

---

## Scenario 1 - Example Operations

**Description**: Shows the output of various OpenCV operations

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Shows the output of various OpenCV operations"
- **TextBlock**  - name="CurrentOperationTextBlock"; text="Current: Blur"
- **ComboBox**  - name="OperationComboBox"; events: SelectionChanged=OperationComboBox_SelectionChanged
- **TextBlock**  - text="Preview"
- **Image**  - name="PreviewImage"
- **TextBlock**  - text="Output of Operation"
- **Image**  - name="OutputImage"
- **TextBlock**  - name="FPSMonitor"

### Code behavior
- **`DispatcherTimer`**
    - API refs: `TimeSpan.FromSeconds`
- **`InitializeMediaCaptureAsync`**
    - instantiates: `MediaCapture`, `MediaCaptureInitializationSettings`
    - API refs: `MediaCaptureSharingMode.ExclusiveControl`, `StreamingCaptureMode.Video`, `MediaCaptureMemoryPreference.Cpu`
- **`MediaCaptureInitializationSettings`**
    - API refs: `MediaCaptureSharingMode.ExclusiveControl`, `StreamingCaptureMode.Video`, `MediaCaptureMemoryPreference.Cpu`
- **`UpdateFPS`**
    - API refs: `Interlocked.Exchange`, `FPSMonitor.Text`
- **`OnNavigatedTo`**
    - instantiates: `BitmapSize`
    - API refs: `MainPage.Current`, `OperationComboBox.ItemsSource`, `Enum.GetValues`, `OperationComboBox.SelectedIndex`, `OperationType.Blur`, `MediaFrameSourceGroup.FindAllAsync`, `SourceInfos.FirstOrDefault`, `MediaFrameSourceKind.Color`, `Debug.WriteLine`, `SourceInfo.Id`, `MediaEncodingSubtypes.Bgra8`
- **`ColorFrameReader_FrameArrivedAsync`**
    - instantiates: `SoftwareBitmap`
    - API refs: `SoftwareBitmap.Convert`, `BitmapPixelFormat.Bgra8`, `BitmapAlphaMode.Premultiplied`, `OperationType.Blur`, `OperationType.HoughLines`, `OperationType.Contours`, `OperationType.Histogram`, `OperationType.MotionDetector`, `Interlocked.Increment`
- **`OperationComboBox_SelectionChanged`**
    - API refs: `OperationType.Blur`, `CurrentOperationTextBlock.Text`, `OperationType.Contours`, `OperationType.Histogram`, `OperationType.HoughLines`, `OperationType.MotionDetector`
    - updates UI: `CurrentOperationTextBlock.Text`


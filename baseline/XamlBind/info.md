# XamlBind (C#)

> **Source**: `Samples\XamlBind\cs\`  
> **AUMID**: `Microsoft.SDKSamples.xBindSampleCS.CS_8wekyb3d8bbwe!xBindSampleCS.App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.xBindSampleCS.CS_8wekyb3d8bbwe`  

## Sample purpose
Shows how to use x:Bind for data binding in XAML apps. x:Bind is a new compile time binding mechanism for XAML in windows 10,

## Scenarios demonstrated (from README)
- **Use x:Bind:** It includes a wide range of bindings that cover most usage patterns.
- **Use x:Bind in Data Templates:** Data Templates need to have the model type that will be used in the bindings specified on the template definition using the x:DataType attribute
- **Use x:Bind with x:Phase:** x:Phase can be used with x:Bind for list scenarios to enable incremental binding and rendering of data templates to improve the panning experience on low end devices.
- **Use x:Bind to bind event handlers:** x:Bind can be used in markup to specify event handlers as part of the data model, rather than requiring them to be in the code behind.
- Indexing dictionaries/maps with a string. (See Basic Bindings scenario.)
- Implicit bool-to-Visibility conversion. (See Other Bindings scenario.)
- C-style casts. (See Other Bindings scenario.)
- Function binding. (See Function Binding scenario.)

## Top-level UWP namespaces used
- `Windows.UI.Colors.Green`
- `Windows.UI.Colors.Red`
- `Windows.System.Launcher.LaunchUriAsync`

## Build / deploy / capture status
- build: skipped
- deploy: ok
- launch: ok
- capture: partial
- uninstall: ok
- error: Scenario iteration: You cannot call a method on a null-valued expression.

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - SDKTemplate.Scenario

### Screenshots
Initial state:

![initial](screenshots/01_SDKTemplate.Scenario__initial.png)

After click **Update Model Values**:

![after_Update Model Values](screenshots/01_SDKTemplate.Scenario__after_Update_Model_Values.png)

After click **Reset Model Values**:

![after_Reset Model Values](screenshots/01_SDKTemplate.Scenario__after_Reset_Model_Values.png)

---

## Scenario 2 - SDKTemplate.Scenario

### Screenshots
Initial state:

![initial](screenshots/02_SDKTemplate.Scenario__initial.png)

After click **Update Values**:

![after_Update Values](screenshots/02_SDKTemplate.Scenario__after_Update_Values.png)

After click **Reset Values**:

![after_Reset Values](screenshots/02_SDKTemplate.Scenario__after_Reset_Values.png)

After click **Undefer TextBlock**:

![after_Undefer TextBlock](screenshots/02_SDKTemplate.Scenario__after_Undefer_TextBlock.png)

---

## Scenario 3 - SDKTemplate.Scenario

### Screenshots
Initial state:

![initial](screenshots/03_SDKTemplate.Scenario__initial.png)

After click **xBindSampleModel.Employee**:

![after_xBindSampleModel.Employee](screenshots/03_SDKTemplate.Scenario__after_xBindSampleModel.Employee.png)

After click **Update Values**:

![after_Update Values](screenshots/03_SDKTemplate.Scenario__after_Update_Values.png)

After click **Reset Values**:

![after_Reset Values](screenshots/03_SDKTemplate.Scenario__after_Reset_Values.png)

---

## Scenario 4 - SDKTemplate.Scenario

### Screenshots
Initial state:

![initial](screenshots/04_SDKTemplate.Scenario__initial.png)

After click **Fire Collection Reset event**:

![after_Fire Collection Reset event](screenshots/04_SDKTemplate.Scenario__after_Fire_Collection_Reset_event.png)

After click **Change Folder...** (popup: Select Folder):

![popup_Change Folder...](screenshots/04_SDKTemplate.Scenario__popup_Change_Folder....png)

After click **Change Folder...**:

![after_Change Folder...](screenshots/04_SDKTemplate.Scenario__after_Change_Folder....png)

---

## MainPage (static analysis)

This sample is a single-page app (no scenario list). The MainPage covers the entire functionality.

### UI elements
- **Image**  - x:Name="WindowsLogo"
- **TextBlock**  - x:Name="Header"; text="Windows platform sample"
- **TextBlock**  - x:Name="SampleTitle"; text="{x:Bind SAMPLE_NAME}"
- **ListBox**  - x:Name="ScenarioControl"; events: SelectionChanged=ScenarioControl_SelectionChanged
- **TextBlock**  - text="{x:Bind Title}"
- **TextBlock**  - text="{x:Bind Description, TargetNullValue=''}"
- **TextBlock**  - x:Name="Copyright"; text="© Microsoft Corporation. All rights reserved."
- **HyperlinkButton**  - content="Trademarks"; events: Click=Footer_Click
- **TextBlock**  - text="|"
- **HyperlinkButton**  - x:Name="PrivacyLink"; content="Privacy"; events: Click=Footer_Click
- **TextBlock**  - x:Name="StatusLabel"; text="Status:"
- **TextBlock**  - x:Name="StatusBlock"
- **ToggleButton**  - events: Click=Button_Click

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `ScenarioControl.ItemsSource`, `Window.Current`, `Bounds.Width`, `ScenarioControl.SelectedIndex`
- **`ScenarioControl_SelectionChanged`**
    - API refs: `String.Empty`, `NotifyType.StatusMessage`, `ScenarioFrame.Navigate`, `Window.Current`, `Bounds.Width`, `Splitter.IsPaneOpen`, `StatusBorder.Visibility`, `Visibility.Collapsed`
- **`NotifyUser`**
    - namespaces: `Windows.UI.Colors.Green`, `Windows.UI.Colors.Red`
    - instantiates: `SolidColorBrush`
    - API refs: `NotifyType.StatusMessage`, `StatusBorder.Background`, `Windows.UI`, `Colors.Green`, `NotifyType.ErrorMessage`, `Colors.Red`, `StatusBlock.Text`, `StatusPanel.Visibility`, `String.Empty`, `Visibility.Visible`, `Visibility.Collapsed`
- **`HideStatus`**
    - API refs: `StatusPanel.Visibility`, `Visibility.Collapsed`
- **`Footer_Click`**
    - namespaces: `Windows.System.Launcher.LaunchUriAsync`
    - instantiates: `Uri`
    - API refs: `Windows.System`, `Launcher.LaunchUriAsync`, `Tag.ToString`
- **`Button_Click`**
    - API refs: `Splitter.IsPaneOpen`, `StatusBorder.Visibility`, `Visibility.Collapsed`


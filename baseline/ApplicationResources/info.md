# ApplicationResources (C#)

> **Source**: `Samples\ApplicationResources\cs\`  
> **AUMID**: `Microsoft.SDKSamples.ApplicationResources.CS_8wekyb3d8bbwe!ApplicationResources.App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.ApplicationResources.CS_8wekyb3d8bbwe`  

## Top-level UWP namespaces used
- `Windows.UI.Core.CoreDispatcherPriority.Normal`
- `Windows.System.Threading.ThreadPool.RunAsync`
- `Windows.ApplicationModel.Resources`
- `Windows.ApplicationModel.Resources.Core`

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: ok
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - scenario1

### Screenshots
Initial state:

![initial](screenshots/01_1_String_Resources_In_XAML__initial.png)

---

## Scenario 2 - scenario2

### Screenshots
Initial state:

![initial](screenshots/02_2_File_Resources_In_XAML__initial.png)

---

## Scenario 3 - scenario3

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `Scenario3TextBlock.Text`
    - updates UI: `Scenario3TextBlock.Text`
- **`Scenario3Button_Show_Click`**
    - API refs: `ResourceLoader.GetForCurrentView`, `Scenario3TextBlock.Text`
    - updates UI: `Scenario3TextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/03_3_String_Resources_In_Code__initial.png)

After click **Show Message**:

![after_Show Message](screenshots/03_3_String_Resources_In_Code__after_Show_Message.png)

---

## Scenario 4 - scenario4

### Screenshots
Initial state:

![initial](screenshots/04_4_Resources_in_the_AppX_manifest__initial.png)

---

## Scenario 5 - scenario5

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `Scenario5TextBlock.Text`
    - updates UI: `Scenario5TextBlock.Text`
- **`Scenario5Button_Show_Click`**
    - API refs: `ResourceLoader.GetForCurrentView`, `Scenario5TextBlock.Text`
    - updates UI: `Scenario5TextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/05_5_Additional_Resource_Files__initial.png)

After click **Show Message**:

![after_Show Message](screenshots/05_5_Additional_Resource_Files__after_Show_Message.png)

---

## Scenario 6 - scenario6

### Code behavior
- **`Scenario6Button_Show_Click`**
    - API refs: `ResourceLoader.GetForCurrentView`, `Scenario6TextBlock.Text`, `Scenario6TextBlock2.Text`, `AppResourceClassLibrary.LocalizedNamesLibrary`
    - updates UI: `Scenario6TextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/06_6_Class_Library_Resources__initial.png)

After click **Show Message**:

![after_Show Message](screenshots/06_6_Class_Library_Resources__after_Show_Message.png)

---

## Scenario 7 - scenario7

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `Scenario7TextBlock.Text`
    - updates UI: `Scenario7TextBlock.Text`
- **`Scenario7Button_Show_Click`**
    - namespaces: `Windows.UI.Core.CoreDispatcherPriority.Normal`
    - API refs: `Scenario7TextBlock.Text`, `ResourceManager.Current`, `MainResourceMap.GetValue`, `QualifierValues.MapChanged`, `Scenario7TextBlock.Dispatcher`, `Windows.UI`, `Core.CoreDispatcherPriority`
    - updates UI: `Scenario7TextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/07_7_Runtime_Changes_Events__initial.png)

After click **Show Message**:

![after_Show Message](screenshots/07_7_Runtime_Changes_Events__after_Show_Message.png)

---

## Scenario 8 - scenario8

### Code behavior
- **`ShowText`**
    - API refs: `ResourceContext.GetForCurrentView`, `ResourceManager.Current`, `MainResourceMap.GetSubtree`, `Scenario8MessageTextBlock.Text`
    - updates UI: `Scenario8MessageTextBlock.Text`
- **`LanguageOverrideCombo_SelectionChanged`**
    - API refs: `ApplicationLanguages.PrimaryLanguageOverride`
- **`AddItemForLanguageTag`**
    - instantiates: `Language`
    - API refs: `LanguageOverrideCombo.Items`, `ApplicationLanguages.PrimaryLanguageOverride`, `LanguageOverrideCombo.SelectedItem`
- **`PopulateComboBox`**
    - API refs: `LanguageOverrideCombo.Items`, `LanguageOverrideCombo.SelectedIndex`, `ApplicationLanguages.Languages`, `ApplicationLanguages.ManifestLanguages`, `LanguageOverrideCombo.SelectionChanged`
- **`UpdateCurrentAppLanguageMessage`**
    - API refs: `Scenario8AppLanguagesTextBlock.Text`
    - updates UI: `Scenario8AppLanguagesTextBlock.Text`
- **`GetAppLanguagesAsFormattedString`**
    - API refs: `String.Join`, `ApplicationLanguages.Languages`

### Screenshots
Initial state:

![initial](screenshots/08_8_Application_Languages__initial.png)

After click **Show Message**:

![after_Show Message](screenshots/08_8_Application_Languages__after_Show_Message.png)

---

## Scenario 9 - scenario9

### Code behavior
- **`OnNavigatedFrom`**
    - API refs: `ResourceContext.GetForCurrentView`
- **`Scenario9Button_Show_Click`**
    - instantiates: `List`
    - API refs: `ResourceContext.GetForCurrentView`, `Scenario9ComboBox.SelectedValue`, `ResourceManager.Current`, `MainResourceMap.GetSubtree`, `Scenario9TextBlock.Text`
    - updates UI: `Scenario9TextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/09_9_Override_Languages__initial.png)

After click **Show Message**:

![after_Show Message](screenshots/09_9_Override_Languages__after_Show_Message.png)

---

## Scenario 10 - scenario10

### Code behavior
- **`Scenario10Button_Show_Click`**
    - API refs: `ResourceContext.GetForCurrentView`, `Scenario10ComboBox_Language.SelectedValue`, `Scenario10ComboBox_Scale.SelectedValue`, `Scenario10ComboBox_Contrast.SelectedValue`, `Scenario10ComboBox_HomeRegion.SelectedValue`
- **`Scenario10_SearchMultipleResourceIds`**
    - API refs: `Scenario10TextBlock.Text`, `ResourceManager.Current`, `MainResourceMap.GetSubtree`
    - updates UI: `Scenario10TextBlock.Text`
- **`Scenario10_ShowCandidates`**
    - API refs: `IsMatch.ToString`, `IsDefault.ToString`, `Scenario10TextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/10_10_Multi-dimensional_fallback__initial.png)

After click **Show Message**:

![after_Show Message](screenshots/10_10_Multi-dimensional_fallback__after_Show_Message.png)

---

## Scenario 11 - scenario11

### Code behavior
- **`Scenario11Button_Show_Click`**
    - API refs: `ResourceLoader.GetForCurrentView`, `Scenario11TextBlock.Text`
    - updates UI: `Scenario11TextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/11_11_Working_with_webservices__initial.png)

After click **Get Url**:

![after_Get Url](screenshots/11_11_Working_with_webservices__after_Get_Url.png)

---

## Scenario 12 - scenario12

### Code behavior
- **`Scenario12Button_Show_Click`**
    - namespaces: `Windows.System.Threading.ThreadPool.RunAsync`
    - instantiates: `List`
    - API refs: `ResourceContext.GetForCurrentView`, `Windows.System`, `Threading.ThreadPool`, `ResourceManager.Current`, `MainResourceMap.GetSubtree`, `ResourceContext.GetForViewIndependentUse`, `ResourceContext.Reset`, `ViewDependentResourcesList.ItemsSource`, `ViewIndependentResourcesList.ItemsSource`

### Screenshots
Initial state:

![initial](screenshots/12_12_Retrieving_resources_in_non-UI_threads__initial.png)

After click **Show Results**:

![after_Show Results](screenshots/12_12_Retrieving_resources_in_non-UI_threads__after_Show_Results.png)

---

## Scenario 13 - scenario13

### Code behavior
- **`DXFLOptionCombo_SelectionChanged`**
    - namespaces: `Windows.ApplicationModel.Resources`, `Windows.ApplicationModel.Resources.Core`
    - instantiates: `Uri`
    - API refs: `ResourceMap.GetValue`, `ResourceContext.SetGlobalQualifierValue`, `SelectedValue.ToString`, `Windows.ApplicationModel`, `Resources.Core`, `StorageFile.GetFileFromApplicationUriAsync`, `FileIO.ReadTextAsync`, `ResultText.Text`

### Screenshots
Initial state:

![initial](screenshots/13_13_File_resources_in_code__initial.png)


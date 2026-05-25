#  (C#)

> **Source**: `Samples\\cs\`  
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


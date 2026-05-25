# RadialController (C#)

> **Source**: `Samples\RadialController\cs\`  
> **Feature**: RadialController C# Sample  
> **AUMID**: `Microsoft.SDKSamples.RadialController.CS_8wekyb3d8bbwe!RadialController.App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.RadialController.CS_8wekyb3d8bbwe`  

## Sample purpose
Creates custom menu items for a Surface Dial device, controls the haptic feedback, and configures the default system items.

## Scenarios demonstrated (from README)
- **Add, remove, and select custom items:** This sample demonstrates how to add, remove, and select custom items dynamically using system-provided icons,
- **Control haptic feedback:** This sample demonstrates how to enable and disable the haptic feedback for custom items.
- **Configure default system items:** This sample demonstrates how to add, remove, and select the default system items.
- **Suppress the menu:** Normally, the system displays a menu when the user presses the Surface Dial.

## Build / deploy / capture status
- build: skipped
- deploy: ok
- launch: ok
- capture: crashed
- uninstall: ok
- error: App window found (hwnd=9897932) but PrintWindow returned null after retry - app likely crashed during startup.

---

## Scenario 1 - Event And Menu Hookup

**Description**: Radial Controller Events Hookup to events and adding menu items using known and custom icons.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Radial Controller Events Hookup to events and adding menu items using known and custom icons."
- **Button**  - content="Add Item 0"; events: Click=AddItem
- **Button**  - content="Select Item 0"; events: Click=SelectItem
- **Button**  - content="Remove Item 0"; events: Click=RemoveItem
- **Slider**  - x:Name="slider0"
- **ToggleSwitch**  - x:Name="toggle0"
- **Button**  - content="Add Item 1"; events: Click=AddItem
- **Button**  - content="Select Item 1"; events: Click=SelectItem
- **Button**  - content="Remove Item 1"; events: Click=RemoveItem
- **Slider**  - x:Name="slider1"
- **ToggleSwitch**  - x:Name="toggle1"
- **Button**  - content="Add Item 2"; events: Click=AddItem
- **Button**  - content="Select Item 2"; events: Click=SelectItem
- **Button**  - content="Remove Item 2"; events: Click=RemoveItem
- **Slider**  - x:Name="slider2"
- **ToggleSwitch**  - x:Name="toggle2"
- **Button**  - content="Add Item 3"; events: Click=AddItem
- **Button**  - content="Select Item 3"; events: Click=SelectItem
- **Button**  - content="Remove Item 3"; events: Click=RemoveItem
- **Slider**  - x:Name="slider3"
- **ToggleSwitch**  - x:Name="toggle3"
- **TextBlock**  - text="❤"
- **Button**  - content="Add Item 4"; events: Click=AddItem
- **Button**  - content="Select Item 4"; events: Click=SelectItem
- **Button**  - content="Remove Item 4"; events: Click=RemoveItem
- **Slider**  - x:Name="slider4"
- **ToggleSwitch**  - x:Name="toggle4"
- **TextBlock**  - text=""
- **Button**  - content="Add Item 5"; events: Click=AddItem
- **Button**  - content="Select Item 5"; events: Click=SelectItem
- **Button**  - content="Remove Item 5"; events: Click=RemoveItem
- **Slider**  - x:Name="slider5"
- **ToggleSwitch**  - x:Name="toggle5"
- **Button**  - content="Get Selected Item"; events: Click=PrintSelectedItem
- **Button**  - content="Select Previous Item"; events: Click=SelectPreviouslySelectedItem
- **ToggleSwitch**  - x:Name="MenuSuppressionToggleSwitch"; events: Toggled=ToggleMenuSuppression
- **TextBlock**  - text="Log"
- **TextBlock**  - x:Name="log"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `MainPage.Current`
- **`OnNavigatedFrom`**
    - API refs: `Controller.Menu`, `Items.Clear`
- **`InitializeController`**
    - API refs: `RadialController.CreateForCurrentView`, `Controller.RotationResolutionInDegrees`, `Controller.RotationChanged`, `Controller.ButtonClicked`, `Controller.ScreenContactStarted`, `Controller.ScreenContactContinued`, `Controller.ScreenContactEnded`, `Controller.ControlAcquired`, `Controller.ControlLost`
- **`AddKnownIconItems`**
    - API refs: `RadialControllerMenuItem.CreateFromKnownIcon`, `RadialControllerMenuKnownIcon.InkColor`, `RadialControllerMenuKnownIcon.NextPreviousTrack`
- **`AddCustomIconItems`**
    - instantiates: `Uri`
    - API refs: `RadialControllerMenuItem.CreateFromIcon`, `RandomAccessStreamReference.CreateFromUri`
- **`AddFontGlyphItems`**
    - instantiates: `Uri`
    - API refs: `RadialControllerMenuItem.CreateFromFontGlyph`
- **`AddItem`**
    - API refs: `Controller.Menu`, `Items.Contains`, `Items.Add`
- **`RemoveItem`**
    - API refs: `Controller.Menu`, `Items.Contains`, `Items.Remove`
- **`SelectItem`**
    - API refs: `Controller.Menu`, `Items.Contains`
- **`SelectPreviouslySelectedItem`**
    - API refs: `Controller.Menu`
- **`GetRadialControllerMenuItemFromSender`**
    - API refs: `Convert.ToInt32`
- **`PrintSelectedItem`**
    - API refs: `Controller.Menu`
- **`ToggleMenuSuppression`**
    - API refs: `RadialControllerConfiguration.GetForCurrentView`, `MenuSuppressionToggleSwitch.IsOn`
- **`LogContactInfo`**
    - API refs: `Bounds.ToString`, `Position.ToString`

---

## Scenario 2 - Modifying System Default Menu

**Description**: Radial Controller Configuration for manipulating system default Radial Controller Menu Items.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Radial Controller Configuration for manipulating system default Radial Controller Menu Items."
- **Button**  - content="Add Item 1"; events: Click=AddCustomItem
- **Button**  - content="Select Item 1"; events: Click=SelectCustomItem
- **Button**  - content="Remove Item 1"; events: Click=RemoveCustomItem
- **Slider**  - x:Name="slider1"
- **TextBlock**  - text="Configure"
- **Button**  - content="Select Volume"; events: Click=Select_Volume
- **Button**  - content="Select Previous Item"; events: Click=SelectPreviouslySelectedItem
- **Button**  - content="Add Default System Items"; events: Click=Reset_ToDefault
- **Button**  - content="Remove Default System Items"; events: Click=Remove_Defaults
- **Button**  - content="Set Default System Items to Volume and Scroll Only"; events: Click=ModifySystemDefaults
- **TextBlock**  - text="Log"
- **TextBlock**  - x:Name="log"

### Code behavior
- **`OnNavigatedFrom`**
    - API refs: `Menu.Items`
- **`Controller_RotationChanged`**
    - API refs: `Contact.Bounds`, `Contact.Position`
- **`ModifySystemDefaults`**
    - API refs: `RadialControllerConfiguration.GetForCurrentView`, `RadialControllerSystemMenuItemKind.Volume`, `RadialControllerSystemMenuItemKind.Scroll`
- **`Select_Volume`**
    - API refs: `RadialControllerConfiguration.GetForCurrentView`, `RadialControllerSystemMenuItemKind.Volume`
- **`SelectPreviouslySelectedItem`**
    - API refs: `Menu.TrySelectPreviouslySelectedMenuItem`
- **`PrintSelectedItem`**
    - API refs: `Menu.GetSelectedMenuItem`
- **`Reset_ToDefault`**
    - API refs: `RadialControllerConfiguration.GetForCurrentView`
- **`AddCustomItem`**
    - API refs: `Menu.Items`
- **`RemoveCustomItem`**
    - API refs: `Menu.Items`
- **`SelectCustomItem`**
    - API refs: `Menu.Items`, `Menu.SelectMenuItem`
- **`Remove_Defaults`**
    - API refs: `RadialControllerConfiguration.GetForCurrentView`


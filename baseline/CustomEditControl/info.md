# CustomEditControl (C#)

> **Source**: `Samples\CustomEditControl\cs\`  
> **Feature**: Custom text control C# Sample  
> **AUMID**: `Microsoft.SDKSamples.CustomEditControl.CS_8wekyb3d8bbwe!CustomEditControl.App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.CustomEditControl.CS_8wekyb3d8bbwe`  

## Sample purpose
Shows how to use the CoreTextEditContext class to create a rudimentary text control.

## Scenarios demonstrated (from README)
- Managing the text and current selection of a custom edit control.
- Rendering the text and current selection in the custom edit control.
- Manually setting focus to and removing focus from the control
- Setting the CoreTextEditContext.InputPaneDisplayPolicy to Manual
- Responding to system events that request information about the
- Responding to layout information requests so that the IME candidate window
- Changing the selection and/or moving the caret when the user presses
- Click or tap on the custom edit control to give it focus,
- Observe that the Input Pane appears (if applicable)
- Use the arrow keys to move the caret (shown as a globe).
- Hold the shift key when pressing the arrow keys to adjust
- Use the Backspace key to delete text.
- To demonstrate support for IME candidates:
- Install an IME by going to Settings, Time and Language,
- Set your input language to Chinese by using the language
- Put focus on the custom edit control and start typing.
- This sample does not properly handle surrogate pairs
- This sample does not support common keyboard shortcuts
- This sample does not show a context menu if the user right-clicks
- This sample does not support using the mouse or touch to

## Build / deploy / capture status
- build: skipped
- deploy: ok
- launch: ok
- capture: ok
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - Text input

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Text input"
- **TextBlock**  - text="When the custom text control has focus, it draws with a green border. The caret is represented by a globe. See the README for this sample for further instructions."

### Code behavior
- **`Page_PointerPressed`**
    - API refs: `EditControl.GetLayout`, `CurrentPoint.Position`, `EditControl.Focus`, `FocusState.Programmatic`
- **`OnNavigatingFrom`**
    - API refs: `CoreWindow.GetForCurrentThread`

### Screenshots
Initial state:

![initial](screenshots/01_1_Text_input__initial.png)


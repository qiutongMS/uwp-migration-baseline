# MIDI (C#)

> **Source**: `Samples\MIDI\cs\`  
> **Feature**: MIDI  

## Build / deploy / capture status
- build: ok
- deploy: failed
- launch: pending
- capture: pending
- uninstall: pending
- error: Add-AppxPackage failed: Deployment failed with HRESULT: 0x80073CF3, Package failed updates, dependency or conflict validation.

Windows cannot install package Microsoft.SDKSamples.MIDI.CS_1.0.0.0_x64__8wekyb3d8bbwe because this package depends on a framework that could not be found. Provide the framework "Microsoft.Midi.GmDls" published by "CN=Microsoft Corporation, O=Microsoft Corporation, L=Redmond, S=Washington, C=US", with neutral or x64 processor architecture and minimum version 1.0.0.0, along with this package to install.

NOTE: For additional information, look for [ActivityId] 924185f5-0230-0005-4a52-cf5904e4dc01 in the Event Log or use the command line Get-AppPackageLog -ActivityID 924185f5-0230-0005-4a52-cf5904e4dc01


---

## Scenario 1 - MIDI Device Enumeration

### UI elements
- **TextBlock**  - text="Description"
- **TextBlock**  - text="This scenario illustrates MIDI Device Enumeration. Connect a MIDI device to see it in the list."
- **TextBlock**  - x:Name="deviceAutoDetectToggleLabel"; text="AUTO-DETECT"
- **ToggleSwitch**  - x:Name="deviceAutoDetectToggle"; events: Toggled=DeviceAutoDetectToggle_Toggled
- **TextBlock**  - x:Name="listInputDevicesButtonLabel"; text="INPUT"
- **Button**  - x:Name="listInputDevicesButton"; content="List all input devices"; events: Click=listInputDevicesButton_Click
- **ListBox**  - x:Name="inputDevices"; events: SelectionChanged=inputDevices_SelectionChanged
- **ListBox**  - x:Name="inputDeviceProperties"
- **TextBlock**  - x:Name="listOutputDevicesButtonLabel"; text="OUTPUT"
- **Button**  - x:Name="listOutputDevicesButton"; content="List all output devices"; events: Click=listOutputDevicesButton_Click
- **ListBox**  - x:Name="outputDevices"; events: SelectionChanged=outputDevices_SelectionChanged
- **ListBox**  - x:Name="outputDeviceProperties"
- **TextBlock**  - x:Name="statusBlock"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `MainPage.Current`
- **`ClearAllDeviceValues`**
    - API refs: `Items.Clear`, `Items.Add`
- **`EnumerateMidiInputDevices`**
    - API refs: `Items.Clear`, `MidiInPort.GetDeviceSelector`, `DeviceInformation.FindAllAsync`, `Items.Add`, `NotifyType.ErrorMessage`, `NotifyType.StatusMessage`
- **`EnumerateMidiOutputDevices`**
    - API refs: `Items.Clear`, `MidiOutPort.GetDeviceSelector`, `DeviceInformation.FindAllAsync`, `Items.Add`, `NotifyType.ErrorMessage`, `NotifyType.StatusMessage`
- **`DisplayDeviceProperties`**
    - API refs: `Items.Clear`, `Items.Add`

---

## Scenario 2 - Receive MIDI Messages

### UI elements
- **TextBlock**  - text="Description"
- **TextBlock**  - text="This scenario reads MIDI input from a MIDI device. Device auto-detection is enabled. Messages from the selected device are displayed. Connect a MIDI device to use this scenario."
- **TextBlock**  - x:Name="inputDevicesLabel"; text="INPUT DEVICES"
- **ListBox**  - x:Name="inputDevices"; events: SelectionChanged=inputDevices_SelectionChanged
- **TextBlock**  - x:Name="inputDeviceMessagesLabel"; text="RECEIVED MESSAGES"
- **ListBox**  - x:Name="inputDeviceMessages"
- **TextBlock**  - x:Name="statusBlock"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `MainPage.Current`
- **`MidiInputDevice_MessageReceived`**
    - instantiates: `StringBuilder`, `InvalidOperationException`
    - API refs: `Timestamp.ToString`, `MidiMessageType.NoteOff`, `MidiMessageType.NoteOn`, `MidiMessageType.PolyphonicKeyPressure`, `MidiMessageType.ControlChange`, `MidiMessageType.ProgramChange`, `MidiMessageType.ChannelPressure`, `MidiMessageType.PitchBendChange`, `MidiMessageType.SystemExclusive`, `DataReader.FromBuffer`, `MidiMessageType.MidiTimeCode`, `MidiMessageType.SongPositionPointer`, `MidiMessageType.SongSelect`, `MidiMessageType.TuneRequest`, `MidiMessageType.TimingClock`, `MidiMessageType.Start`, `MidiMessageType.Continue`, `MidiMessageType.Stop`, `MidiMessageType.ActiveSensing`, `MidiMessageType.SystemReset`, `MidiMessageType.None`, `Dispatcher.RunAsync`, `CoreDispatcherPriority.High`, `Items.Add`, `Items.Count`, `NotifyType.StatusMessage`

---

## Scenario 3 - Send MIDI Messages

### UI elements
- **TextBlock**  - text="Description"
- **TextBlock**  - text="This scenario sends MIDI output to a MIDI device (external or the built-in synth). Device auto-detection is enabled. Select an output device to send MIDI messages to it."
- **TextBlock**  - x:Name="outputDevicesLabel"; text="OUTPUT DEVICES"
- **ListBox**  - x:Name="outputDevices"; events: SelectionChanged=outputDevices_SelectionChanged
- **TextBlock**  - x:Name="messageTypeLabel"; text="SEND MESSAGE"
- **ComboBox**  - x:Name="messageType"; events: SelectionChanged=messageType_SelectionChanged
- **ComboBox**  - x:Name="parameter1"; events: SelectionChanged=Parameter1_SelectionChanged
- **ComboBox**  - x:Name="parameter2"; events: SelectionChanged=Parameter2_SelectionChanged
- **ComboBox**  - x:Name="parameter3"; events: SelectionChanged=Parameter3_SelectionChanged
- **TextBlock**  - x:Name="rawBufferHeader"; text="Enter SysEx Message: "
- **TextBox**  - x:Name="sysExMessageContent"
- **Button**  - x:Name="resetButton"; content="Reset"; events: Click=resetButton_Click
- **Button**  - x:Name="sendButton"; content="Send"; events: Click=sendButton_Click
- **TextBlock**  - x:Name="statusBlock"

### Code behavior
- **`OnNavigatedTo`**
    - API refs: `MainPage.Current`
- **`PopulateMessageTypes`**
    - instantiates: `Dictionary`
    - API refs: `MidiMessageType.ActiveSensing`, `MidiMessageType.ChannelPressure`, `MidiMessageType.Continue`, `MidiMessageType.ControlChange`, `MidiMessageType.MidiTimeCode`, `MidiMessageType.NoteOff`, `MidiMessageType.NoteOn`, `MidiMessageType.PitchBendChange`, `MidiMessageType.PolyphonicKeyPressure`, `MidiMessageType.ProgramChange`, `MidiMessageType.SongPositionPointer`, `MidiMessageType.SongSelect`, `MidiMessageType.Start`, `MidiMessageType.Stop`, `MidiMessageType.SystemExclusive`, `MidiMessageType.SystemReset`, `MidiMessageType.TimingClock`, `MidiMessageType.TuneRequest`, `Items.Clear`, `Items.Add`
- **`ResetMessageTypeAndParameters`**
    - API refs: `MidiMessageType.None`, `Visibility.Collapsed`
- **`UpdateParameterList1`**
    - API refs: `MidiMessageType.NoteOff`, `MidiMessageType.NoteOn`, `MidiMessageType.PolyphonicKeyPressure`, `MidiMessageType.ControlChange`, `MidiMessageType.ProgramChange`, `MidiMessageType.ChannelPressure`, `MidiMessageType.PitchBendChange`, `MidiMessageType.MidiTimeCode`, `MidiMessageType.SongPositionPointer`, `MidiMessageType.SongSelect`, `MidiMessageType.SystemExclusive`, `Items.Clear`, `Visibility.Collapsed`, `NotifyType.StatusMessage`
- **`Parameter1_SelectionChanged`**
    - API refs: `MidiMessageType.SongPositionPointer`, `MidiMessageType.SongSelect`
- **`UpdateParameterList2`**
    - API refs: `Items.Clear`, `Visibility.Collapsed`, `MidiMessageType.NoteOff`, `MidiMessageType.NoteOn`, `MidiMessageType.PolyphonicKeyPressure`, `MidiMessageType.ControlChange`, `MidiMessageType.ProgramChange`, `MidiMessageType.ChannelPressure`, `MidiMessageType.PitchBendChange`, `MidiMessageType.MidiTimeCode`
- **`Parameter2_SelectionChanged`**
    - API refs: `MidiMessageType.ProgramChange`, `MidiMessageType.ChannelPressure`, `MidiMessageType.PitchBendChange`, `MidiMessageType.MidiTimeCode`
- **`UpdateParameterList3`**
    - API refs: `Items.Clear`, `Visibility.Collapsed`, `MidiMessageType.NoteOff`, `MidiMessageType.NoteOn`, `MidiMessageType.PolyphonicKeyPressure`, `MidiMessageType.ControlChange`
- **`Parameter3_SelectionChanged`**
    - API refs: `MidiMessageType.NoteOff`, `MidiMessageType.NoteOn`, `MidiMessageType.PolyphonicKeyPressure`, `MidiMessageType.ControlChange`
- **`PopulateParameterList`**
    - API refs: `Items.Clear`, `Items.Add`, `Visibility.Visible`


#  (C#)

> **Source**: `Samples\\cs\`  
> **Feature**: File access C# sample  
> **AUMID**: `Microsoft.SDKSamples.FileAccess.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.FileAccess.CS_8wekyb3d8bbwe`  

## Sample purpose
Shows basic file operations, how to retrieve file properties, and how to track a file or folder so that your app can access it again.

## Top-level UWP namespaces used
- `Windows.Storage.Streams.Buffer`

## Build / deploy / capture status
- build: skipped
- deploy: ok
- launch: ok
- capture: ok
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - Scenario1_Create

**Description**: Create a new file 'sample.dat' to exercise the scenarios in this sample. File will be created in the Pictures library.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Create a new file 'sample.dat' to exercise the scenarios in this sample. File will be created in the Pictures library."
- **Button**  - content="Create 'sample.dat'"; events: Click=CreateFileButton_Click

### Code behavior
- **`CreateFileButton_Click`**
    - API refs: `KnownFolders.GetFolderForUserAsync`, `KnownFolderId.PicturesLibrary`, `CreationCollisionOption.ReplaceExisting`, `NotifyType.StatusMessage`, `NotifyType.ErrorMessage`

### Screenshots
Initial state:

![initial](screenshots/01_1_Creating_a_file__initial.png)

After click **Create 'sample.dat'**:

![after_Create 'sample.dat'](screenshots/01_1_Creating_a_file__after_Create_'sample.dat'.png)

---

## Scenario 2 - Scenario2_GetParent

**Description**: 'sample.dat' was created in the Pictures library. The app has the Pictures library capability, and can therefore access the folder where the file was created. To retrieve the folder, click 'Get Parent'.

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Get Parent"; events: Click=GetParent_Click

### Code behavior
- **`GetParent_Click`**
    - instantiates: `StringBuilder`
    - API refs: `NotifyType.StatusMessage`

### Screenshots
Initial state:

![initial](screenshots/02_2_Getting_a_file's_parent_folder__initial.png)

After click **Get Parent**:

![after_Get Parent](screenshots/02_2_Getting_a_file's_parent_folder__after_Get_Parent.png)

---

## Scenario 3 - Scenario3_Text

**Description**: To write some text to 'sample.dat', type something in the textbox below and click 'Write'. To read the contents of 'sample.dat', click 'Read'.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="To write some text to 'sample.dat', type something in the textbox below and click 'Write'. To read the contents of 'sample.dat', click 'Read'."
- **TextBox**  - x:Name="InputTextBox"; text="ABC123"
- **Button**  - content="Write"; events: Click=WriteTextButton_Click
- **Button**  - content="Read"; events: Click=ReadTextButton_Click

### Code behavior
- **`WriteTextButton_Click`**
    - API refs: `InputTextBox.Text`, `FileIO.WriteTextAsync`, `NotifyType.StatusMessage`, `NotifyType.ErrorMessage`
- **`ReadTextButton_Click`**
    - API refs: `FileIO.ReadTextAsync`, `NotifyType.StatusMessage`, `MainPage.E_NO_UNICODE_TRANSLATION`, `NotifyType.ErrorMessage`

### Screenshots
Initial state:

![initial](screenshots/03_3_Writing_and_reading_text_in_a_file__initial.png)

After click **Write**:

![after_Write](screenshots/03_3_Writing_and_reading_text_in_a_file__after_Write.png)

After click **Read**:

![after_Read](screenshots/03_3_Writing_and_reading_text_in_a_file__after_Read.png)

---

## Scenario 4 - Scenario4_Bytes

**Description**: To write some set of bytes to 'sample.dat', type something in the textbox below and click 'Write'. To read a set of bytes with the contents of 'sample.dat', click 'Read'.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="To write some set of bytes to 'sample.dat', type something in the textbox below and click 'Write'. To read a set of bytes with the contents of 'sample.dat', click 'Read'."
- **TextBox**  - x:Name="InputTextBox"; text="ABC123"
- **Button**  - content="Write"; events: Click=WriteBytesButton_Click
- **Button**  - content="Read"; events: Click=ReadBytesButton_Click

### Code behavior
- **`WriteBytesButton_Click`**
    - API refs: `InputTextBox.Text`, `MainPage.GetBufferFromString`, `FileIO.WriteBufferAsync`, `String.Format`, `Environment.NewLine`, `NotifyType.StatusMessage`, `NotifyType.ErrorMessage`
- **`ReadBytesButton_Click`**
    - API refs: `FileIO.ReadBufferAsync`, `MainPage.GetStringFromBuffer`, `NotifyType.StatusMessage`, `MainPage.E_NO_UNICODE_TRANSLATION`, `NotifyType.ErrorMessage`

### Screenshots
Initial state:

![initial](screenshots/04_4_Writing_and_reading_bytes_in_a_file__initial.png)

After click **Write**:

![after_Write](screenshots/04_4_Writing_and_reading_bytes_in_a_file__after_Write.png)

After click **Read**:

![after_Read](screenshots/04_4_Writing_and_reading_bytes_in_a_file__after_Read.png)

---

## Scenario 5 - Scenario5_Stream

**Description**: To write some text to 'sample.dat' using a stream, type something in the textbox below and click 'Write'. To read the contents of 'sample.dat' using a stream, click 'Read'.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="To write some text to 'sample.dat' using a stream, type something in the textbox below and click 'Write'. To read the contents of 'sample.dat' using a stream, click 'Read'."
- **TextBox**  - x:Name="InputTextBox"; text="ABC123"
- **Button**  - content="Write"; events: Click=WriteToStreamButton_Click
- **Button**  - content="Read"; events: Click=ReadFromStreamButton_Click

### Code behavior
- **`WriteToStreamButton_Click`**
    - API refs: `InputTextBox.Text`, `MainPage.GetBufferFromString`, `Stream.WriteAsync`, `Stream.Size`, `NotifyType.StatusMessage`, `String.Format`, `NotifyType.ErrorMessage`
- **`ReadFromStreamButton_Click`**
    - namespaces: `Windows.Storage.Streams.Buffer`
    - instantiates: `Windows.Storage.Streams.Buffer`
    - API refs: `FileAccessMode.Read`, `UInt32.MaxValue`, `Windows.Storage`, `Streams.Buffer`, `InputStreamOptions.None`, `MainPage.GetStringFromBuffer`, `NotifyType.StatusMessage`, `NotifyType.ErrorMessage`, `MainPage.E_NO_UNICODE_TRANSLATION`

### Screenshots
Initial state:

![initial](screenshots/05_5_Writing_and_reading_using_a_stream__initial.png)

After click **Write**:

![after_Write](screenshots/05_5_Writing_and_reading_using_a_stream__after_Write.png)

After click **Read**:

![after_Read](screenshots/05_5_Writing_and_reading_using_a_stream__after_Read.png)

---

## Scenario 6 - Scenario6_Properties

**Description**: To retrieve and display file properties for 'sample.dat', click 'Show Properties'.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="To retrieve and display file properties for 'sample.dat', click 'Show Properties'."
- **Button**  - content="Show Properties"; events: Click=ShowPropertiesButton_Click

### Code behavior
- **`ShowPropertiesButton_Click`**
    - instantiates: `StringBuilder`
    - API refs: `Properties.RetrievePropertiesAsync`, `NotifyType.StatusMessage`, `NotifyType.ErrorMessage`

### Screenshots
Initial state:

![initial](screenshots/06_6_Displaying_file_properties__initial.png)

After click **Show Properties**:

![after_Show Properties](screenshots/06_6_Displaying_file_properties__after_Show_Properties.png)

---

## Scenario 7 - Scenario7_FutureAccess

**Description**: Persist access to a storage item for future use.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Persist access to a storage item for future use."
- **RadioButton**  - x:Name="MRURadioButton"; content="Most Recently Used"
- **CheckBox**  - x:Name="SystemMRUCheckBox"; content="Also add to system Most Recently Used"
- **RadioButton**  - x:Name="FALRadioButton"; content="Future Access List"
- **Button**  - content="Add to List"; events: Click=AddToListButton_Click
- **Button**  - content="Show List"; events: Click=ShowListButton_Click
- **Button**  - content="Open from List"; events: Click=OpenFromListButton_Click

### Code behavior
- **`AddToListButton_Click`**
    - API refs: `MRURadioButton.IsChecked`, `SystemMRUCheckBox.IsChecked`, `RecentStorageItemVisibility.AppAndSystem`, `RecentStorageItemVisibility.AppOnly`, `StorageApplicationPermissions.MostRecentlyUsedList`, `NotifyType.StatusMessage`, `StorageApplicationPermissions.FutureAccessList`, `NotifyType.ErrorMessage`
- **`ShowListButton_Click`**
    - instantiates: `StringBuilder`
    - API refs: `MRURadioButton.IsChecked`, `StorageApplicationPermissions.MostRecentlyUsedList`, `StorageApplicationPermissions.FutureAccessList`, `NotifyType.StatusMessage`, `NotifyType.ErrorMessage`
- **`OpenFromListButton_Click`**
    - API refs: `MRURadioButton.IsChecked`, `StorageApplicationPermissions.MostRecentlyUsedList`, `NotifyType.ErrorMessage`, `StorageApplicationPermissions.FutureAccessList`, `FileIO.ReadTextAsync`, `NotifyType.StatusMessage`

### Screenshots
Initial state:

![initial](screenshots/07_7_Persisting_access_to_a_storage_item_for_future_u__initial.png)

After click **Add to List**:

![after_Add to List](screenshots/07_7_Persisting_access_to_a_storage_item_for_future_u__after_Add_to_List.png)

After click **Show List**:

![after_Show List](screenshots/07_7_Persisting_access_to_a_storage_item_for_future_u__after_Show_List.png)

After click **Open from List**:

![after_Open from List](screenshots/07_7_Persisting_access_to_a_storage_item_for_future_u__after_Open_from_List.png)

---

## Scenario 8 - Scenario8_Copy

**Description**: To copy 'sample.dat' to the Pictures library, click 'Copy'.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="To copy 'sample.dat' to the Pictures library, click 'Copy'."
- **Button**  - content="Copy"; events: Click=CopyFileButton_Click

### Code behavior
- **`CopyFileButton_Click`**
    - API refs: `KnownFolders.GetFolderForUserAsync`, `KnownFolderId.PicturesLibrary`, `NameCollisionOption.ReplaceExisting`, `NotifyType.StatusMessage`, `NotifyType.ErrorMessage`

### Screenshots
Initial state:

![initial](screenshots/08_8_Copying_a_file__initial.png)

After click **Copy**:

![after_Copy](screenshots/08_8_Copying_a_file__after_Copy.png)

---

## Scenario 9 - Scenario9_Compare

**Description**: Click 'Compare Files' to pick a file and compare it with 'sample.dat'. For example, in a save scenario you could determine if the user is overwriting the same file or creating a new one.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Click 'Compare Files' to pick a file and compare it with 'sample.dat'. For example, in a save scenario you could determine if the user is overwriting the same file or creating a new one."
- **Button**  - content="Compare Files"; events: Click=CompareFilesButton_Click

### Code behavior
- **`CompareFilesButton_Click`**
    - instantiates: `FileOpenPicker`
    - API refs: `PickerLocationId.PicturesLibrary`, `FileTypeFilter.Add`, `NotifyType.StatusMessage`

### Screenshots
Initial state:

![initial](screenshots/09_9_Comparing_two_files_to_see_if_they_are_the_same___initial.png)

After click **Compare Files** (popup: Open):

![popup_Compare Files](screenshots/09_9_Comparing_two_files_to_see_if_they_are_the_same___popup_Compare_Files.png)

After click **Compare Files**:

![after_Compare Files](screenshots/09_9_Comparing_two_files_to_see_if_they_are_the_same___after_Compare_Files.png)

---

## Scenario 10 - Scenario10_Delete

**Description**: To delete 'sample.dat', click 'Delete'.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="To delete 'sample.dat', click 'Delete'."
- **Button**  - content="Delete"; events: Click=DeleteFileButton_Click

### Code behavior
- **`DeleteFileButton_Click`**
    - API refs: `NotifyType.StatusMessage`, `NotifyType.ErrorMessage`

### Screenshots
Initial state:

![initial](screenshots/10_10_Deleting_a_file__initial.png)

After click **&Help**:

![after_&Help](screenshots/10_10_Deleting_a_file__after_&Help.png)

After click **View Slider** (popup: View Slider Control):

![popup_View Slider](screenshots/10_10_Deleting_a_file__popup_View_Slider.png)

After click **View Slider**:

![after_View Slider](screenshots/10_10_Deleting_a_file__after_View_Slider.png)

After click **Organize**:

![after_Organize](screenshots/10_10_Deleting_a_file__after_Organize.png)

---

## Scenario 11 - Scenario11_TryGet

**Description**: To try to retrieve the file 'sample.dat', click 'Get File'. The TryGetItemAsync method does not throw an exception if it cannot get the file.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="To try to retrieve the file 'sample.dat', click 'Get File'. The TryGetItemAsync method does not throw an exception if it cannot get the file."
- **Button**  - content="Get File"; events: Click=GetFileButton_Click

### Code behavior
- **`GetFileButton_Click`**
    - API refs: `KnownFolders.GetFolderForUserAsync`, `KnownFolderId.PicturesLibrary`, `NotifyType.StatusMessage`

### Screenshots
Initial state:

![initial](screenshots/11_11_Attempting_to_get_a_file_with_no_error_on_failu__initial.png)

After click **&Help**:

![after_&Help](screenshots/11_11_Attempting_to_get_a_file_with_no_error_on_failu__after_&Help.png)

After click **View Slider** (popup: View Slider Control):

![popup_View Slider](screenshots/11_11_Attempting_to_get_a_file_with_no_error_on_failu__popup_View_Slider.png)

After click **View Slider**:

![after_View Slider](screenshots/11_11_Attempting_to_get_a_file_with_no_error_on_failu__after_View_Slider.png)

After click **Organize**:

![after_Organize](screenshots/11_11_Attempting_to_get_a_file_with_no_error_on_failu__after_Organize.png)


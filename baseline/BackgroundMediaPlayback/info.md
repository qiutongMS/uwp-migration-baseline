#  (C#)

> **Source**: `Samples\\cs\`  
> **Feature**: BackgroundMediaPlayback  
> **AUMID**: `Microsoft.SDKSamples.BackgroundMediaPlayback.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.BackgroundMediaPlayback.CS_8wekyb3d8bbwe`  

## Sample purpose
Shows how to create a playlist that can continue to play even when the app is no longer in the foreground.

## Build / deploy / capture status
- build: skipped
- deploy: ok
- launch: ok
- capture: failed
- uninstall: pending
- error: Could not find main window (looked for 'Background Media Playback C# Sample')

---

## Scenario 1 - Background Media Playback

**Description**: Demonstrates playback lists and background audio.

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="Demonstrates playback lists and background audio."
- **MediaPlayerElement**  - x:Name="mediaPlayerElement"
- **Button**  - x:Name="prevButton"; events: Click={x:Bind PlayerViewModel.SkipPrevious}
- **Button**  - x:Name="playButton"; events: Click={x:Bind PlayerViewModel.TogglePlayPause}
- **Button**  - x:Name="nextButton"; events: Click={x:Bind PlayerViewModel.SkipNext}
- **Button**  - x:Name="speedButton"; content="Speed"; events: Click=speedButton_Click
- **TextBlock**  - text="Audio Category"
- **TextBlock**  - x:Name="currentTrackTitle"; text="{x:Bind PlayerViewModel.MediaList.CurrentItem.Title, Mode=OneWay}"
- **TextBlock**  - x:Name="currentStateTextBlock"; text="{x:Bind PlayerViewModel.PlaybackSession.PlaybackState, Mode=OneWay}"
- **TextBlock**  - x:Name="StatusBlock"

### Code behavior
- **`Scenario1_Loaded`**
    - instantiates: `MediaList`, `MediaListViewModel`
    - API refs: `Debug.WriteLine`, `SettingsService.Instance`, `MediaList.LoadFromApplicationUriAsync`, `MediaList.ToPlaybackList`, `PlaybackList.ItemFailed`, `PlayerViewModel.MediaList`
- **`Scenario1_Unloaded`**
    - API refs: `Debug.WriteLine`, `SettingsService.Instance`, `PlaybackList.ItemFailed`, `PlayerViewModel.Dispose`, `GC.Collect`
- **`UpdateControlVisibility`**
    - API refs: `SettingsService.Instance`, `Visibility.Visible`, `Visibility.Collapsed`
- **`PlaybackList_ItemFailed`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`, `Error.ErrorCode`, `Error.ExtendedError`, `MainPage.Current`, `NotifyType.ErrorMessage`
- **`Player_MediaPlayerRateChanged`**
    - API refs: `Dispatcher.RunAsync`, `CoreDispatcherPriority.Normal`
- **`UpdatePlaybackSpeed`**
    - API refs: `String.Format`, `Player.PlaybackSession`


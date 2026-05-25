# BackgroundMediaPlayback (C#)

> **Source**: `Samples\BackgroundMediaPlayback\cs\`  
> **Feature**: BackgroundMediaPlayback  
> **AUMID**: `Microsoft.SDKSamples.BackgroundMediaPlayback.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.BackgroundMediaPlayback.CS_8wekyb3d8bbwe`  

## Sample purpose
Shows how to create a playlist that can continue to play even when the app is no longer in the foreground.

## Scenarios demonstrated (from README)
- Enabling background media playback through a manifest capability
- Playing audio and video in the background with the MediaPlayer API
- Gapless playback with MediaPlaybackList
- Automatic SystemMediaTransportControl integration
- Update of MediaPlaybackItem DisplayProperties
- MVVM for media player apps
- JSON playlist serialization
- Background applications have a memory target
- There are lifecycle events to inform apps if over target
- Apps can respond to being over target by unloading resources, including views
- If an app needs to continue executing in the background when not playing media
- If an app needs to make networking calls in the background when not
- This changes lifecycle behavior to keep the app process from suspending as
- All media playback APIs become background enabled. That means you can use any
- Enable SystemMediaTransportControls by setting IsEnabled to true
- Set IsPlayEnabled and IsPauseEnabled to true
- Handle the corresponding ButtonPressed events
- Over limit policy: Apps must handle OnAppMemoryUsageLimitChanging to reduce
- Apps can use CoreApplication lifecycle events EnteredBackground and
- Apps can use the MemoryManager class to monitor their memory usage after a
- When the app enters the background or receives an over limit notification,
- MediaPlayer works in foreground and background apps, with UI or without. All
- A lightweight MediaPlayerElement allows binding and unbinding to a player for
- MediaPlayer has a MediaPlayerSurface that can be used to render video to a
- MediaPlayer connects to SystemMediaTransportControls through a
- The app can popupate the DisplayProperties of the MediaPlaybackItem with

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


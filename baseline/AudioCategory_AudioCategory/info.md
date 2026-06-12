# AudioCategory_AudioCategory (C#)

> **Source**: `Samples\AudioCategory_AudioCategory\cs\`  
> **Feature**: Audio Category Sample  
> **AUMID**: `Microsoft.SDKSamples.AudioCategory.CS_8wekyb3d8bbwe!AudioCategory.App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.AudioCategory.CS_8wekyb3d8bbwe`  

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: ok
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - Movie

**Description**: This scenario will play an audio stream tagged with the Movie category. This category is used to play video files where there is focus on having clear dialog, such as in movies. Use the second Audio Category sample to see the interactions between this category and Communications.

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Select Audio File"; events: Click=Default_Click

### Code behavior
- **`Default_Click`**
    - API refs: `Playback.SetAudioCategory`, `AudioCategory.Movie`, `Playback.SelectFile`

### Screenshots
Initial state:

![initial](screenshots/01_1_Movie__initial.png)

After click **Select Audio File** (popup: Open):

![popup_Select Audio File](screenshots/01_1_Movie__popup_Select_Audio_File.png)

After click **Select Audio File**:

![after_Select Audio File](screenshots/01_1_Movie__after_Select_Audio_File.png)

After click **Play**:

![after_Play](screenshots/01_1_Movie__after_Play.png)

After click **Pause**:

![after_Pause](screenshots/01_1_Movie__after_Pause.png)

---

## Scenario 2 - Media

**Description**: This scenario will play a Media audio stream. This category is typically used to play any audio file, apart from movies. Select an audio file from your library (e.g. a song), and press play. It will have similar characteristics to the Movie category, but the audio effects that are applied to each audio category might be different.

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Select Audio File"; events: Click=Default_Click

### Code behavior
- **`Default_Click`**
    - API refs: `Playback.SetAudioCategory`, `AudioCategory.Media`, `Playback.SelectFile`

### Screenshots
Initial state:

![initial](screenshots/02_2_Media__initial.png)

After click **Select Audio File** (popup: Open):

![popup_Select Audio File](screenshots/02_2_Media__popup_Select_Audio_File.png)

After click **Select Audio File**:

![after_Select Audio File](screenshots/02_2_Media__after_Select_Audio_File.png)

After click **Play**:

![after_Play](screenshots/02_2_Media__after_Play.png)

After click **Pause**:

![after_Pause](screenshots/02_2_Media__after_Pause.png)

---

## Scenario 3 - Game Chat

**Description**: This scenario will play an audio stream tagged with the Game Chat category. This category is used for in-game communication between players. This category has the same behavior as the Communications category with the exception that it does not attenuate other audio streams.

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Select Audio File"; events: Click=Default_Click

### Code behavior
- **`Default_Click`**
    - API refs: `Playback.SetAudioCategory`, `AudioCategory.GameChat`, `Playback.SelectFile`

### Screenshots
Initial state:

![initial](screenshots/03_3_Game_Chat__initial.png)

After click **Select Audio File** (popup: Open):

![popup_Select Audio File](screenshots/03_3_Game_Chat__popup_Select_Audio_File.png)

After click **Select Audio File**:

![after_Select Audio File](screenshots/03_3_Game_Chat__after_Select_Audio_File.png)

After click **Play**:

![after_Play](screenshots/03_3_Game_Chat__after_Play.png)

After click **Pause**:

![after_Pause](screenshots/03_3_Game_Chat__after_Pause.png)

---

## Scenario 4 - Speech

**Description**: This scenario will play an audio stream tagged with the Speech category. This category is used by applications that handle speech input (e.g. personal assistants, such as Cortana) and output (e.g., navigation apps).

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Select Audio File"; events: Click=Default_Click

### Code behavior
- **`Default_Click`**
    - API refs: `Playback.SetAudioCategory`, `AudioCategory.Speech`, `Playback.SelectFile`

### Screenshots
Initial state:

![initial](screenshots/04_4_Speech__initial.png)

After click **Select Audio File** (popup: Open):

![popup_Select Audio File](screenshots/04_4_Speech__popup_Select_Audio_File.png)

After click **Select Audio File**:

![after_Select Audio File](screenshots/04_4_Speech__after_Select_Audio_File.png)

After click **Play**:

![after_Play](screenshots/04_4_Speech__after_Play.png)

After click **Pause**:

![after_Pause](screenshots/04_4_Speech__after_Pause.png)

---

## Scenario 5 - Communications

**Description**: This scenario will play an audio stream tagged with the Communications category. This category is used by VOIP apps, such as Skype and Lync. If a separate communications device is connected (Blutooth HFP) audio will play via that endpoint instead of stereo speakers. Note the interactions between Media/Movie audio and Communications streams. Play one using the Audio Category Copy SDK sample, and then the other with Audio Category SDK sample to see how they interact. Communications will attenuate the Music and Movie streams (so that users use VOIP apps to chat while there is audio in the background).

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Select Audio File"; events: Click=Default_Click

### Code behavior
- **`Default_Click`**
    - API refs: `Playback.SetAudioCategory`, `AudioCategory.Communications`, `Playback.SelectFile`

### Screenshots
Initial state:

![initial](screenshots/05_5_Communications__initial.png)

After click **Select Audio File** (popup: Open):

![popup_Select Audio File](screenshots/05_5_Communications__popup_Select_Audio_File.png)

After click **Select Audio File**:

![after_Select Audio File](screenshots/05_5_Communications__after_Select_Audio_File.png)

After click **Play**:

![after_Play](screenshots/05_5_Communications__after_Play.png)

After click **Pause**:

![after_Pause](screenshots/05_5_Communications__after_Pause.png)

---

## Scenario 6 - Alerts

**Description**: This scenario will play a stream tagged as Alerts. Notice that this stream will attenuate Media and Movie streams when the alert is played.

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Select Audio File"; events: Click=Default_Click

### Code behavior
- **`Default_Click`**
    - API refs: `Playback.SetAudioCategory`, `AudioCategory.Alerts`, `Playback.SelectFile`

### Screenshots
Initial state:

![initial](screenshots/06_6_Alerts__initial.png)

After click **Select Audio File** (popup: Open):

![popup_Select Audio File](screenshots/06_6_Alerts__popup_Select_Audio_File.png)

After click **Select Audio File**:

![after_Select Audio File](screenshots/06_6_Alerts__after_Select_Audio_File.png)

After click **Play**:

![after_Play](screenshots/06_6_Alerts__after_Play.png)

After click **Pause**:

![after_Pause](screenshots/06_6_Alerts__after_Pause.png)

---

## Scenario 7 - Sound Effects

**Description**: This scenario will play an audio stream tagged with the Sound Effects category. This category is used by applications that play sound effects.

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Select Audio File"; events: Click=Default_Click

### Code behavior
- **`Default_Click`**
    - API refs: `Playback.SetAudioCategory`, `AudioCategory.SoundEffects`, `Playback.SelectFile`

### Screenshots
Initial state:

![initial](screenshots/07_7_Sound_Effects__initial.png)

After click **Select Audio File** (popup: Open):

![popup_Select Audio File](screenshots/07_7_Sound_Effects__popup_Select_Audio_File.png)

After click **Select Audio File**:

![after_Select Audio File](screenshots/07_7_Sound_Effects__after_Select_Audio_File.png)

After click **Play**:

![after_Play](screenshots/07_7_Sound_Effects__after_Play.png)

After click **Pause**:

![after_Pause](screenshots/07_7_Sound_Effects__after_Pause.png)

---

## Scenario 8 - Game Effects

**Description**: This scenario will play an audio stream tagged with the Game Effects category. This category is used by applications that play game effects.

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Select Audio File"; events: Click=Default_Click

### Code behavior
- **`Default_Click`**
    - API refs: `Playback.SetAudioCategory`, `AudioCategory.GameEffects`, `Playback.SelectFile`

### Screenshots
Initial state:

![initial](screenshots/08_8_Game_Effects__initial.png)

After click **Select Audio File** (popup: Open):

![popup_Select Audio File](screenshots/08_8_Game_Effects__popup_Select_Audio_File.png)

After click **Select Audio File**:

![after_Select Audio File](screenshots/08_8_Game_Effects__after_Select_Audio_File.png)

After click **Play**:

![after_Play](screenshots/08_8_Game_Effects__after_Play.png)

After click **Pause**:

![after_Pause](screenshots/08_8_Game_Effects__after_Pause.png)

---

## Scenario 9 - Game Media

**Description**: This scenario will play an audio stream tagged with the Game Media category. This category is used to play audio for games. It has very similar characteristics to the Media category. However, notice that streams that use the Media category will also attenuate streams that use the Game Media category.

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Select Audio File"; events: Click=Default_Click

### Code behavior
- **`Default_Click`**
    - API refs: `Playback.SetAudioCategory`, `AudioCategory.GameMedia`, `Playback.SelectFile`

### Screenshots
Initial state:

![initial](screenshots/09_9_Game_Media__initial.png)

After click **Select Audio File** (popup: Open):

![popup_Select Audio File](screenshots/09_9_Game_Media__popup_Select_Audio_File.png)

After click **Select Audio File**:

![after_Select Audio File](screenshots/09_9_Game_Media__after_Select_Audio_File.png)

After click **Play**:

![after_Play](screenshots/09_9_Game_Media__after_Play.png)

After click **Pause**:

![after_Pause](screenshots/09_9_Game_Media__after_Pause.png)

---

## Scenario 10 - Other

**Description**: This scenario plays audio with the Other tag. It is the lowest priority audio stream and will play only in the foreground and mix with background media. Use it for generic apps that will play a few sounds while the app is in the foreground.

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Select Audio File"; events: Click=Default_Click

### Code behavior
- **`Default_Click`**
    - API refs: `Playback.SetAudioCategory`, `AudioCategory.Other`, `Playback.SelectFile`

### Screenshots
Initial state:

![initial](screenshots/10_10_Other__initial.png)

After click **Select Audio File** (popup: Open):

![popup_Select Audio File](screenshots/10_10_Other__popup_Select_Audio_File.png)

After click **Select Audio File**:

![after_Select Audio File](screenshots/10_10_Other__after_Select_Audio_File.png)

After click **Play**:

![after_Play](screenshots/10_10_Other__after_Play.png)

After click **Pause**:

![after_Pause](screenshots/10_10_Other__after_Pause.png)


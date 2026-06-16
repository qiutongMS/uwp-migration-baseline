# LanguageFont (C#)

> **Source**: `Samples\LanguageFont\cs\`  
> **Feature**: Language Font CS Sample  
> **AUMID**: `Microsoft.SDKSamples.SDKTemplate.CS_8wekyb3d8bbwe!SDKTemplate.App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.SDKTemplate.CS_8wekyb3d8bbwe`  

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: ok
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - Fonts for UI

### UI elements
- **TextBlock**  - text="This shows the use of the LanguageFontGroup to get fonts for a particular language for UI body text and heading elements. This sample uses Japanese."
- **Button**  - content="Apply Recommended Fonts"; events: Click=ApplyFonts_Click
- **TextBlock**  - x:Name="HeadingTextBlock"; text="䶧䧟みゅろ猪"
- **TextBlock**  - x:Name="BodyTextBlock"; text="訧焨を餯ダ 拣饵廦え尤 栧穃榞しゃぴゃ 餯ダ ら横襩 ペ覧へ 䨣禚詃ウォ榯 稣じ韩むにょ ぬ檧 みよ栣 グェ来げ毚廤 しゅ择れ苩㫣 スィ栩, 婧スぴゅ し짦さシャず 䥚にゃ槚じゅ谦 饟襧ッラ゜け 餯ダ 饟襧ッ 䩚埨 嫣婧スぴゅ椩 綩觚奤珣う"

### Code behavior
- **`ApplyFonts_Click`**
    - instantiates: `LanguageFontGroup`
    - API refs: `MainPage.ApplyLanguageFont`

### Screenshots
Initial state:

![initial](screenshots/01_1_Fonts_for_UI__initial.png)

After click **Apply Recommended Fonts**:

![after_Apply Recommended Fonts](screenshots/01_1_Fonts_for_UI__after_Apply_Recommended_Fonts.png)

---

## Scenario 2 - Fonts for Documents

### UI elements
- **TextBlock**  - text="This shows the use of the LanguageFontGroup to get fonts for a particular language for document body text and heading elements. This sample uses Hindi."
- **Button**  - content="Apply Recommended Fonts"; events: Click=ApplyFonts_Click 
- **TextBlock**  - x:Name="HeadingTextBlock"; text="है।अभी पत्रिका लाभान्वित"
- **TextBlock**  - x:Name="DocumentTextBlock"

### Code behavior
- **`ApplyFonts_Click`**
    - instantiates: `LanguageFontGroup`
    - API refs: `MainPage.ApplyLanguageFont`

### Screenshots
Initial state:

![initial](screenshots/02_2_Fonts_for_Documents__initial.png)

After click **Apply Recommended Fonts**:

![after_Apply Recommended Fonts](screenshots/02_2_Fonts_for_Documents__after_Apply_Recommended_Fonts.png)


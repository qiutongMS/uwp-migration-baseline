# NumberFormatting (C#)

> **Source**: `Samples\NumberFormatting\cs\`  
> **Feature**: Number formatting C# sample  
> **AUMID**: `Microsoft.SDKSamples.NumberFormatting.CS_8wekyb3d8bbwe!App`  
> **PackageFamilyName**: `Microsoft.SDKSamples.NumberFormatting.CS_8wekyb3d8bbwe`  

## Top-level UWP namespaces used
- `Windows.Globalization.NumberFormatting.PercentFormatter`
- `Windows.Globalization.NumberFormatting.PermilleFormatter`
- `Windows.Globalization.NumberFormatting.DecimalFormatter`
- `Windows.Globalization.NumberFormatting.CurrencyFormatter`
- `Windows.Globalization.NumberFormatting.IncrementNumberRounder`
- `Windows.Globalization.NumberFormatting.SignificantDigitsNumberRounder`
- `Windows.Globalization.NumberFormatting.NumeralSystemTranslator`
- `Windows.Globalization.NumberFormatting`

## Build / deploy / capture status
- build: ok
- deploy: ok
- launch: ok
- capture: ok
- uninstall: ok

## Main page
![Main page](screenshots/00_main.png)

---

## Scenario 1 - Percent and Permille Formatting

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Display"; events: Click=Display_Click
- **TextBlock**  - x:Name="OutputTextBlock"

### Code behavior
- **`Display_Click`**
    - namespaces: `Windows.Globalization.NumberFormatting.PercentFormatter`, `Windows.Globalization.NumberFormatting.PermilleFormatter`
    - instantiates: `StringBuilder`, `Random`, `PercentFormatter`, `PermilleFormatter`
    - API refs: `Windows.Globalization`, `NumberFormatting.PercentFormatter`, `NumberFormatting.PermilleFormatter`, `OutputTextBlock.Text`
    - updates UI: `OutputTextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/01_1_Percent_and_Permille_Formatting__initial.png)

After click **Display**:

![after_Display](screenshots/01_1_Percent_and_Permille_Formatting__after_Display.png)

---

## Scenario 2 - Decimal Formatting

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Display"; events: Click=Display_Click
- **TextBlock**  - x:Name="OutputTextBlock"

### Code behavior
- **`Display_Click`**
    - namespaces: `Windows.Globalization.NumberFormatting.DecimalFormatter`
    - instantiates: `StringBuilder`, `Windows.Globalization.NumberFormatting.DecimalFormatter`, `Random`
    - API refs: `Windows.Globalization`, `NumberFormatting.DecimalFormatter`, `OutputTextBlock.Text`
    - updates UI: `OutputTextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/02_2_Decimal_Formatting__initial.png)

After click **Display**:

![after_Display](screenshots/02_2_Decimal_Formatting__after_Display.png)

---

## Scenario 3 - Currency Formatting

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Display"; events: Click=Display_Click
- **TextBlock**  - x:Name="OutputTextBlock"

### Code behavior
- **`Display_Click`**
    - namespaces: `Windows.Globalization.NumberFormatting.CurrencyFormatter`
    - instantiates: `StringBuilder`, `CurrencyFormatter`
    - API refs: `Windows.Globalization`, `NumberFormatting.CurrencyFormatter`, `GlobalizationPreferences.Currencies`, `CurrencyIdentifiers.USD`, `CurrencyIdentifiers.EUR`, `CurrencyFormatterMode.UseCurrencyCode`, `CurrencyFormatterMode.UseSymbol`, `OutputTextBlock.Text`
    - updates UI: `OutputTextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/03_3_Currency_Formatting__initial.png)

After click **Display**:

![after_Display](screenshots/03_3_Currency_Formatting__after_Display.png)

---

## Scenario 4 - Number Parsing

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Display"; events: Click=Display_Click
- **TextBlock**  - x:Name="OutputTextBlock"

### Code behavior
- **`Display_Click`**
    - namespaces: `Windows.Globalization.NumberFormatting.DecimalFormatter`, `Windows.Globalization.NumberFormatting.CurrencyFormatter`, `Windows.Globalization.NumberFormatting.PercentFormatter`
    - instantiates: `StringBuilder`, `PercentFormatter`, `DecimalFormatter`, `CurrencyFormatter`
    - API refs: `Windows.Globalization`, `NumberFormatting.DecimalFormatter`, `NumberFormatting.CurrencyFormatter`, `NumberFormatting.PercentFormatter`, `GlobalizationPreferences.Currencies`, `OutputTextBlock.Text`
    - updates UI: `OutputTextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/04_4_Number_Parsing__initial.png)

After click **Display**:

![after_Display](screenshots/04_4_Number_Parsing__after_Display.png)

---

## Scenario 5 - Rounding and Padding

### UI elements
- **TextBlock**  - text="Description:"
- **Button**  - content="Display"; events: Click=Display_Click
- **TextBlock**  - x:Name="OutputTextBlock"

### Code behavior
- **`DisplayRoundingAlgorithmAsString`**
    - API refs: `RoundingAlgorithm.None`, `RoundingAlgorithm.RoundAwayFromZero`, `RoundingAlgorithm.RoundDown`, `RoundingAlgorithm.RoundHalfAwayFromZero`, `RoundingAlgorithm.RoundHalfDown`, `RoundingAlgorithm.RoundHalfToEven`, `RoundingAlgorithm.RoundHalfToOdd`, `RoundingAlgorithm.RoundHalfTowardsZero`, `RoundingAlgorithm.RoundHalfUp`, `RoundingAlgorithm.RoundTowardsZero`, `RoundingAlgorithm.RoundUp`
- **`DoPaddingAndRoundingScenarios`**
    - namespaces: `Windows.Globalization.NumberFormatting.IncrementNumberRounder`, `Windows.Globalization.NumberFormatting.DecimalFormatter`
    - instantiates: `Windows.Globalization.NumberFormatting.IncrementNumberRounder`, `Windows.Globalization.NumberFormatting.DecimalFormatter`, `StringBuilder`
    - API refs: `Windows.Globalization`, `NumberFormatting.IncrementNumberRounder`, `NumberFormatting.DecimalFormatter`
- **`DoCurrencyRoundingScenarios`**
    - namespaces: `Windows.Globalization.NumberFormatting.CurrencyFormatter`
    - instantiates: `Windows.Globalization.NumberFormatting.CurrencyFormatter`, `StringBuilder`
    - API refs: `Windows.Globalization`, `NumberFormatting.CurrencyFormatter`
- **`DoIncrementRoundingScenarios`**
    - namespaces: `Windows.Globalization.NumberFormatting.IncrementNumberRounder`, `Windows.Globalization.NumberFormatting.DecimalFormatter`
    - instantiates: `Windows.Globalization.NumberFormatting.IncrementNumberRounder`, `Windows.Globalization.NumberFormatting.DecimalFormatter`, `StringBuilder`
    - API refs: `Windows.Globalization`, `NumberFormatting.IncrementNumberRounder`, `NumberFormatting.DecimalFormatter`
- **`DoSignificantDigitRoundingScenarios`**
    - namespaces: `Windows.Globalization.NumberFormatting.SignificantDigitsNumberRounder`
    - instantiates: `Windows.Globalization.NumberFormatting.SignificantDigitsNumberRounder`, `StringBuilder`
    - API refs: `Windows.Globalization`, `NumberFormatting.SignificantDigitsNumberRounder`
- **`Display_Click`**
    - namespaces: `Windows.Globalization.NumberFormatting.DecimalFormatter`, `Windows.Globalization.NumberFormatting.PercentFormatter`
    - instantiates: `StringBuilder`, `Windows.Globalization.NumberFormatting.DecimalFormatter`, `Windows.Globalization.NumberFormatting.PercentFormatter`
    - API refs: `Windows.Globalization`, `NumberFormatting.DecimalFormatter`, `NumberFormatting.PercentFormatter`, `RoundingAlgorithm.RoundUp`, `RoundingAlgorithm.RoundDown`, `RoundingAlgorithm.RoundHalfUp`, `RoundingAlgorithm.RoundHalfDown`, `RoundingAlgorithm.RoundHalfToOdd`, `RoundingAlgorithm.RoundHalfToEven`, `OutputTextBlock.Text`
    - updates UI: `OutputTextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/05_5_Rounding_and_Padding__initial.png)

After click **Display**:

![after_Display](screenshots/05_5_Rounding_and_Padding__after_Display.png)

---

## Scenario 6 - Numeral System Translation

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="This example converts strings containing Latin numbers to an appropriate numeral system that can be rendered when digit substitution is not automatically performed."
- **Button**  - content="Display"; events: Click=Display_Click
- **TextBlock**  - x:Name="OutputTextBlock"

### Code behavior
- **`Display_Click`**
    - namespaces: `Windows.Globalization.NumberFormatting.NumeralSystemTranslator`
    - instantiates: `StringBuilder`, `Windows.Globalization.NumberFormatting.NumeralSystemTranslator`
    - API refs: `Windows.Globalization`, `NumberFormatting.NumeralSystemTranslator`, `OutputTextBlock.Text`
    - updates UI: `OutputTextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/06_6_Numeral_System_Translation__initial.png)

After click **Display**:

![after_Display](screenshots/06_6_Numeral_System_Translation__after_Display.png)

---

## Scenario 7 - Formatting/Translation using Unicode Extensions

### UI elements
- **TextBlock**  - text="Description:"
- **TextBlock**  - text="This example demonstrates how to use language names with Unicode extensions to directly set properties of number formatters."
- **Button**  - content="Display"; events: Click=Display_Click
- **TextBlock**  - x:Name="OutputTextBlock"

### Code behavior
- **`Display_Click`**
    - namespaces: `Windows.Globalization.NumberFormatting`, `Windows.Globalization.NumberFormatting.IncrementNumberRounder`
    - instantiates: `StringBuilder`, `Random`, `Windows.Globalization.NumberFormatting.IncrementNumberRounder`, `DecimalFormatter`, `CurrencyFormatter`, `PercentFormatter`, `PermilleFormatter`, `NumeralSystemTranslator`
    - API refs: `Windows.Globalization`, `NumberFormatting.IncrementNumberRounder`, `CurrencyIdentifiers.EUR`, `OutputTextBlock.Text`
    - updates UI: `OutputTextBlock.Text`

### Screenshots
Initial state:

![initial](screenshots/07_7_Formatting_Translation_using_Unicode_Extensions__initial.png)

After click **Display**:

![after_Display](screenshots/07_7_Formatting_Translation_using_Unicode_Extensions__after_Display.png)


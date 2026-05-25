<#
.SYNOPSIS
  Static analysis of one UWP sample (C# flavor).
  Produces static.json describing scenarios, UI controls, handlers and APIs.

.PARAMETER SamplePath   Path to the sample root (e.g. ...\Samples\Calendar)
.PARAMETER OutDir       Destination directory; static.json will be written here.

  Run in either PS 7 or 5.1.
#>
param(
    [Parameter(Mandatory=$true)] [string] $SamplePath,
    [Parameter(Mandatory=$true)] [string] $OutDir
)
$ErrorActionPreference = 'Continue'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$sampleName = Split-Path $SamplePath -Leaf
$csDir      = Join-Path $SamplePath 'cs'
$sharedDir  = Join-Path $SamplePath 'shared'

if (-not (Test-Path $csDir)) { Write-Error "No cs/ directory under $SamplePath"; exit 2 }

# --- 1. README ---
$readmePath = Join-Path $SamplePath 'README.md'
$readme = @{ description = $null; demonstrates = @(); api_links = @(); raw = $null }
if (Test-Path $readmePath) {
    $rmd = Get-Content $readmePath -Raw
    $readme.raw = $rmd
    # Description from YAML frontmatter ("description: \"...\"")
    if ($rmd -match '(?ms)^description:\s*"([^"]+)"') {
        $readme.description = $matches[1]
    }
    # Bullets after "This sample contains scenarios that demonstrate:" / "This sample shows how to:" / similar
    $section = $null
    if ($rmd -match '(?ms)(scenarios that demonstrate:|sample shows how to:|sample demonstrates:|sample contains examples).*?(?=\r?\n##)') {
        $section = $matches[0]
    }
    if ($section) {
        $bullets = @()
        foreach ($line in ($section -split "\r?\n")) {
            if ($line -match '^\s*[\*\-]\s+(.+)$') {
                $b = $matches[1].Trim()
                $b = ($b -replace '\[([^\]]+)\]\([^\)]+\)', '$1')   # strip markdown links to bare text
                $bullets += $b
            }
        }
        $readme.demonstrates = $bullets
    }
    # API link names (e.g. [Calendar](...))
    $links = [regex]::Matches($rmd, '\[([A-Za-z][A-Za-z0-9_\.]+)\]\(https?://[^)]+\)')
    foreach ($m in $links) {
        $n = $m.Groups[1].Value
        if ($n -match '\.' -or $n -match '^[A-Z]') {
            if ($readme.api_links -notcontains $n) { $readme.api_links += $n }
        }
    }
}

# --- 2. SampleConfiguration.cs (scenario titles + class names) ---
$cfgPath = Join-Path $csDir 'SampleConfiguration.cs'
$featureName = $null
$scenarioRefs = @()  # array of @{ title; class }
if (Test-Path $cfgPath) {
    $cfg = Get-Content $cfgPath -Raw
    if ($cfg -match 'FEATURE_NAME\s*=\s*"([^"]+)"') { $featureName = $matches[1] }
    foreach ($m in [regex]::Matches($cfg, 'Title\s*=\s*"([^"]+)"\s*,\s*ClassType\s*=\s*typeof\(\s*(?:[\w\.]*\.)?([\w_]+)\s*\)')) {
        $scenarioRefs += @{ title = $m.Groups[1].Value; class = $m.Groups[2].Value }
    }
}

# --- 3. Scenario XAML + xaml.cs pairs ---
function Get-ScenarioXaml([string]$className) {
    foreach ($d in @($csDir, $sharedDir, $SamplePath)) {
        if (-not (Test-Path $d)) { continue }
        $candidate = Join-Path $d "$className.xaml"
        if (Test-Path $candidate) { return $candidate }
    }
    return $null
}
function Get-ScenarioCs([string]$className) {
    $candidate = Join-Path $csDir "$className.xaml.cs"
    if (Test-Path $candidate) { return $candidate }
    return $null
}

function Parse-XamlControls([string]$xamlPath) {
    $controls = @()
    if (-not (Test-Path $xamlPath)) { return $controls }
    try {
        $content = Get-Content $xamlPath -Raw
        # Strip XML BOM if present
        $content = $content.TrimStart([char]0xFEFF)
        [xml]$xml = $content
    } catch {
        return $controls
    }
    # interesting control localnames
    $interesting = @('Button','TextBox','PasswordBox','ComboBox','CheckBox','RadioButton',
                     'ToggleSwitch','Slider','ListBox','ListView','GridView','TextBlock',
                     'Image','MediaElement','MediaPlayerElement','HyperlinkButton','AppBarButton',
                     'ToggleButton','SplitButton','DropDownButton','CalendarView','DatePicker',
                     'TimePicker','ColorPicker','ProgressBar','ProgressRing','RichEditBox',
                     'RichTextBlock','Canvas','InkCanvas','CaptureElement','WebView','WebView2')
    function Walk-Node($n, [int]$depth) {
        if ($null -eq $n -or $n.NodeType -ne 'Element') { return }
        $local = $n.LocalName
        if ($interesting -contains $local) {
            $entry = [ordered]@{
                type = $local
                name = $n.GetAttribute('Name')
                x_name = $n.GetAttribute('Name', 'http://schemas.microsoft.com/winfx/2006/xaml')
            }
            $attrsOfInterest = @('Content','Text','Header','PlaceholderText','Glyph','Tag')
            foreach ($a in $attrsOfInterest) {
                $v = $n.GetAttribute($a)
                if ($v) { $entry[$a.ToLower()] = $v }
            }
            $events = @('Click','Tapped','Checked','Unchecked','SelectionChanged','TextChanged',
                        'ValueChanged','Toggled','Loaded','PointerPressed','PointerReleased',
                        'KeyDown','KeyUp','ItemClick','DragStarting','DropCompleted')
            $handlers = @{}
            foreach ($ev in $events) {
                $v = $n.GetAttribute($ev)
                if ($v) { $handlers[$ev] = $v }
            }
            if ($handlers.Count -gt 0) { $entry.handlers = $handlers }
            # For container elements, try to capture inner text if no Content attr
            if (-not $entry.content -and -not $entry.text -and $local -in @('Button','TextBlock','HyperlinkButton')) {
                $inner = ($n.InnerText -replace '\s+', ' ').Trim()
                if ($inner -and $inner.Length -lt 200) { $entry.inner_text = $inner }
            }
            $script:foundControls += [pscustomobject]$entry
        }
        foreach ($c in $n.ChildNodes) { Walk-Node $c ($depth+1) }
    }
    $script:foundControls = @()
    Walk-Node $xml.DocumentElement 0
    return $script:foundControls
}

function Parse-Cs([string]$csPath) {
    $result = [ordered]@{
        usings    = @()
        handlers  = @()
        winapi_types = @()
    }
    if (-not (Test-Path $csPath)) { return $result }
    $text = Get-Content $csPath -Raw
    # using directives
    foreach ($m in [regex]::Matches($text, '(?m)^\s*using\s+([\w\.]+)\s*;')) {
        $u = $m.Groups[1].Value
        if ($result.usings -notcontains $u) { $result.usings += $u }
    }
    # method declarations: capture name + brace block (very crude balanced parser)
    $methodRegex = [regex]'(?m)(?:private|protected|public|internal)?\s*(?:async\s+)?(?:void|Task|[\w<>\.\?,\s]+)\s+([A-Z]\w*)\s*\([^\)]*\)\s*\{'
    foreach ($mm in $methodRegex.Matches($text)) {
        $name = $mm.Groups[1].Value
        # only candidates that look like handlers / business methods (skip constructors detected as type-name?)
        $start = $mm.Index + $mm.Length
        # find matching closing brace
        $depth = 1; $i = $start
        while ($i -lt $text.Length -and $depth -gt 0) {
            $c = $text[$i]
            if ($c -eq '{') { $depth++ } elseif ($c -eq '}') { $depth-- }
            $i++
        }
        $body = $text.Substring($start, ($i - $start - 1))
        # collect API class references like Windows.X.Y.Z or known class names
        $namespacesUsed = @()
        foreach ($m2 in [regex]::Matches($body, '\b((?:Windows|Microsoft)\.[\w\.]+)')) {
            $ns = $m2.Groups[1].Value
            if ($namespacesUsed -notcontains $ns) { $namespacesUsed += $ns }
        }
        # collect simple class+member references (Calendar.Foo, CalendarIdentifiers.Japanese)
        $apiRefs = @()
        foreach ($m3 in [regex]::Matches($body, '\b([A-Z][a-zA-Z0-9_]+)\.([A-Z][a-zA-Z0-9_]+)')) {
            $cls = $m3.Groups[1].Value; $mem = $m3.Groups[2].Value
            $key = "$cls.$mem"
            if ($apiRefs -notcontains $key) { $apiRefs += $key }
        }
        # types instantiated: new Foo(...)
        $newTypes = @()
        foreach ($m4 in [regex]::Matches($body, '\bnew\s+([A-Z][\w\.]+)\s*[\(<]')) {
            $t = $m4.Groups[1].Value
            if ($newTypes -notcontains $t) { $newTypes += $t }
        }
        # OutputTextBlock or similar assignments (xxxTextBlock.Text = ...)
        $uiSets = @()
        foreach ($m5 in [regex]::Matches($body, '\b(\w+(?:TextBlock|TextBox|Output|Result))\.(\w+)\s*=')) {
            $u = "$($m5.Groups[1].Value).$($m5.Groups[2].Value)"
            if ($uiSets -notcontains $u) { $uiSets += $u }
        }
        $result.handlers += [pscustomobject]@{
            name             = $name
            namespaces_used  = $namespacesUsed
            api_refs         = $apiRefs
            new_types        = $newTypes
            ui_sets          = $uiSets
            body_length      = $body.Length
        }
    }
    return $result
}

# Find Scenario#_*.xaml.cs files
$scenarioFiles = Get-ChildItem -Path $csDir -Filter 'Scenario*.xaml.cs' -ErrorAction SilentlyContinue | Sort-Object Name
$scenarios = @()
foreach ($scFile in $scenarioFiles) {
    $className = [System.IO.Path]::GetFileNameWithoutExtension($scFile.Name) -replace '\.xaml$', ''
    $xaml = Get-ScenarioXaml $className
    $cs   = $scFile.FullName
    $controls = Parse-XamlControls $xaml
    $code = Parse-Cs $cs
    # find a matching title from SampleConfiguration if any
    $match = $scenarioRefs | Where-Object { $_.class -eq $className } | Select-Object -First 1
    $title = if ($match) { $match.title } else { $className }
    # extract description text from XAML if any TextBlock has ScenarioDescriptionTextStyle
    $descText = $null
    if (Test-Path $xaml) {
        $rawXaml = Get-Content $xaml -Raw
        if ($rawXaml -match '(?s)Style="\{StaticResource\s+ScenarioDescriptionTextStyle\}"[^>]*>\s*([^<]+)') {
            $descText = ($matches[1] -replace '\s+', ' ').Trim()
        }
    }
    $scenarios += [pscustomobject]@{
        index           = ([int]([regex]::Match($className, '\d+').Value))
        class           = $className
        title           = $title
        xaml_path       = $xaml
        cs_path         = $cs
        description     = $descText
        controls        = $controls
        usings          = $code.usings
        handlers        = $code.handlers
    }
}
$scenarios = $scenarios | Sort-Object index

# Aggregate all unique APIs across the sample
$allApiNamespaces = @()
$allApiRefs = @()
foreach ($s in $scenarios) {
    foreach ($h in $s.handlers) {
        foreach ($n in $h.namespaces_used) { if ($allApiNamespaces -notcontains $n) { $allApiNamespaces += $n } }
        foreach ($r in $h.api_refs)        { if ($allApiRefs       -notcontains $r) { $allApiRefs       += $r } }
    }
}

$result = [ordered]@{
    sample            = $sampleName
    feature_name      = $featureName
    readme_description = $readme.description
    readme_bullets    = $readme.demonstrates
    readme_api_links  = $readme.api_links
    api_namespaces    = $allApiNamespaces
    api_references    = $allApiRefs
    scenarios         = $scenarios
}
$result | ConvertTo-Json -Depth 8 | Out-File (Join-Path $OutDir 'static.json') -Encoding UTF8
Write-Host "[ANALYZE] ${sampleName}: $($scenarios.Count) scenarios, $($allApiNamespaces.Count) namespaces"

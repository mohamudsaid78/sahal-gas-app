# Copies images/logo.png into Android and iOS asset locations for native splash
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $root\..\sahal_gas

$source = Join-Path (Get-Location) "images\logo.png"
if (-not (Test-Path $source)) {
    Write-Error "Source image not found: $source"
    Pop-Location
    exit 1
}

# Android: copy to drawable
$androidDestDir = "android\app\src\main\res\drawable"
if (-not (Test-Path $androidDestDir)) { New-Item -ItemType Directory -Force -Path $androidDestDir | Out-Null }
Copy-Item $source (Join-Path $androidDestDir "logo.png") -Force
Write-Output "Copied logo to $androidDestDir\logo.png"

# iOS: copy into Assets.xcassets logo.imageset
$iosDir = "ios\Runner\Assets.xcassets\logo.imageset"
if (-not (Test-Path $iosDir)) { New-Item -ItemType Directory -Force -Path $iosDir | Out-Null }
Copy-Item $source (Join-Path $iosDir "logo.png") -Force
# For convenience, duplicate for @2x and @3x (not actual scaled versions)
Copy-Item $source (Join-Path $iosDir "logo@2x.png") -Force
Copy-Item $source (Join-Path $iosDir "logo@3x.png") -Force
Write-Output "Copied logo files to $iosDir"

# Ensure Contents.json exists (the repo includes one). If not, create minimal
$contents = Join-Path $iosDir "Contents.json"
if (-not (Test-Path $contents)) {
    $json = @"{
  \"images\" : [
    { \"idiom\" : \"universal\", \"filename\" : \"logo.png\", \"scale\" : \"1x\" },
    { \"idiom\" : \"universal\", \"filename\" : \"logo@2x.png\", \"scale\" : \"2x\" },
    { \"idiom\" : \"universal\", \"filename\" : \"logo@3x.png\", \"scale\" : \"3x\" }
  ],
  \"info\" : { \"version\" : 1, \"author\" : \"xcode\" }
}"
    $json | Out-File -FilePath $contents -Encoding utf8
    Write-Output "Created Contents.json in $iosDir"
} else {
    Write-Output "Contents.json already exists in $iosDir"
}

Pop-Location

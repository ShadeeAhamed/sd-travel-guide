$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $projectRoot 'assets\branding\sd_travel_guide_logo.png'
$androidRes = Join-Path $projectRoot 'android\app\src\main\res'

Add-Type -AssemblyName System.Drawing

$sizes = @{
  'mipmap-mdpi' = 48
  'mipmap-hdpi' = 72
  'mipmap-xhdpi' = 96
  'mipmap-xxhdpi' = 144
  'mipmap-xxxhdpi' = 192
}

$source = [System.Drawing.Image]::FromFile($sourcePath)
$cropX = 120
$cropY = 110
$cropSize = [Math]::Min($source.Width - ($cropX * 2), $source.Height - ($cropY * 2))

try {
  foreach ($folder in $sizes.Keys) {
    $size = $sizes[$folder]
    $targetFile = Join-Path $androidRes "$folder\ic_launcher.png"

    $bitmap = New-Object System.Drawing.Bitmap $size, $size
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    try {
      $graphics.Clear([System.Drawing.Color]::FromArgb(11, 16, 32))
      $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
      $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

      $padding = [int]([Math]::Round($size * 0.06))
      $drawSize = $size - ($padding * 2)
      $destRect = New-Object System.Drawing.Rectangle $padding, $padding, $drawSize, $drawSize
      $srcRect = New-Object System.Drawing.Rectangle $cropX, $cropY, $cropSize, $cropSize
      $graphics.DrawImage($source, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)

      $bitmap.Save($targetFile, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
      $graphics.Dispose()
      $bitmap.Dispose()
    }
  }
}
finally {
  $source.Dispose()
}

Write-Host 'Android launcher icons updated from branding asset.'

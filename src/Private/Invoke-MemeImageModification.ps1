function Invoke-MemeImageModification {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ImagePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,

        [Parameter()]
        [string]$TopText = '',

        [Parameter()]
        [string]$BottomText = ''
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
        if (-not $IsWindows) {
            throw 'This function requires Windows OS due to System.Drawing dependencies.'
        }
    }

    process {
        try {
            Write-Verbose "Modifying image $ImagePath and saving to $OutputPath"
            $bitmap = [System.Drawing.Image]::FromFile($ImagePath)
            Write-Verbose "Raw bitmap dimensions after load: Width=$($bitmap.Width) Height=$($bitmap.Height)"
            Write-Verbose "EXIF property IDs present: $($bitmap.PropertyIdList -join ', ')"

            # Normalize EXIF orientation so bitmap.Width/Height match the displayed dimensions.
            # Viewers (Windows Photo Viewer, browsers) auto-apply EXIF rotation, but
            # System.Drawing reports raw stored dimensions. Without this correction,
            # centering math uses the wrong axis for portrait images.
            $exifOrientationId = 274
            if ($bitmap.PropertyIdList -contains $exifOrientationId) {
                $orientationValue = $bitmap.GetPropertyItem($exifOrientationId).Value[0]
                Write-Verbose "EXIF orientation tag (274) found, value: $orientationValue"
                $rotateFlipType = switch ($orientationValue) {
                    2 { [System.Drawing.RotateFlipType]::RotateNoneFlipX }
                    3 { [System.Drawing.RotateFlipType]::Rotate180FlipNone }
                    4 { [System.Drawing.RotateFlipType]::Rotate180FlipX }
                    5 { [System.Drawing.RotateFlipType]::Rotate90FlipX }
                    6 { [System.Drawing.RotateFlipType]::Rotate90FlipNone }
                    7 { [System.Drawing.RotateFlipType]::Rotate270FlipX }
                    8 { [System.Drawing.RotateFlipType]::Rotate270FlipNone }
                    default { $null }
                }
                if ($null -ne $rotateFlipType) {
                    $bitmap.RotateFlip($rotateFlipType)
                    $bitmap.RemovePropertyItem($exifOrientationId)
                    Write-Verbose "Applied EXIF orientation correction (tag value: $orientationValue)"
                    Write-Verbose "Bitmap dimensions after EXIF correction: Width=$($bitmap.Width) Height=$($bitmap.Height)"
                } else {
                    Write-Verbose "EXIF orientation value $orientationValue requires no rotation"
                }
            } else {
                Write-Verbose 'No EXIF orientation tag found, using raw dimensions as-is'
            }

            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
            $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

            Write-Verbose "Bitmap DPI: HorzRes=$($bitmap.HorizontalResolution) VertRes=$($bitmap.VerticalResolution)"
            Write-Verbose "Graphics DPI: DpiX=$($graphics.DpiX) DpiY=$($graphics.DpiY)"
            Write-Verbose "PixelFormat: $($bitmap.PixelFormat)"

            # Check if Impact font is available; warn if falling back to a system default
            $impactCheck = New-Object System.Drawing.Font('Impact', 12, [System.Drawing.FontStyle]::Bold)
            Write-Verbose "Font resolved: '$($impactCheck.Name)' (requested 'Impact') — $(if ($impactCheck.Name -ne 'Impact') { 'WARNING: Impact not installed, using fallback' } else { 'OK' })"
            $impactCheck.Dispose()

            $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
            $font = $null
            $padding = 10

            # Detect the actual content width by scanning columns from the right edge inward.
            # Some templates have baked-in whitespace on the right that would offset text centering.
            $whiteThreshold = 240
            $sampleStep = 10
            $contentWidth = $bitmap.Width
            for ($col = $bitmap.Width - 1; $col -ge [int]($bitmap.Width * 0.5); $col--) {
                $isBlank = $true
                for ($row = 0; $row -lt $bitmap.Height; $row += $sampleStep) {
                    $pixel = $bitmap.GetPixel($col, $row)
                    if ($pixel.R -lt $whiteThreshold -or $pixel.G -lt $whiteThreshold -or $pixel.B -lt $whiteThreshold) {
                        $isBlank = $false
                        break
                    }
                }
                if (-not $isBlank) {
                    $contentWidth = $col + 1
                    break
                }
            }
            Write-Verbose "Content width detection: bitmap=$($bitmap.Width)px  detectedContent=$($contentWidth)px  (scanned right 50% of columns)"

            $maxFontSize = [float][Math]::Min(40, $contentWidth / 5)
            $availableWidth = $contentWidth - 2 * $padding
            Write-Verbose "Image dimensions for layout: Width=$($bitmap.Width) Height=$($bitmap.Height)"
            Write-Verbose "ContentWidth=$contentWidth  Padding=$padding  MaxFontSize=$maxFontSize pt  AvailableWidth=$availableWidth px"
            # GenericTypographic gives true text bounds without GDI+ whitespace padding
            $typographicFormat = [System.Drawing.StringFormat]::GenericTypographic

            if (-not [string]::IsNullOrWhiteSpace($TopText)) {
                $text = $TopText.ToUpper()
                $fontSize = $maxFontSize
                $font = New-Object System.Drawing.Font('Impact', $fontSize, [System.Drawing.FontStyle]::Bold)
                $size = $graphics.MeasureString($text, $font, [System.Drawing.PointF]::Empty, $typographicFormat)
                Write-Verbose "TopText='$text'  Initial measured size: Width=$([Math]::Round($size.Width,1)) Height=$([Math]::Round($size.Height,1)) at $fontSize pt"
                $iterations = 0
                while ($size.Width -gt $availableWidth -and $fontSize -gt 8) {
                    $font.Dispose()
                    $fontSize -= 1
                    $iterations++
                    $font = New-Object System.Drawing.Font('Impact', $fontSize, [System.Drawing.FontStyle]::Bold)
                    $size = $graphics.MeasureString($text, $font, [System.Drawing.PointF]::Empty, $typographicFormat)
                }
                Write-Verbose "TopText scaling: $iterations iteration(s)  fitCheck=($([Math]::Round($size.Width,1)) <= $availableWidth)"
                $x = [float][Math]::Max(($contentWidth - $size.Width) / 2, $padding)
                Write-Verbose "TopText final: fontSize=$fontSize pt  textWidth=$([Math]::Round($size.Width,1))  x=$([Math]::Round($x,1))  y=$padding"
                $point = New-Object System.Drawing.PointF($x, [float]$padding)
                $graphics.DrawString($text, $font, $brush, $point, $typographicFormat)
                $font.Dispose()
                $font = $null
            }

            if (-not [string]::IsNullOrWhiteSpace($BottomText)) {
                $text = $BottomText.ToUpper()
                $fontSize = $maxFontSize
                $font = New-Object System.Drawing.Font('Impact', $fontSize, [System.Drawing.FontStyle]::Bold)
                $size = $graphics.MeasureString($text, $font, [System.Drawing.PointF]::Empty, $typographicFormat)
                Write-Verbose "BottomText='$text'  Initial measured size: Width=$([Math]::Round($size.Width,1)) Height=$([Math]::Round($size.Height,1)) at $fontSize pt"
                $iterations = 0
                while ($size.Width -gt $availableWidth -and $fontSize -gt 8) {
                    $font.Dispose()
                    $fontSize -= 1
                    $iterations++
                    $font = New-Object System.Drawing.Font('Impact', $fontSize, [System.Drawing.FontStyle]::Bold)
                    $size = $graphics.MeasureString($text, $font, [System.Drawing.PointF]::Empty, $typographicFormat)
                }
                Write-Verbose "BottomText scaling: $iterations iteration(s)  fitCheck=($([Math]::Round($size.Width,1)) <= $availableWidth)"
                $x = [float][Math]::Max(($contentWidth - $size.Width) / 2, $padding)
                $y = [float]($bitmap.Height - $size.Height - $padding)
                Write-Verbose "BottomText final: fontSize=$fontSize pt  textWidth=$([Math]::Round($size.Width,1))  x=$([Math]::Round($x,1))  y=$([Math]::Round($y,1))"
                $point = New-Object System.Drawing.PointF($x, $y)
                $graphics.DrawString($text, $font, $brush, $point, $typographicFormat)
                $font.Dispose()
                $font = $null
            }

            $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
            $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 100L)

            [void] ($bitmap.Save($OutputPath, $jpegCodec, $encoderParams))
        } catch {
            Write-Verbose "$($MyInvocation.MyCommand) Operation failed: $_"
            Write-Verbose "StackTrace: $($_.ScriptStackTrace)"
            throw $_
        } finally {
            if ($null -ne $graphics) { $graphics.Dispose() }
            if ($null -ne $bitmap) { $bitmap.Dispose() }
            if ($null -ne $brush) { $brush.Dispose() }
            if ($null -ne $font) { $font.Dispose() }
            if ($null -ne $encoderParams) { $encoderParams.Dispose() }
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}

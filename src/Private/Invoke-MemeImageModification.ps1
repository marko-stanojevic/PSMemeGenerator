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

            # Normalize EXIF orientation so bitmap.Width/Height match the displayed dimensions.
            # Viewers (Windows Photo Viewer, browsers) auto-apply EXIF rotation, but
            # System.Drawing reports raw stored dimensions. Without this correction,
            # centering math uses the wrong axis for portrait images.
            $exifOrientationId = 274
            if ($bitmap.PropertyIdList -contains $exifOrientationId) {
                $orientationValue = $bitmap.GetPropertyItem($exifOrientationId).Value[0]
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
                }
            }

            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
            $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

            $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
            $font = $null
            $padding = 10
            $maxFontSize = [float][Math]::Min(40, $bitmap.Width / 5)
            # GenericTypographic gives true text bounds without GDI+ whitespace padding
            $typographicFormat = [System.Drawing.StringFormat]::GenericTypographic

            if (-not [string]::IsNullOrWhiteSpace($TopText)) {
                $text = $TopText.ToUpper()
                $fontSize = $maxFontSize
                $font = New-Object System.Drawing.Font('Impact', $fontSize, [System.Drawing.FontStyle]::Bold)
                $size = $graphics.MeasureString($text, $font, [System.Drawing.PointF]::Empty, $typographicFormat)
                while ($size.Width -gt ($bitmap.Width - 2 * $padding) -and $fontSize -gt 8) {
                    $font.Dispose()
                    $fontSize -= 1
                    $font = New-Object System.Drawing.Font('Impact', $fontSize, [System.Drawing.FontStyle]::Bold)
                    $size = $graphics.MeasureString($text, $font, [System.Drawing.PointF]::Empty, $typographicFormat)
                }
                Write-Verbose "TopText font size: $fontSize pt"
                $x = [float][Math]::Max(($bitmap.Width - $size.Width) / 2, $padding)
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
                while ($size.Width -gt ($bitmap.Width - 2 * $padding) -and $fontSize -gt 8) {
                    $font.Dispose()
                    $fontSize -= 1
                    $font = New-Object System.Drawing.Font('Impact', $fontSize, [System.Drawing.FontStyle]::Bold)
                    $size = $graphics.MeasureString($text, $font, [System.Drawing.PointF]::Empty, $typographicFormat)
                }
                Write-Verbose "BottomText font size: $fontSize pt"
                $x = [float][Math]::Max(($bitmap.Width - $size.Width) / 2, $padding)
                $y = [float]($bitmap.Height - $size.Height - $padding)
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

function Invoke-MemeImageModification {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('InjectionRisk.AddType', '',
        Justification = 'Suppress false positives in PSRule for Add-Type usage')]
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
        if (-not ([AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetName().Name -eq 'System.Drawing' })) {
            Add-Type -AssemblyName 'System.Drawing'
        }
    }

    process {
        try {
            Write-Verbose "Modifying image $ImagePath and saving to $OutputPath"
            $bitmap = [System.Drawing.Image]::FromFile($ImagePath)
            $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
            $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
            $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

            $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
            $font = New-Object System.Drawing.Font('Impact', 40, [System.Drawing.FontStyle]::Bold)
            $padding = 10
            # GenericTypographic gives true text bounds without GDI+ whitespace padding
            $typographicFormat = [System.Drawing.StringFormat]::GenericTypographic

            if (-not [string]::IsNullOrWhiteSpace($TopText)) {
                $text = $TopText.ToUpper()
                $size = $graphics.MeasureString($text, $font, [System.Drawing.PointF]::Empty, $typographicFormat)
                $x = [float][Math]::Max(($bitmap.Width - $size.Width) / 2, $padding)
                $point = New-Object System.Drawing.PointF($x, [float]$padding)
                $graphics.DrawString($text, $font, $brush, $point, $typographicFormat)
            }

            if (-not [string]::IsNullOrWhiteSpace($BottomText)) {
                $text = $BottomText.ToUpper()
                $size = $graphics.MeasureString($text, $font, [System.Drawing.PointF]::Empty, $typographicFormat)
                $x = [float][Math]::Max(($bitmap.Width - $size.Width) / 2, $padding)
                $y = [float]($bitmap.Height - $size.Height - $padding)
                $point = New-Object System.Drawing.PointF($x, $y)
                $graphics.DrawString($text, $font, $brush, $point, $typographicFormat)
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

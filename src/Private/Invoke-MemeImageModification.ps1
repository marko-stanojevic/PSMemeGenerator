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

            $format = New-Object System.Drawing.StringFormat
            $format.Alignment = [System.Drawing.StringAlignment]::Center

            if (-not [string]::IsNullOrWhiteSpace($TopText)) {
                $format.LineAlignment = [System.Drawing.StringAlignment]::Near
                $rect = New-Object System.Drawing.RectangleF(0, 10, $bitmap.Width, $bitmap.Height)
                $graphics.DrawString($TopText.ToUpper(), $font, $brush, $rect, $format)
            }

            if (-not [string]::IsNullOrWhiteSpace($BottomText)) {
                $format.LineAlignment = [System.Drawing.StringAlignment]::Far
                $rect = New-Object System.Drawing.RectangleF(0, 0, $bitmap.Width, $bitmap.Height - 10)
                $graphics.DrawString($BottomText.ToUpper(), $font, $brush, $rect, $format)
            }

            $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
            $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
            $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 100L)

            $bitmap.Save($OutputPath, $jpegCodec, $encoderParams)

            $graphics.Dispose()
            $bitmap.Dispose()
            $brush.Dispose()
            $font.Dispose()
            $format.Dispose()
            $encoderParams.Dispose()
        } catch {
            Write-Verbose "$($MyInvocation.MyCommand) Operation failed: $_"
            Write-Verbose "StackTrace: $($_.ScriptStackTrace)"
            throw $_
        }
    }

    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}

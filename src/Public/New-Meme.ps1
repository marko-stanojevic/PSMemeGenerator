function New-Meme {
    <#
    .SYNOPSIS
        Creates a new meme by applying text to an image template.

    .DESCRIPTION
        Downloads a meme template from a URL and applies top and bottom text using System.Drawing.
        The text is drawn with a white fill and black outline, centered horizontally.
        Requires Windows OS due to System.Drawing dependencies in modern .NET.

    .PARAMETER Id
        The ID of the source meme template from Imgflip.

    .PARAMETER Name
        The name of the source meme template from Imgflip.

    .PARAMETER Url
        The URL of the source meme image.

    .PARAMETER TopText
        The text to display at the top of the meme.

    .PARAMETER BottomText
        The text to display at the bottom of the meme.

    .PARAMETER OutputPath
        The path where the generated meme image will be saved.

    .EXAMPLE
        New-Meme -Name "Drake" -TopText "WHEN YOU WRITE" -BottomText "A POWERSHELL MODULE" -OutputPath ".\meme.jpg"
        Creates a meme using the first template matching "Drake" and saves it to meme.jpg.

    .EXAMPLE
        New-Meme -Id "181913649" -TopText "WHEN YOU WRITE" -BottomText "A POWERSHELL MODULE" -OutputPath ".\meme.jpg"
        Creates a meme using the template with ID "181913649" and saves it to meme.jpg.

    .OUTPUTS
        System.IO.FileInfo
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'ByName')]
    param (
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Id,

        [Parameter(Mandatory, ParameterSetName = 'ByName', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName = 'ByUrl', ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Url,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $OutputPath,

        [Parameter(Mandatory = $false)]
        [string]
        $TopText = '',

        [Parameter(Mandatory = $false)]
        [string]
        $BottomText = ''
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"

        if ($null -ne $IsWindows -and -not $IsWindows) {
            throw 'This function requires Windows OS due to System.Drawing dependencies.'
        }

        # Ensure System.Drawing is loaded
        try {
            $null = [System.Reflection.Assembly]::LoadWithPartialName('System.Drawing')
        } catch {
            throw 'Failed to load System.Drawing. This module requires Windows.'
        }
    }

    process {
        try {
            $resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)

            $targetUrl = $Url
            if ($PSCmdlet.ParameterSetName -eq 'ById') {
                Write-Verbose "Looking up meme template by ID: $Id"
                $template = Get-MemeTemplate | Where-Object Id -EQ $Id | Select-Object -First 1
                if (-not $template) {
                    throw "Could not find a meme template with ID '$Id'."
                }
                $targetUrl = $template.Url
            } elseif ($PSCmdlet.ParameterSetName -eq 'ByName') {
                Write-Verbose "Looking up meme template by Name: $Name"
                $template = Get-MemeTemplate -Name $Name | Select-Object -First 1
                if (-not $template) {
                    throw "Could not find a meme template matching Name '$Name'."
                }
                $targetUrl = $template.Url
            }

            if ($PSCmdlet.ShouldProcess($resolvedPath, "Create meme from $targetUrl")) {
                Write-Verbose "Downloading image from $targetUrl"

                # Download image to memory
                $webClient = [System.Net.WebClient]::new()
                $imageBytes = $webClient.DownloadData($targetUrl)
                $memoryStream = [System.IO.MemoryStream]::new($imageBytes)

                try {
                    $image = [System.Drawing.Image]::FromStream($memoryStream)
                    $graphics = [System.Drawing.Graphics]::FromImage($image)

                    # Set up graphics quality
                    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
                    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
                    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

                    # Calculate font size based on image height (roughly 1/10th of height)
                    $fontSize = [math]::Max(12, [math]::Round($image.Height / 10))
                    $font = [System.Drawing.Font]::new('Impact', $fontSize, [System.Drawing.FontStyle]::Bold)

                    # Set up text formatting (centered)
                    $format = [System.Drawing.StringFormat]::new()
                    $format.Alignment = [System.Drawing.StringAlignment]::Center
                    $format.LineAlignment = [System.Drawing.StringAlignment]::Center

                    # Set up drawing path for outline effect
                    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()

                    # Draw Top Text
                    if (-not [string]::IsNullOrWhiteSpace($TopText)) {
                        $topRect = [System.Drawing.RectangleF]::new(0, 10, $image.Width, $fontSize * 2)
                        $path.AddString($TopText.ToUpper(), $font.FontFamily, [int]$font.Style, $graphics.DpiY * $font.Size / 72, $topRect, $format)
                    }

                    # Draw Bottom Text
                    if (-not [string]::IsNullOrWhiteSpace($BottomText)) {
                        $bottomRect = [System.Drawing.RectangleF]::new(0, $image.Height - ($fontSize * 2) - 10, $image.Width, $fontSize * 2)
                        $path.AddString($BottomText.ToUpper(), $font.FontFamily, [int]$font.Style, $graphics.DpiY * $font.Size / 72, $bottomRect, $format)
                    }

                    # Draw the text with outline
                    if ($path.PointCount -gt 0) {
                        $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::Black, [math]::Max(2, $fontSize / 15))
                        $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
                        $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)

                        $graphics.DrawPath($pen, $path)
                        $graphics.FillPath($brush, $path)

                        $pen.Dispose()
                        $brush.Dispose()
                    }

                    # Save the image
                    Write-Verbose "Saving meme to $resolvedPath"
                    $image.Save($resolvedPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)

                    # Return the created file info
                    Get-Item -Path $resolvedPath
                } finally {
                    if ($null -ne $path) { $path.Dispose() }
                    if ($null -ne $format) { $format.Dispose() }
                    if ($null -ne $font) { $font.Dispose() }
                    if ($null -ne $graphics) { $graphics.Dispose() }
                    if ($null -ne $image) { $image.Dispose() }
                    if ($null -ne $memoryStream) { $memoryStream.Dispose() }
                    if ($null -ne $webClient) { $webClient.Dispose() }
                }
            }
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

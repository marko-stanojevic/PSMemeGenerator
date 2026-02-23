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
                try {
                    $response = Invoke-WebRequest -Uri $targetUrl -Method Get
                    $imageBytes = $response.Content
                } catch {
                    throw "Failed to download image from $targetUrl. Error: $_"
                }

                # Call the private function to handle the image modification
                Invoke-MemeImageModification -ImageBytes $imageBytes -OutputPath $resolvedPath -TopText $TopText -BottomText $BottomText
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

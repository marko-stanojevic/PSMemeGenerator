function New-Meme {
    <#
    .SYNOPSIS
        Creates a new meme by applying text to an image template.

    .DESCRIPTION
        Downloads a meme template from a URL and applies top and bottom text using System.Drawing.
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
        Defaults to the current user's Desktop. The filename is derived from BottomText (or TopText
        if BottomText is not provided), with spaces replaced by underscores (e.g. meme_like_a_boss.jpg).
        Falls back to meme.jpg if neither text is provided.

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

        [Parameter()]
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
            if ([string]::IsNullOrEmpty($OutputPath)) {
                $desktop = [System.Environment]::GetFolderPath('Desktop')
                $textForName = if (-not [string]::IsNullOrWhiteSpace($BottomText)) { $BottomText } elseif (-not [string]::IsNullOrWhiteSpace($TopText)) { $TopText } else { 'meme' }
                $safeName = ($textForName.ToLower() -replace '[^a-z0-9]+', '_').Trim('_')
                $OutputPath = Join-Path $desktop "meme_$safeName.jpg"
                Write-Verbose "No OutputPath specified, defaulting to: $OutputPath"
            }

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

                $tempFile = [System.IO.Path]::GetTempFileName()
                try {
                    Invoke-WebRequest -Uri $targetUrl -OutFile $tempFile
                    Invoke-MemeImageModification -ImagePath $tempFile -OutputPath $resolvedPath -TopText $TopText -BottomText $BottomText
                    Get-Item -Path $resolvedPath
                } finally {
                    if (Test-Path $tempFile) {
                        Remove-Item -Path $tempFile -Force
                    }
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

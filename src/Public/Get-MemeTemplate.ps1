function Get-MemeTemplate {
    <#
    .SYNOPSIS
        Gets a list of popular meme templates from Imgflip.

    .DESCRIPTION
        Retrieves the top 100 most popular meme templates from the Imgflip API.
        Returns objects containing the meme ID, name, URL, width, and height.

    .EXAMPLE
        Get-MemeTemplate
        Returns all available meme templates.

    .EXAMPLE
        Get-MemeTemplate -Name 'Drake'
        Finds meme templates with 'Drake' in the name.

    .OUTPUTS
        PSCustomObject
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [string]
        $Name
    )

    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }

    process {
        try {
            $uri = 'https://api.imgflip.com/get_memes'
            Write-Verbose "Fetching meme templates from $uri"

            $response = Invoke-RestMethod -Uri $uri -Method Get

            if ($response.success) {
                foreach ($meme in $response.data.memes) {
                    if ([string]::IsNullOrEmpty($Name) -or $meme.name -match $Name) {
                        [PSCustomObject]@{
                            Id       = $meme.id
                            Name     = $meme.name
                            Url      = $meme.url
                            Width    = $meme.width
                            Height   = $meme.height
                            BoxCount = $meme.box_count
                        }
                    }
                }
            } else {
                throw "Imgflip API returned an error: $($response.error_message)"
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

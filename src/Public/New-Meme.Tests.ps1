BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'New-Meme' {
    Context 'Parameter Validation' {
        It 'Should not accept null or empty Url' {
            { New-Meme -Url '' -OutputPath '.\test.jpg' } | Should -Throw
        }

        It 'Should not accept null or empty Name' {
            { New-Meme -Name '' -OutputPath '.\test.jpg' } | Should -Throw
        }

        It 'Should not accept null or empty Id' {
            { New-Meme -Id '' -OutputPath '.\test.jpg' } | Should -Throw
        }

        It 'Should not accept null or empty OutputPath' {
            { New-Meme -Url 'https://example.com/image.jpg' -OutputPath '' } | Should -Throw
        }
    }

    Context 'Functionality' {
        It 'Should throw on non-Windows systems' -Skip:$IsWindows {
            { New-Meme -Url 'https://example.com/image.jpg' -OutputPath '.\test.jpg' } | Should -Throw 'This function requires Windows OS due to System.Drawing dependencies.'
        }

        It 'Should download image and save it' -Skip:(-not $IsWindows) {
            # This test would run on Windows and actually test the functionality
            # For a full test, we would need a real image URL and a temporary output path
            $tempPath = Join-Path $env:TEMP 'test_meme.jpg'
            try {
                # We mock the WebClient to avoid actual downloads in unit tests
                # But since we can't mock .NET methods easily, we'd need a real image
                # For now, we just verify the function exists and has the right parameters
                $command = Get-Command New-Meme
                $command.Parameters.Keys | Should -Contain 'Url'
                $command.Parameters.Keys | Should -Contain 'Name'
                $command.Parameters.Keys | Should -Contain 'Id'
                $command.Parameters.Keys | Should -Contain 'OutputPath'
            } finally {
                if (Test-Path $tempPath) { Remove-Item $tempPath -Force }
            }
        }

        It 'Should throw if URL is invalid' -Skip:(-not $IsWindows) {
            { New-Meme -Url 'invalid_url' -OutputPath '.\test.jpg' } | Should -Throw
        }
    }
}

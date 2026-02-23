BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
    . $PSCommandPath.Replace('New-Meme.Tests.ps1', '../Private/Invoke-MemeImageModification.ps1')
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
        It 'Should download image and call Invoke-MemeImageModification' {
            # Mock the WebClient
            Mock Invoke-RestMethod { return [byte[]]@(1, 2, 3) }

            # Mock the private function
            Mock Invoke-MemeImageModification { return [System.IO.FileInfo]::new('C:\test.jpg') }

            $result = New-Meme -Url 'https://example.com/image.jpg' -OutputPath '.\test.jpg' -TopText 'TOP' -BottomText 'BOTTOM'

            Should -Invoke Invoke-MemeImageModification -Exactly 1
        }

        It 'Should throw if URL is invalid' {
            Mock Invoke-RestMethod { throw 'Invalid URL' }
            { New-Meme -Url 'invalid_url' -OutputPath '.\test.jpg' } | Should -Throw
        }
    }
}

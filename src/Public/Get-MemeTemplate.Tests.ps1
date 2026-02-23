BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Get-MemeTemplate' {
    Context 'Functionality' {
        It 'Should return meme templates from Imgflip API' {
            # Mock the API call
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{
                    success = $true
                    data    = [PSCustomObject]@{
                        memes = @(
                            [PSCustomObject]@{
                                id        = '181913649'
                                name      = 'Drake Hotline Bling'
                                url       = 'https://i.imgflip.com/30b1gx.jpg'
                                width     = 1200
                                height    = 1200
                                box_count = 2
                            }
                        )
                    }
                }
            }

            $result = Get-MemeTemplate

            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result[0].Id | Should -Be '181913649'
            $result[0].Name | Should -Be 'Drake Hotline Bling'
            $result[0].Url | Should -Be 'https://i.imgflip.com/30b1gx.jpg'

            Should -Invoke Invoke-RestMethod -Exactly 1
        }

        It 'Should filter meme templates by Name' {
            # Mock the API call
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{
                    success = $true
                    data    = [PSCustomObject]@{
                        memes = @(
                            [PSCustomObject]@{
                                id        = '181913649'
                                name      = 'Drake Hotline Bling'
                                url       = 'https://i.imgflip.com/30b1gx.jpg'
                                width     = 1200
                                height    = 1200
                                box_count = 2
                            },
                            [PSCustomObject]@{
                                id        = '87743020'
                                name      = 'Two Buttons'
                                url       = 'https://i.imgflip.com/1g8my4.jpg'
                                width     = 600
                                height    = 908
                                box_count = 3
                            }
                        )
                    }
                }
            }

            $result = Get-MemeTemplate -Name 'Drake'

            $result | Should -Not -BeNullOrEmpty
            $result.Count | Should -Be 1
            $result[0].Name | Should -Be 'Drake Hotline Bling'
        }

        It 'Should throw an error if API returns success = false' {
            Mock Invoke-RestMethod {
                return [PSCustomObject]@{
                    success       = $false
                    error_message = 'Invalid request'
                }
            }

            { Get-MemeTemplate } | Should -Throw 'Imgflip API returned an error: Invalid request'
        }
    }
}

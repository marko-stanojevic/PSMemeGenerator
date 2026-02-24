BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Invoke-MemeImageModification' {
    Context 'Parameter Validation' {
        It 'Should require mandatory parameters' {
            { Invoke-MemeImageModification -ImagePath 'test.jpg' -OutputPath '' -ErrorAction Stop } | Should -Throw
            { Invoke-MemeImageModification -ImagePath '' -OutputPath 'out.jpg' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Functionality' {
        It 'Should throw on non-Windows OS' {
            if ($IsWindows) {
                Set-Variable -Name IsWindows -Value $false -Scope Global -Force
                try {
                    { Invoke-MemeImageModification -ImagePath 'test.jpg' -OutputPath 'out.jpg' } | Should -Throw '*requires Windows*'
                } finally {
                    Set-Variable -Name IsWindows -Value $true -Scope Global -Force
                }
            } else {
                { Invoke-MemeImageModification -ImagePath 'test.jpg' -OutputPath 'out.jpg' } | Should -Throw '*requires Windows*'
            }
        }
    }
}

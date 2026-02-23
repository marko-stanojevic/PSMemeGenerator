BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Invoke-MemeImageModification' {
    Context 'Parameter Validation' {
        It 'Should not accept null or empty ImageBytes' {
            { Invoke-MemeImageModification -ImageBytes $null -OutputPath '.\test.jpg' } | Should -Throw
        }

        It 'Should not accept null or empty OutputPath' {
            { Invoke-MemeImageModification -ImageBytes @([byte]1, [byte]2, [byte]3) -OutputPath '' } | Should -Throw
        }
    }

    Context 'Functionality' {
        It 'Should throw on non-Windows systems' -Skip:$IsWindows {
            { Invoke-MemeImageModification -ImageBytes @([byte]1, [byte]2, [byte]3) -OutputPath '.\test.jpg' } | Should -Throw 'This function requires Windows OS due to System.Drawing dependencies.'
        }
    }
}

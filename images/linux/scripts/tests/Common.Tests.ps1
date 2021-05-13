Describe "Swift" {
    It "swift" {
        "swift --version" | Should -ReturnZeroExitCode
    }

    It "swiftc" {
        "swiftc --version" | Should -ReturnZeroExitCode
    }
}

Describe "PipxPackages" -Skip:(Test-IsUbuntu16) {
    [array]$testCases = (Get-ToolsetContent).pipx | ForEach-Object { @{package=$_.package; cmd = $_.cmd} }

    It "<package>" -TestCases $testCases {
        "$cmd --version" | Should -ReturnZeroExitCode
    }
}

BeforeDiscovery {
    if (-not (Get-Module -Name $env:BHProjectName)) {
        Import-Module -Name $env:BHPSModuleManifest -ErrorAction Stop -Force
    }
}

Describe -Name 'Get-LatestImage' -Fixture {

    BeforeAll {
        Mock -CommandName 'Get-AWSCredential' -ModuleName $env:BHProjectName -MockWith {
            [PSCustomObject] @{ ProfileName = 'fake-profile' }
        }

        Mock -CommandName 'Get-AWSRegion' -ModuleName $env:BHProjectName -MockWith {
            [PSCustomObject] @{ Region = 'us-east-1' }
        }
    }

    Context -Name 'when querying EC2 for AMIs' -Fixture {

        It -Name 'returns images sorted by CreationDate descending' -Test {
            Mock -CommandName 'Get-EC2Image' -ModuleName $env:BHProjectName -MockWith {
                @(
                    [PSCustomObject] @{ ImageId = 'ami-001'; CreationDate = '2024-01-01T00:00:00.000Z' }
                    [PSCustomObject] @{ ImageId = 'ami-003'; CreationDate = '2024-01-03T00:00:00.000Z' }
                    [PSCustomObject] @{ ImageId = 'ami-002'; CreationDate = '2024-01-02T00:00:00.000Z' }
                )
            }

            $result = Get-LatestImage -NameTag 'MyInstance' -ProfileName 'fake-profile' -Region 'us-east-1'
            $result.ImageId | Should -Be @('ami-003', 'ami-002', 'ami-001')
        }

        It -Name 'passes the NameTag filter to Get-EC2Image' -Test {
            Mock -CommandName 'Get-EC2Image' -ModuleName $env:BHProjectName -MockWith { @() }

            Get-LatestImage -NameTag 'MyInstance' -ProfileName 'fake-profile' -Region 'us-east-1' | Out-Null

            Should -Invoke -CommandName 'Get-EC2Image' -ModuleName $env:BHProjectName -Times 1 -Exactly -ParameterFilter {
                ($Filter | Where-Object { $_.Name -eq 'tag:Name' }).Values -eq 'MyInstance'
            }
        }

        It -Name 'expands -BackupDays into one creation-date filter value per day plus today' -Test {
            Mock -CommandName 'Get-EC2Image' -ModuleName $env:BHProjectName -MockWith { @() }

            Get-LatestImage -NameTag 'MyInstance' -BackupDays 5 -ProfileName 'fake-profile' -Region 'us-east-1' | Out-Null

            Should -Invoke -CommandName 'Get-EC2Image' -ModuleName $env:BHProjectName -Times 1 -Exactly -ParameterFilter {
                $dateFilter = $Filter | Where-Object { $_.Name -eq 'creation-date' }
                $dateFilter.Values.Count -eq 6
            }
        }
    }

    Context -Name 'parameter validation' -Fixture {

        It -Name 'rejects a -NameTag with disallowed characters' -Test {
            { Get-LatestImage -NameTag 'has spaces' -ProfileName 'fake-profile' -Region 'us-east-1' } | Should -Throw
        }

        It -Name 'rejects -BackupDays outside the 1..90 range' -Test {
            { Get-LatestImage -NameTag 'MyInstance' -BackupDays 0 -ProfileName 'fake-profile' -Region 'us-east-1' } | Should -Throw
            { Get-LatestImage -NameTag 'MyInstance' -BackupDays 91 -ProfileName 'fake-profile' -Region 'us-east-1' } | Should -Throw
        }
    }
}

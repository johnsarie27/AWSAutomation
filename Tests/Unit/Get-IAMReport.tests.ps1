<#
    Example unit test for AWSAutomation/Public/Get-IAMReport.ps1.

    Demonstrates the Tests/Unit/ convention documented in README.md and
    matches the SecurityTools project's existing Pester v5 pattern:

    - BeforeDiscovery loads the module from the manifest under test using
      the BuildHelpers env vars (BHProjectName, BHPSModuleManifest) that
      the existing PSake Test task sets up.
    - AWS cmdlets called by the function are mocked via
      `Mock -ModuleName $env:BHProjectName` so the mock applies inside
      the function's own module session (and inside ValidateScript
      blocks that call those cmdlets).
    - Tests drive the function through its -Path parameter set so the
      IAM credential-report fetch never touches AWS.
    - Assertions cover output shape and branch behavior - not AWS service
      state.

    Run with:
        ./Build/build.ps1 -ResolveDependency -TaskList Test
#>

BeforeDiscovery {
    if (-not (Get-Module -Name $env:BHProjectName)) {
        Import-Module -Name $env:BHPSModuleManifest -ErrorAction 'Stop' -Force
    }
}

Describe -Name 'Get-IAMReport' -Fixture {

    BeforeAll {
        # MINIMAL IAM CREDENTIAL REPORT FIXTURE
        $csvPath = Join-Path -Path $TestDrive -ChildPath 'iam-credential-report.csv'
        @(
            'user,access_key_1_active,mfa_active,password_enabled,password_last_changed,password_last_used,access_key_1_last_used_date,arn'
            'alice,true,true,true,2026-01-15T00:00:00+00:00,2026-05-01T00:00:00+00:00,2026-05-20T00:00:00+00:00,arn:aws:iam::111122223333:user/alice'
            '<root_account>,false,true,not_supported,N/A,N/A,N/A,arn:aws:iam::111122223333:root'
        ) | Set-Content -Path $csvPath

        # SATISFY THE [ValidateScript] ON -ProfileName WITHOUT TOUCHING AWS
        Mock -CommandName 'Get-AWSCredential' -ModuleName $env:BHProjectName -MockWith {
            [PSCustomObject] @{ ProfileName = 'fake-profile' }
        }
    }

    Context -Name 'when loading from -Path' -Fixture {

        It -Name 'returns one object per CSV row' -Test {
            Mock -CommandName 'Get-IAMGroupForUser' -ModuleName $env:BHProjectName -MockWith {
                @([PSCustomObject] @{ GroupName = 'admins' })
            }

            $result = Get-IAMReport -Path $csvPath -ProfileName 'fake-profile'
            $result.Count | Should -Be 2
        }

        It -Name 'projects the documented property set in order' -Test {
            Mock -CommandName 'Get-IAMGroupForUser' -ModuleName $env:BHProjectName -MockWith {
                @([PSCustomObject] @{ GroupName = 'admins' })
            }

            $result   = Get-IAMReport -Path $csvPath -ProfileName 'fake-profile'
            $expected = @(
                'User', 'AccessKeyActive', 'MFAEnabled', 'Account', 'PasswordEnabled',
                'PasswordLastChanged', 'DaysSinceLogin', 'PasswordLastUsed',
                'DaysSinceKeyUsed', 'KeyLastUsed', 'Groups', 'PrimaryGroup'
            )
            $result[0].PSObject.Properties.Name | Should -Be $expected
        }

        It -Name "short-circuits group lookups for the <root_account> row" -Test {
            Mock -CommandName 'Get-IAMGroupForUser' -ModuleName $env:BHProjectName -MockWith {
                @([PSCustomObject] @{ GroupName = 'admins' })
            }

            $result = Get-IAMReport -Path $csvPath -ProfileName 'fake-profile'
            $root   = $result | Where-Object -FilterScript { $_.User -eq '<root_account>' }

            $root.Groups       | Should -Be '0'
            $root.PrimaryGroup | Should -Be 'N/A'
            Should -Invoke -CommandName 'Get-IAMGroupForUser' -ModuleName $env:BHProjectName -Times 1 -Exactly
        }

        It -Name "represents missing date fields as 'N/A'" -Test {
            Mock -CommandName 'Get-IAMGroupForUser' -ModuleName $env:BHProjectName -MockWith { @() }

            $result = Get-IAMReport -Path $csvPath -ProfileName 'fake-profile'
            $root   = $result | Where-Object -FilterScript { $_.User -eq '<root_account>' }

            $root.PasswordLastChanged | Should -Be 'N/A'
            $root.PasswordLastUsed    | Should -Be 'N/A'
            $root.DaysSinceLogin      | Should -Be 'N/A'
            $root.KeyLastUsed         | Should -Be 'N/A'
            $root.DaysSinceKeyUsed    | Should -Be 'N/A'
        }

        It -Name "falls back to PrimaryGroup = 'None' when the user has no groups" -Test {
            Mock -CommandName 'Get-IAMGroupForUser' -ModuleName $env:BHProjectName -MockWith { @() }

            $result = Get-IAMReport -Path $csvPath -ProfileName 'fake-profile'
            $alice  = $result | Where-Object -FilterScript { $_.User -eq 'alice' }

            $alice.Groups       | Should -Be 0
            $alice.PrimaryGroup | Should -Be 'None'
        }
    }
}

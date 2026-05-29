BeforeDiscovery {
    if (-not (Get-Module -Name $env:BHProjectName)) {
        Import-Module -Name $env:BHPSModuleManifest -ErrorAction Stop -Force
    }
}

Describe -Name 'ConvertFrom-CFLog' -Fixture {

    BeforeAll {
        $logPath = Join-Path -Path $TestDrive -ChildPath 'cf.log'
        # CloudFront logs use space-separated headers and tab-separated data rows.
        $lines = @(
            '#Version: 1.0'
            '#Fields: date time x-edge-location sc-bytes c-ip cs-method'
            "2024-01-01`t12:00:00`tIAD89-C1`t1234`t192.0.2.1`tGET"
            "2024-01-01`t12:00:01`tIAD89-C2`t5678`t192.0.2.2`tPOST"
        )
        Set-Content -Path $logPath -Value $lines -Encoding ascii
    }

    Context -Name 'when loading from -Path' -Fixture {

        It -Name 'returns one object per data row' -Test {
            $result = ConvertFrom-CFLog -Path $logPath
            $result | Should -HaveCount 2
        }

        It -Name 'projects properties from the #Fields header' -Test {
            $result = ConvertFrom-CFLog -Path $logPath
            $expected = 'date', 'time', 'x-edge-location', 'sc-bytes', 'c-ip', 'cs-method'
            ($result[0].PSObject.Properties.Name) | Should -Be $expected
        }

        It -Name 'maps values to the correct properties' -Test {
            $result = ConvertFrom-CFLog -Path $logPath
            $result[0].'x-edge-location' | Should -Be 'IAD89-C1'
            $result[1].'cs-method' | Should -Be 'POST'
        }

        It -Name 'skips comment lines starting with #' -Test {
            $result = ConvertFrom-CFLog -Path $logPath
            $result.date | Should -Not -Contain '#Version: 1.0'
        }
    }

    Context -Name 'parameter validation' -Fixture {

        It -Name 'rejects a path that does not exist' -Test {
            { ConvertFrom-CFLog -Path (Join-Path -Path $TestDrive -ChildPath 'missing.log') } | Should -Throw
        }
    }
}

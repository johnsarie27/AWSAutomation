BeforeDiscovery {
    if (-not (Get-Module -Name $env:BHProjectName)) {
        Import-Module -Name $env:BHPSModuleManifest -ErrorAction Stop -Force
    }
}

Describe -Name 'ConvertTo-CFStackParam' -Fixture {

    Context -Name 'normal usage' -Fixture {

        It -Name 'returns one Parameter object per hashtable key' -Test {
            $result = ConvertTo-CFStackParam -Parameter @{ pVpcCIDR = '172.16.0.0/16'; pVpcName = 'myNewVpc' }
            $result | Should -HaveCount 2
        }

        It -Name 'maps hashtable keys to ParameterKey and values to ParameterValue' -Test {
            $result = ConvertTo-CFStackParam -Parameter @{ pVpcCIDR = '172.16.0.0/16' }
            $result[0].ParameterKey | Should -Be 'pVpcCIDR'
            $result[0].ParameterValue | Should -Be '172.16.0.0/16'
        }

        It -Name 'returns Amazon.CloudFormation.Model.Parameter instances' -Test {
            $result = ConvertTo-CFStackParam -Parameter @{ pVpcName = 'x' }
            $result[0] | Should -BeOfType [Amazon.CloudFormation.Model.Parameter]
        }
    }

    Context -Name 'pipeline input' -Fixture {

        It -Name 'accepts a hashtable from the pipeline' -Test {
            $result = @{ pA = '1'; pB = '2' } | ConvertTo-CFStackParam
            $result | Should -HaveCount 2
        }
    }
}

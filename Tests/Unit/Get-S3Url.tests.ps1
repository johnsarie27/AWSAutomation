BeforeDiscovery {
    if (-not (Get-Module -Name $env:BHProjectName)) {
        Import-Module -Name $env:BHPSModuleManifest -ErrorAction Stop -Force
    }
}

Describe -Name 'Get-S3Url' -Fixture {

    Context -Name 'when -Region is supplied' -Fixture {

        It -Name 'returns a regional virtual-hosted-style URL' -Test {
            $url = Get-S3Url -BucketName 'myBucket' -Key 'Files/readme.txt' -Region 'us-west-2'
            $url | Should -Be 'https://myBucket.s3.us-west-2.amazonaws.com/Files/readme.txt'
        }
    }

    Context -Name 'when -Region is omitted' -Fixture {

        It -Name 'returns a region-less virtual-hosted-style URL' -Test {
            $url = Get-S3Url -BucketName 'myBucket' -Key 'Files/readme.txt'
            $url | Should -Be 'https://myBucket.s3.amazonaws.com/Files/readme.txt'
        }
    }

    Context -Name 'parameter validation' -Fixture {

        It -Name 'rejects an empty -BucketName' -Test {
            { Get-S3Url -BucketName '' -Key 'a/b.txt' } | Should -Throw
        }

        It -Name 'rejects a -Key containing disallowed characters' -Test {
            { Get-S3Url -BucketName 'myBucket' -Key 'has spaces.txt' } | Should -Throw
        }
    }
}

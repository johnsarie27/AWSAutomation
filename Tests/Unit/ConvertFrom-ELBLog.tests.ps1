BeforeDiscovery {
    if (-not (Get-Module -Name $env:BHProjectName)) {
        Import-Module -Name $env:BHPSModuleManifest -ErrorAction Stop -Force
    }
}

Describe -Name 'ConvertFrom-ELBLog' -Fixture {

    BeforeAll {
        $logPath = Join-Path -Path $TestDrive -ChildPath 'elb.log'

        # Representative ALB access log line (AWS docs sample, abbreviated for stability).
        $sample = 'http 2018-07-02T22:23:00.186641Z app/my-loadbalancer/50dc6c495c0c9188 192.168.131.39:2817 10.0.0.1:80 0.000 0.001 0.000 200 200 34 366 "GET http://www.example.com:80/ HTTP/1.1" "curl/7.46.0" - - arn:aws:elasticloadbalancing:us-east-2:123456789012:targetgroup/my-targets/73e2d6bc24d8a067 "Root=1-58337262-36d228ad5d99923122bbe354" "-" "-" 0 2018-07-02T22:22:48.364000Z "forward" "-" "-" "10.0.0.1:80" "200" "-" "-"'

        Set-Content -Path $logPath -Value @($sample, $sample) -Encoding ascii
    }

    Context -Name 'when loading from -Path' -Fixture {

        It -Name 'returns one object per log line' -Test {
            $result = ConvertFrom-ELBLog -Path $logPath
            $result | Should -HaveCount 2
        }

        It -Name 'projects the documented ALB access log property set' -Test {
            $result = ConvertFrom-ELBLog -Path $logPath
            $expected = 'type', 'time', 'elb', 'client_port', 'target_port',
                'request_processing_time', 'target_processing_time', 'response_processing_time',
                'elb_status_code', 'target_status_code', 'received_bytes', 'sent_bytes',
                'request', 'user_agent', 'ssl_cipher', 'ssl_protocol', 'target_group_arn',
                'trace_id', 'domain_name', 'chosen_cert_arn', 'matched_rule_priority',
                'request_creation_time', 'actions_executed', 'redirect_url', 'error_reason',
                'target_port_list', 'target_status_code_list', 'classification', 'classification_reason'
            ($result[0].PSObject.Properties.Name) | Should -Be $expected
        }

        It -Name 'parses leading whitespace-delimited fields' -Test {
            $result = ConvertFrom-ELBLog -Path $logPath
            $result[0].type | Should -Be 'http'
            $result[0].elb_status_code | Should -Be '200'
        }

        It -Name 'parses quoted segments' -Test {
            $result = ConvertFrom-ELBLog -Path $logPath
            $result[0].request | Should -Be 'GET http://www.example.com:80/ HTTP/1.1'
            $result[0].user_agent | Should -Be 'curl/7.46.0'
        }
    }

    Context -Name 'parameter validation' -Fixture {

        It -Name 'rejects a path that does not exist' -Test {
            { ConvertFrom-ELBLog -Path (Join-Path -Path $TestDrive -ChildPath 'missing.log') } | Should -Throw
        }
    }
}

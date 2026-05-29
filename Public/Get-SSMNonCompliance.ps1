function Get-SSMNonCompliance {
    <#
    .SYNOPSIS
        Get non-compliant items
    .DESCRIPTION
        Get non-compliant SSM items of type Association or Patch
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        Amazon.Runtime.AWSCredentials.
    .OUTPUTS
        Amazon.SimpleSystemsManagement.Model.ComplianceItem.
    .EXAMPLE
        PS C:\> $socCreds.Values | Get-SSMNonCompliance -Region us-east-2
        Get any non-compliant items for all accounts in us-east-2 contained in $socCreds
    .NOTES
        Status: Stable
    #>
    [CmdletBinding(DefaultParameterSetName = '_profile')]
    [OutputType([Amazon.SimpleSystemsManagement.Model.ComplianceItem[]])]
    Param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = '_profile', HelpMessage = 'AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String[]] $ProfileName,

        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ParameterSetName = '_credential', HelpMessage = 'AWS credentials object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(Mandatory, Position = 1, HelpMessage = 'AWS region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        $filter = @(
            @{ Key = 'Status'; Type = 'Equal'; Values = 'NON_COMPLIANT' }
            #@{ Key = "ComplianceType"; Values = 'Association' } # 'Association|Patch'
        )
        $nonCompliantItem = [System.Collections.Generic.List[System.Object]]::new()
        $itemProps = @('Status', 'ResourceId', 'ComplianceType', 'Severity', 'Id', 'Details')
    }
    Process {
        if ($PSCmdlet.ParameterSetName -eq '_profile') {
            foreach ( $account in $ProfileName ) {
                $creds = @{ ProfileName = $account; Region = $Region }

                $compliance = Get-SSMResourceComplianceSummaryList @creds -Filter $filter

                foreach ( $nc in $compliance ) {
                    $nonCompliantItem.Add( (Get-SSMComplianceItemList @creds -ResourceId $nc.ResourceId -Filter $filter) )
                }
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq '_credential') {
            foreach ( $account in $Credential ) {
                $creds = @{ Credential = $account; Region = $Region }

                # GET ALL COMPLIANCE
                $compliance = Get-SSMResourceComplianceSummaryList @creds -Filter $filter
                #$compliance = Get-SSMResourceComplianceSummaryList @creds
                #$props = @('ResourceId', 'ResourceType', 'ComplianceType', 'OverallSeverity', 'Status')
                #$compliance | Where-Object Status -NE 'COMPLIANT' | Format-Table -Property $props

                # GET NONCOMPLIANCE INSTANCE SUMMARY
                foreach ( $nc in $compliance ) {
                    $nonCompliantItem.Add( (Get-SSMComplianceItemList @creds -ResourceId $nc.ResourceId -Filter $filter) )
                }
            }
        }
    }
    End {
        $nonCompliantItem | Select-Object -Property $itemProps
    }
}
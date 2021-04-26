function Get-SSMNonCompliance {
    <# =========================================================================
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
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '__crd')]
    Param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = '__pro', HelpMessage = 'AWS Profile containing access key and secret')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string[]] $ProfileName,

        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(Mandatory, Position = 1, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [string] $Region
    )
    Begin {
        $filter = @(
            @{ Key = 'Status'; Type = 'Equal'; Values = 'NON_COMPLIANT' }
            #@{ Key = "ComplianceType"; Values = 'Association' } # 'Association|Patch'
        )
        $nonCompliantItem = [System.Collections.Generic.List[System.Object]]::new()
        $itemProps = @('Status', 'ResourceId', 'ComplianceType', 'Severity', 'Id', 'Details')
    }
    Process {
        if ($PSCmdlet.ParameterSetName -eq '__pro') {
            foreach ( $account in $ProfileName ) {
                $creds = @{ ProfileName = $account; Region = $Region }

                $compliance = Get-SSMResourceComplianceSummaryList @creds -Filter $filter

                foreach ( $nc in $compliance ) {
                    $nonCompliantItem.Add( (Get-SSMComplianceItemList @creds -ResourceId $nc.ResourceId -Filter $filter) )
                }
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq '__crd') {
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
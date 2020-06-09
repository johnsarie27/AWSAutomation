#Requires -Modules AWS.Tools.EC2

function Get-AvailableEBS {
    <# =========================================================================
    .SYNOPSIS
        Get "unattached" Elastic Block Store volumes
    .DESCRIPTION
        This function returns a list of custom objects with properties from AWS
        EBS volume objects where each EBS volume is available (unattached).
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-AvailableEBS -AllProfiles | Group -Property Account | Select Name, Count
        Get unattached EBS volumes, group them by Account, and display Name and Count
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '_profile')]
    [OutputType([System.Object[]])]

    Param(
        [Parameter(Mandatory, ParameterSetName = '_profile', HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string[]] $ProfileName,

        [Parameter(Mandatory, ParameterSetName = '_credential', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(HelpMessage = 'Name of desired AWS Region.')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [String] $Region = 'us-east-1'
    )

    Begin {
        $results = [System.Collections.Generic.List[System.Object]]::new()
        $awsParams = @{ Region = $Region; Filter = @{Name = "status";Values = "available"} }
    }

    Process {
        if ( $PSCmdlet.ParameterSetName -eq '_profile' ) {
            foreach ( $name in $ProfileName ) {
                foreach ( $volume in (Get-EC2Volume -ProfileName $name @awsParams) ) {
                    $volume | Add-Member -MemberType NoteProperty -Name Account -Value $name
                    $results.Add($volume)
                }
            }
        }
        if ( $PSCmdlet.ParameterSetName -eq '_credential' ) {
            foreach ( $cred in $Credential ) {
                $account = (Get-STSCallerIdentity -Credential $cred -Region $Region).Account
                foreach ( $volume in (Get-EC2Volume -Credential $cred @awsParams) ) {
                    $volume | Add-Member -MemberType NoteProperty -Name Account -Value $account
                    $results.Add($volume)
                }
            }
        }
    }

    End {
        Write-Verbose -Message ('Number of volumes: [{0}]' -f $results.Count)
        # RETURN LIST
        $results
    }
}

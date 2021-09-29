function Get-AssociationStatus {
    <# =========================================================================
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .PARAMETER Name
        Systems Manager Association name
    .PARAMETER ProfileName
        AWS credential profile name
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS Region
    .INPUTS
        Amazon.Runtime.AWSCredentials.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-AssociationStatus -Name UpdateAgent -Credential $c -Region us-east-1
        Explanation of what the example does
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0, HelpMessage = 'Systems Manager Association name')]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory, Position = 1, ParameterSetName = '__pro', HelpMessage = 'AWS Profile')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string[]] $ProfileName,

        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(Position = 2, ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [string] $Region
    )
    Process {

        if ( $PSCmdlet.ParameterSetName -eq '__crd' ) {

            foreach ( $c in $Credential ) {

                # SET CREDENTIALS
                $awsCreds = @{ Credential = $c; Region = $Region }

                # GET ALL ASSOCIATIONS
                $assocList = Get-SSMAssociationList @awsCreds

                # GET TARGET ASSOCIATION
                $assoc = $assocList | Where-Object AssociationName -Like $Name

                # GET SUCCESS AND FAILURE COUNTS
                #$assoc.Overview.AssociationStatusAggregatedCount

                # GET ALL EXECUTIONS FOR GIVEN ASSOCIATION
                $assocExec = Get-SSMAssociationExecution -AssociationId $assoc.AssociationId @awsCreds

                # GET ALL TARGET RESULTS FROM LAST EXECUTION OF GIVEN ASSOCIATION
                Get-SSMAssociationExecutionTarget -AssociationId $assoc.AssociationId -ExecutionId $assocExec[0].ExecutionId @awsCreds
            }
        }
        if ( $PSCmdlet.ParameterSetName -eq '__pro' ) {

            foreach ( $p in $ProfileName ) {

                # SET CREDENTIALS
                $awsCreds = @{ ProfileName = $p; Region = $Region }

                # GET ALL ASSOCIATIONS
                $assocList = Get-SSMAssociationList @awsCreds

                # GET TARGET ASSOCIATION
                $assoc = $assocList | Where-Object AssociationName -Like $Name

                # GET SUCCESS AND FAILURE COUNTS
                #$assoc.Overview.AssociationStatusAggregatedCount

                # GET ALL EXECUTIONS FOR GIVEN ASSOCIATION
                $assocExec = Get-SSMAssociationExecution -AssociationId $assoc.AssociationId @awsCreds

                # GET ALL TARGET RESULTS FROM LAST EXECUTION OF GIVEN ASSOCIATION
                Get-SSMAssociationExecutionTarget -AssociationId $assoc.AssociationId -ExecutionId $assocExec[0].ExecutionId @awsCreds
            }
        }
    }
}
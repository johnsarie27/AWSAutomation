function Get-PatchInfo {
    <# =========================================================================
    .SYNOPSIS
        Get AWS Systems Manager Patch information
    .DESCRIPTION
        Get AWS Systems Manager Patch information for all instances in a give
        Patch Group
    .PARAMETER PatchGroup
        Patch Group
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
        PS C:\> Get-PatchInfo PatchGroup 'staging*' -Credential $c -Region us-west-2
        Explanation of what the example does
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0, HelpMessage = 'Patch Group')]
        [ValidateNotNullOrEmpty()]
        [System.String] $PatchGroup,

        [Parameter(Mandatory, Position = 1, ParameterSetName = '__pro', HelpMessage = 'AWS Profile')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String[]] $ProfileName,

        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(Position = 2, ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )
    Process {

        if ( $PSCmdlet.ParameterSetName -eq '__crd' ) {

            foreach ( $c in $Credential ) {

                # SET AUTHENTICATION
                $creds = @{ Credential = $c; Region = $Region }

                # GET PATCH GROUPS
                $pgList = Get-SSMPatchGroup @creds | Where-Object PatchGroup -Like $PatchGroup

                foreach ( $pg in $pgList ) {

                    <# # GET SUMMARY INFO BUT NO INSTANCE DETAILS
                    # GET PATCH GROUP STATE FOR GIVEN PATCH GROUP
                    $pgState = Get-SSMPatchGroupState -PatchGroup $pg.PatchGroup @accCreds

                    # IF STATE HAS FAILURES ADD IT TO ARRAY
                    if ( $pgState.InstancesWithCriticalNonCompliantPatches -gt 0 -or $pgState.InstancesWithFailedPatches -gt 0 ) {

                        $trouble += [pscustomobject] @{ PatchGroup = $pg.PatchGroup; Details = $pgState }
                    } #>

                    # GET DETAILS FOR EACH INSTANCE
                    # GET PATCH STATE FOR ALL INSTANCES IN GIVEN PATCH GROUP
                    Get-SSMInstancePatchStatesForPatchGroup @creds -PatchGroup $pg.PatchGroup
                }
            }
        }

        if ( $PSCmdlet.ParameterSetName -eq '__pro' ) {

            foreach ( $p in $Credential ) {

                # SET AUTHENTICATION
                $creds = @{ ProfileName = $p; Region = $Region }

                # GET PATCH GROUPS
                $pgList = Get-SSMPatchGroup @creds | Where-Object PatchGroup -Like $PatchGroup

                foreach ( $pg in $pgList ) {

                    <# # GET SUMMARY INFO BUT NO INSTANCE DETAILS
                    # GET PATCH GROUP STATE FOR GIVEN PATCH GROUP
                    $pgState = Get-SSMPatchGroupState -PatchGroup $pg.PatchGroup @accCreds

                    # IF STATE HAS FAILURES ADD IT TO ARRAY
                    if ( $pgState.InstancesWithCriticalNonCompliantPatches -gt 0 -or $pgState.InstancesWithFailedPatches -gt 0 ) {

                        $trouble += [pscustomobject] @{ PatchGroup = $pg.PatchGroup; Details = $pgState }
                    } #>

                    # GET DETAILS FOR EACH INSTANCE
                    # GET PATCH STATE FOR ALL INSTANCES IN GIVEN PATCH GROUP
                    Get-SSMInstancePatchStatesForPatchGroup @creds -Region $Region
                }
            }
        }
    }
}
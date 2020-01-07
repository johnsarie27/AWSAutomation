#Requires -Modules ImportExcel, AWS.Tools.IdentityManagement

function Export-IAMRolePolicy {
    <# =========================================================================
    .SYNOPSIS
        Export a spreadsheet of each Role with accompanying Policies
    .DESCRIPTION
        Export a spreadsheet of each Role with accompanying Policies and details
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER RoleName
        Name of one or more AWS IAM Roles
    .PARAMETER Path
        Path to new report file
    .PARAMETER PassThru
        Return path to report file
    .INPUTS
        System.String.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> Export-IAMRolePolicy -ProfileName MyAwsAccount -RoleName MyNewRole
        Generates an Excel Spreadsheet of all matching Roles with a list of their Policies
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string[]] $ProfileName,

        [Parameter(ValueFromPipeline, HelpMessage = 'One or more Role names')]
        [ValidateNotNullOrEmpty()]
        [string[]] $RoleName,

        [Parameter(HelpMessage = 'Path to new report file')]
        [ValidateScript( { Test-Path -Path ([System.IO.Path]::GetDirectoryName($_)) })]
        [ValidateScript( { [System.IO.Path]::GetExtension($_) -eq '.xlsx' })]
        [string] $Path,

        [Parameter(HelpMessage = 'Return new credential object')]
        [switch] $PassThru
    )

    Begin {
        # SET EXCEL PARAMETERS
        $excelParams = @{
            AutoSize     = $true
            FreezeTopRow = $true
            MoveToEnd    = $true
            BoldTopRow   = $true
            AutoFilter   = $true
            Style        = (New-ExcelStyle -Bold -Range '1:1' -HorizontalAlignment Center)
        }

        # SET PATH
        if ( $PSBoundParameters.ContainsKey('Path') ) {
            $excelParams['Path'] = $Path
        }
        else {
            $excelParams['Path'] = Join-Path -Path "$HOME\Desktop" -ChildPath ('IAMRolePolicies_{0}.xlsx' -f (Get-Date -Format "yyyy-MM"))
        }
    }

    Process {
        # LOOP EACH ACCOUNT PROFILE
        foreach ( $pn in $ProfileName ) {
            # GET ROLES
            if ( !$PSBoundParameters.ContainsKey('RoleName') ) { $RoleName = (Get-IAMRoleList -ProfileName $pn).RoleName }

            # THIS GETS ALL THE POLICIES FOR EACH ROLE AND CREATES A COLLECTION OF CUSTOM OBJECTS
            $policies = [System.Collections.Generic.List[System.Object]]::new()

            # LOOP ALL PROVIDED ROLES
            foreach ( $rn in $RoleName ) {
                # LOOP ALL MANAGED POLICIES IN ROLE AND ADD TO LIST
                foreach ( $policy in (Get-IAMAttachedRolePolicyList -RoleName $rn -ProfileName $pn) ) {
                    $new = [PSCustomObject] @{
                        Profile    = $pn
                        RoleType   = 'Managed'
                        RoleName   = $rn
                        PolicyName = $policy.PolicyName
                        PolicyArn  = $policy.PolicyArn
                    }
                    $policies.Add($new)
                }

                # LOOP ALL IN-LINE POLICIES IN ROLE AND ADD TO LIST
                foreach ( $policy in (Get-IAMRolePolicyList -RoleName $rn -ProfileName $pn) ) {
                    $new = [PSCustomObject] @{
                        Profile    = $pn
                        RoleType   = 'In-line'
                        RoleName   = $rn
                        PolicyName = $policy.PolicyName
                        PolicyArn  = $policy.PolicyArn
                    }
                    $policies.Add($new)
                }
            }

            # WRITE POLICIES TO EXCEL
            $policies | Export-Excel @excelParams -WorksheetName $pn
        }
    }

    End {
        # RETURN NEW PATH
        if ( $PSBoundParameters.ContainsKey('PassThru') ) { $excelParams['Path'] }
    }
}

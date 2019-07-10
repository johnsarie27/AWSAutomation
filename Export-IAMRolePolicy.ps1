#Requires -Module ImportExcel

function Export-IAMRolePolicy {
    <# =========================================================================
    .SYNOPSIS
        Export a spreadsheet of each Role with accompanying Policies
    .DESCRIPTION
        Export a spreadsheet of each Role with accompanying Policies
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Path
        Path to new report file
    .PARAMETER Pattern
        Regex pattern to match Role names
    .INPUTS
        System.String.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> Export-IAMRolePolicy -ProfileName MyAwsAccount
        Generates an Excel Spreadsheet of all matching Roles with a list of their Policies
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string[]] $ProfileName,

        [Parameter(HelpMessage = 'Regex pattern to match Role names')]
        [ValidateNotNullOrEmpty()]
        [string] $Pattern = '_Administrator|_Manager',

        [Parameter(HelpMessage = 'Path to new report file')]
        [ValidateScript( { Test-Path -Path ([System.IO.Path]::GetDirectoryName($_)) })]
        [ValidateScript( { [System.IO.Path]::GetExtension($_) -eq '.xlsx' })]
        [string] $Path
    )

    Begin {
        Import-Module -Name AWSPowerShell.NetCore, ImportExcel

        $excelParams = @{
            AutoSize     = $true
            FreezeTopRow = $true
            MoveToEnd    = $true
            BoldTopRow   = $true
            AutoFilter   = $true
        }

        if ( !$PSBoundParameters.ContainsKey('Path') ) {
            $date = Get-Date -Format "yyyy-MM"
            $excelParams['Path'] = Join-Path -Path "$HOME\Desktop" -ChildPath ('IAMRolePolicies_{0}.xlsx' -f $date)
        }
    }

    Process {
        foreach ( $pn in $ProfileName ) {
            $splat = @{ ProfileName = $pn }

            # GET ROLES
            $roleName = Get-IAMRoleList @splat | Where-Object RoleName -Match $Pattern | Select-Object -EXP RoleName

            # THIS GETS ALL THE POLICIES FOR EACH ROLE AND CREATES A COLLECTION OF CUSTOM OBJECTS
            $policies = [System.Collections.Generic.List[System.Object]]::new()
            foreach ( $rn in $roleName ) {
                foreach ( $policy in (Get-IAMAttachedRolePolicies -RoleName $rn @splat) ) {
                    $new = [PSCustomObject] @{
                        RoleName   = $rn
                        PolicyName = $policy.PolicyName
                        PolicyArn  = $policy.PolicyArn
                    }
                    $policies.Add($new)
                }    
            }

            # THIS FINDS THE ROLE WITH THE MOST POLICIES AND PUTS THEM IN A HASHTABLE WITH THE ROLE NAME
            # AND HOW MANY POLICIES IT HAS
            $longest = @{ Name = 'default'; Count = 0 }
            foreach ( $i in ($policies | Sort-Object RoleName -Unique) ) {
                $count = ($policies | Where-Object RoleName -EQ $i.RoleName | Measure-Object).Count
                if ( $count -gt $longest.Count ) { $longest['Name'] = $i.RoleName; $longest['Count'] = $count }
            }

            # THIS IS WHERE THE MAGIC HAPPENS
            $results = [System.Collections.Generic.List[System.Object]]::new()
            for ($i = 0; $i -lt $longest['Count']; $i++) {
                $new = [PSCustomObject] @{
                    $roleName[0] = ($policies | Where-Object RoleName -EQ $roleName[0])[$i].PolicyName
                    $roleName[1] = ($policies | Where-Object RoleName -EQ $roleName[1])[$i].PolicyName
                    $roleName[2] = ($policies | Where-Object RoleName -EQ $roleName[2])[$i].PolicyName
                    $roleName[3] = ($policies | Where-Object RoleName -EQ $roleName[3])[$i].PolicyName
                }
                $results.Add($new)
            }

            $results | Export-Excel @excelParams -WorksheetName $splat['ProfileName']
        }
    }
}

# GET ROLE POLICIES
#Get-IAMRolePolicyList # THIS GETS IN-LINE POLICIES ONLY

<# # CREATE AN ARRAY OF POLICIES AS THE VALUE OF EACH ROLE AN OBJECT PROPERTY
$new = @{}
foreach ( $rn in $roleName ) {
    $role = Get-IAMRole -RoleName $rn @splat
    
    $policies = Get-IAMAttachedRolePolicies -RoleName $role.RoleName @splat
    
    $new[$role.RoleName] = $policies.PolicyName
}

[PSCustomObject] $new | Format-List #>

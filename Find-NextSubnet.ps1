function Find-NextSubnet {
    <# =========================================================================
    .SYNOPSIS
        Find next unused subnet
    .DESCRIPTION
        Find next unused subnet and return the second octet of the subnet CIDR range
    .PARAMETER ProfileName
        AWS Credential Profile Name
    .PARAMETER Region
        AWS Region
    .INPUTS
        None.
    .OUTPUTS
        System.Int32
    .EXAMPLE
        PS C:\> Find-NextSubnet -ProfileName $myProfile
        Returns the second octet of the next available subnet CIDR range
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string[]] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [string] $Region = 'us-east-1'
    )

    Begin {
        $vpcs = [System.Collections.Generic.List[Amazon.EC2.Model.Vpc]]::new()
        $subVal = [System.Collections.Generic.List[System.Int32]]::new()

        # GET NAME TAG
        $name = @{Name = 'Name'; Expression = { ($_.Tags | Where-Object Key -EQ Name).Value } }

        # EXCLUDE ALL DEFAULT VPC'S (172.31.0.0/16) AND SERVICES VPC
        $where = { $_.CidrBlock -notmatch '^172\.' }
    }

    Process {
        foreach ( $p in $ProfileName ) {
            foreach ( $vpc in (Get-EC2Vpc -ProfileName $p -Region $Region) ) {
                $vpcs.Add($vpc)
            }
        }

        $custVpcs = $vpcs | Where-Object $where | Select-Object -Property $name, CidrBlock

        # GET GREATEST SECOND OCTET
        foreach ( $range in $custVpcs.CidrBlock ) {
            $subVal.Add([int] ($range -replace '10\.(\d{1,3})(\.\d{1,3}){2}/16', '$1'))
        }

        # SORT SUBNET OCTET 2 FROM LOWEST TO HIGHEST
        $subVal = $subVal | Sort-Object

        $nextSubnet = $subVal[-1] + 1
        $nextSubnet
    }
}

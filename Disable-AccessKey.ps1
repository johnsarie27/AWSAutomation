function Disable-AccessKey {
    <# =========================================================================
    .SYNOPSIS
        Disable IAM User Access Key
    .DESCRIPTION
        Disable any IAM User Access Key that is older than 90 days.
    .PARAMETER UserName
        User name
    .PARAMETER ProfileName
        AWS Credential Profile name
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Disable-AccessKey -UserName jsmith -ProfileName MyAWSAccount
        Disable all access keys for jsmith that are older than 90 days in MyAWSAccount profile.
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage='User name')]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage='AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string[]] $ProfileName
    )

    Begin {
        # IMPORT AWS MODULE
        Import-Module -Name AWSPowerShell.NetCore

        # VALIDATE USERNAME
        if ( $UserName -notin (Get-IAMUserList).UserName ) {
            Write-Error ('User [{0}] not found.' -f $UserName); Break
        }

        # CREATE RESULTS ARRAY
        $Results = [System.Collections.Generic.List[PSObject]]::new()
    }

    Process {

        #LOOP ALL PROFILES
        foreach ( $PN in $ProfileName ) {
            
            # GET ACCESS KEYS
            $Keys = Get-IAMAccessKey -UserName $UserName -ProfileName $PN

            # LOOP THROUGH KEYS
            $Keys | ForEach-Object -Process {

                # CREATE TIMESPAN
                $Span = New-TimeSpan -Start $_.CreateDate -End (Get-Date)

                # IF KEY OLDER THAN 90 DAYS...
                if ( $Span.Days -ge 90 ) {
                    # REMOVE KEY
                    Remove-IAMAccessKey -AccessKeyId $_.AccessKeyId -ProfileName $PN

                    # DEACTIVATE KEY
                    #Update-IAMAccessKey -UserName $_.UserName -AccessKeyId $_.AccessKeyId -Status Inactive -ProfileName $ProfileName

                    # ADD KEY TO LIST
                    $Results.Add($_)
                }
            }
        }
    }

    End {
        Write-Output ('[{0}] keys disabled.' -f $Results.Count)

        # RETURN REVOKED KEYS
        Write-Information $Results
    }
}

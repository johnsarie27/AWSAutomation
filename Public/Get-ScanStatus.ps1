function Get-ScanStatus {
    <# =========================================================================
    .SYNOPSIS
        Get S3 Virus Scan Status
    .DESCRIPTION
        Get S3 Virus Scan Status
    .PARAMETER BucketName
        S3 Bucket Name
    .PARAMETER KeyPrefix
        Key prefix to filter bucket resutls
    .PARAMETER ProfileName
        AWS Credential Profile Name
    .PARAMETER Credential
        AWS Credential Object
    .INPUTS
        None.
    .OUTPUTS
        System.Object[].
    .EXAMPLE
        PS C:\> Get-ScanStatus -ProfileName myAcc -BucketName 'test-bucket-02340989' -KeyPrefix 'Docs'
        Search all S3 objects in folder 'Docs' of bucket 'test-bucket-02340989' for tags with value "infected"
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '_creds')]
    Param(
        [Parameter(Mandatory, HelpMessage = 'Bucket name')]
        [ValidateNotNullOrEmpty()]
        [string] $BucketName,

        [Parameter(HelpMessage = 'Key prefix')]
        [ValidateNotNullOrEmpty()]
        [string] $KeyPrefix,

        [Parameter(Mandatory, ParameterSetName = '_profile', HelpMessage = 'AWS Profile')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(Mandatory, ParameterSetName = '_creds', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential
    )

    Begin {
        # CONFIGURE CREDENTIALS AND ADD KEY PREFIX IF SPECIFIED
        $creds = @{ BucketName = $BucketName }
        if ( $PSBoundParameters.ContainsKey('KeyPrefix') ) { $creds.Add('KeyPrefix', $KeyPrefix) }
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $creds['ProfileName'] = $ProfileName }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $creds['Credential'] = $Credential }

        $objects = Get-S3Object @creds

        # REMOVE KEY PREFIX
        if ( $creds['KeyPrefix'] ) { $creds.Remove('KeyPrefix') }
    }

    Process {
        # LOOP THROUGH EACH S3 OBJECT
        foreach ( $i in $objects ) {

            $tags = Get-S3ObjectTagSet @creds -Key $i.Key

            # CHECK TAGS FOR 'INFECTED' AND RETURN OBJECT
            # SKIP ANY KEYS ENDING WITH "/"
            if ( $i.Key -notmatch '^.+\/$' ) {
                if ( $tags.Value -match 'infected' ) {
                    [PSCustomObject] @{ Status = 'INFECTED'; Key = $i.Key }
                }
                elseif ( $tags.Value -match 'clean' ) {
                    [PSCustomObject] @{ Status = 'CLEAN'; Key = $i.Key }
                }
                else {
                    [PSCustomObject] @{ Status = 'UNKNOWN'; Key = $i.Key }
                }
            }
        }
    }
}

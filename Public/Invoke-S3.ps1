#Requires -Modules AWS.Tools.S3

function Invoke-S3 {
    <# =========================================================================
    .SYNOPSIS
        Invoke S3 operation
    .DESCRIPTION
        Invoke S3 upload or download operation
    .PARAMETER ProfileName
        AWS Credential Profile Name
    .PARAMETER BucketName
        S3 Bucket Name
    .PARAMETER Path
        Local path for download or key prefix for upload
    .PARAMETER Folder
        Local folder to upload
    .PARAMETER File
        Local file to upload
    .PARAMETER KeyPrefix
        Object key prefix to download
    .PARAMETER Key
        Object key to download
    .INPUTS
        None.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> Invoke-S3 -Profile myProf -BucketName bucket123 -Key /Folder/Files/data.json -Path $HOME
        Downloads file data.json to the directory $HOME
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '__uploadFile')]
    Param(
        [Parameter(HelpMessage = 'AWS Profile')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory, HelpMessage = 'Bucket name')]
        [ValidateNotNullOrEmpty()]
        [string] $BucketName,

        [Parameter(Mandatory, HelpMessage = 'Local path for download or key prefix for upload')]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

        [Parameter(Mandatory, HelpMessage = 'Local folder to upload', ParameterSetName = '__uploadFolder')]
        [ValidateScript( { Test-Path -Path $_ -PathType Container })]
        [string] $Folder,

        [Parameter(Mandatory, HelpMessage = 'Local file to upload', ParameterSetName = '__uploadFile')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [string] $File,

        [Parameter(Mandatory, HelpMessage = 'S3 object key prefix to download', ParameterSetName = '__downloadFolder')]
        [ValidateNotNullOrEmpty()]
        [string] $KeyPrefix,

        [Parameter(Mandatory, HelpMessage = 'S3 object key to download', ParameterSetName = '__downloadFile')]
        [ValidateNotNullOrEmpty()]
        [string] $Key
    )

    Begin {
        # STAGE SPLATTER TABLE
        $s3Params = @{ BucketName  = $BucketName }

        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $s3Params['ProfileName'] = $ProfileName }
        elseif ( $PSBoundParameters.ContainsKey('Credential') ) { $s3Params['Credential'] = $Credential }
        else { Throw 'User not authorized.' }

        if ( $PSCmdlet.ParameterSetName -in @('__downloadFolder', '__downloadFile') ) {
            # CHECK FOR VALID DOWNLOAD PATH
            if ( -not (Test-Path -Path $Path) ) { Throw ('Invalid path: [{0}]' -f $Path) }

            # SET COMMAND TYPE
            $download = $true
        }
    }

    Process {
        # DETERMINE DESIRED SCENARIO AND SET SPLATTER TABLE PARAMS
        if ( $PSBoundParameters.ContainsKey('KeyPrefix') ) {
            $s3Params['KeyPrefix'] = $KeyPrefix
            $s3Params['Folder'] = Join-Path $Path -ChildPath $KeyPrefix
        }
        if ( $PSBoundParameters.ContainsKey('Key') ) {
            $s3Params['Key'] = $Key
            $s3Params['File'] = Join-Path $Path -ChildPath $Key
        }
        if ( $PSBoundParameters.ContainsKey('Folder') ) {
            $s3Params['Folder'] = $Folder
            $s3Params['KeyPrefix'] = Join-Path -Path $Path -ChildPath [System.IO.Path]::GetFileName($Folder)
        }
        if ( $PSBoundParameters.ContainsKey('File') ) {
            $s3Params['File'] = $File
            $s3Params['Key'] = Join-Path -Path $Path -ChildPath [System.IO.Path]::GetFileName($File)
        }

        # VERBOSE
        Write-Verbose -Message $s3Params.GetEnumerator()

        # PERFORM OPERATIONS
        if ( $download ) { Read-S3Object @s3Params }
        else { Write-S3Object @s3Params }
    }
}
#Requires -Modules AWS.Tools.S3

function Invoke-S3 {
    <# =========================================================================
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .PARAMETER abc
        Parameter description (if any)
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '__uploadFile')]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(Mandatory, HelpMessage = 'Bucket name')]
        [ValidateNotNullOrEmpty()]
        [string] $BucketName,

        [Parameter(Mandatory, HelpMessage = 'Local path for download or key prefix for upload')]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

        [Parameter(Mandatory, HelpMessage = 'Local folder', ParameterSetName = '__uploadFolder')]
        [ValidateScript( { Test-Path -Path $_ -PathType Container })]
        [string] $Folder,

        [Parameter(Mandatory, HelpMessage = 'Local folder', ParameterSetName = '__uploadFile')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [string] $File,

        [Parameter(Mandatory, HelpMessage = 'Bucket key prefix', ParameterSetName = '__downloadFolder')]
        [ValidateNotNullOrEmpty()]
        [string] $KeyPrefix,

        [Parameter(Mandatory, HelpMessage = 'Bucket key prefix', ParameterSetName = '__downloadFile')]
        [ValidateNotNullOrEmpty()]
        [string] $Key
    )

    Begin {

    }

    Process {
        $path = "$HOME\Downloads"
        #$path = "Folder\SubFolder" # KEY PREFIX FOR UPLOAD FILE/FOLDER

        # UPLOAD TO S3 RECURSIVELY
        $s3Params = @{
            ProfileName = 'esricloud'
            BucketName  = 's3-virus-scan-test'
            KeyPrefix   = "Data/NetworkDatasets/CompressedLicensed"
            #Key         = "Data/NetworkDatasets/CompressedLicensed/data.json"
            #Folder      = "$HOME\Downloads\Datasets"
            #File        = "$HOME\Downloads\Datasets\data.json"
        }
        $s3Params['Folder'] = Join-Path $path -ChildPath $s3Params['KeyPrefix']
        #$s3Params['File'] = Join-Path $path -ChildPath $s3Params['Key']
        #$s3Params['KeyPrefix'] = Join-Path -Path $path -ChildPath [System.IO.Path]::GetFileName($s3Params['Folder'])
        #$s3Params['Key'] = Join-Path -Path $path -ChildPath [System.IO.Path]::GetFileName($s3Params['File'])

        Read-S3Object @s3Params
        #Write-S3Object @s3Params
    }
}
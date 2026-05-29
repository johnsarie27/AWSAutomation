function Get-LatestImage {
    <#
    .SYNOPSIS
        Get latest image(s) for an EC2 instance
    .DESCRIPTION
        Get the latest image(s) for an EC2 instance from a specified number of days ago
    .PARAMETER NameTag
        EC2 Instance name tag value
    .PARAMETER BackupDays
        Backup days to output
    .PARAMETER ProfileName
        AWS Profile
    .PARAMETER Region
        AWS Region
    .INPUTS
        None.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-LatestImage @commonParams -NameTag 'MyInstance' -BackupDays 3
        Returns the latest image(s) for the instance 'MyInstance' from the last 3 days
    .NOTES
        Status: Stable
    #>
    [CmdletBinding()]
    [OutputType([Amazon.EC2.Model.Image])]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'EC2 Instance name tag value')]
        [ValidatePattern('^[\w-]+$')]
        [System.String] $NameTag,

        [Parameter(Mandatory = $false, HelpMessage = 'Backup days to output')]
        [ValidateRange(1, 90)]
        [System.Int32] $BackupDays = 3,

        [Parameter(Mandatory = $true, HelpMessage = 'AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, HelpMessage = 'AWS region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET CREDENTIALS
        $creds = @{ ProfileName = $ProfileName; Region = $Region }

        # OUTPUT VERBOSE
        Write-Verbose -Message ('Getting image(s) for instance [{0}] from:' -f $NameTag)
    }
    Process {
        # SET DATE VALUES ARRAY
        $dateVals = @()

        # LOOP THROUGH EACH DAY TILL TODAY
        for ($i = $BackupDays; $i -gt -1; $i--) {
            # OUTPUT VERBOSE
            Write-Verbose -Message ('{0:yyyy-MM-dd}*' -f (Get-Date).AddDays(-$i))

            # ADD DATE TO ARRAY
            $dateVals += ('{0:yyyy-MM-dd}*' -f (Get-Date).AddDays(-$i))
        }

        # SET FILTERS FOR AMI SEARCH
        $filters = @(
            @{ Name = 'tag:Name'; Values = $NameTag }
            @{ Name = 'creation-date'; Values = $dateVals }
        )

        # GET IMAGES FROM YESTERDAY
        Get-EC2Image @creds -Filter $filters | Sort-Object CreationDate -Descending

        # USE PROPERTY SET 'INFO' TO RETURN RELEVANT IMAGE PROPERTIES
    }
}
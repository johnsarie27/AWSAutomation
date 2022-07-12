function Update-CFNStackAMI {
    <# =========================================================================
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .PARAMETER Path
        Path to CloudFormation template file
    .PARAMETER OSVersion
        Windows OS version
    .PARAMETER Region
        AWS region
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .INPUTS
        None.
    .OUTPUTS
        Output (if any)
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .NOTES
        Name:     <Function Name>
        Author:   Justin Johns
        Version:  0.1.0 | Last Edit: 2022-07-11
        - <VersionNotes> (or remove this line if no version notes)
        Comments: <Comment(s)>
        General notes
    ========================================================================= #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = '__crd')]
    Param(
        [Parameter(Mandatory, Position = 0, HelpMessage = 'Path to CloudFormation template file')]
        [ValidateScript({ Test-Json -Json (Get-Content -Path $_ -Raw) })]
        [System.String] $Path,

        [Parameter(Mandatory, Position = 1, HelpMessage = 'Windows OS version')]
        [ValidateSet('Server2016', 'Server2019', 'Server2022')]
        [System.String] $OSVersion,

        [Parameter(Mandatory, Position = 2, HelpMessage = 'AWS Region')]
        [ValidateScript({ $_ -in (Get-AWSRegion).Region })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region,

        [Parameter(Mandatory, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory, ParameterSetName = '__pro', HelpMessage = 'AWS Profile object')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(HelpMessage = 'Proceed with changes without prompting for confirmation')]
        [System.Management.Automation.SwitchParameter] $Force
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET COMMON PARAMETERS
        $awsParams = @{ Region = $Region }
        switch ($PSCmdlet.ParameterSetName) {
            '__pro' { $awsParams['ProfileName'] = $ProfileName }
            '__crd' { $awsParams['Credential'] = $Credential }
        }
    }
    Process {

        if ($PSCmdlet.ShouldProcess($Path)) {
            # GET LATEST AMI
            $ami = Get-LatestAmi @awsParams -OSVersion $OSVersion

            # CONVERT TEMPLATE TO OBJECT
            $template = Get-Content -Path $Path | ConvertFrom-Json

            # SET AMI ID TO LATEST
            # THIS ASSUMES THAT THE REGION MAP USES "Baseline" AS THE IMAGE ID KEY
            if ($template.Mappings.RegionMap.$Region) {
                $template.Mappings.RegionMap.$Region.Baseline = $ami.ImageId
            }
            else {
                Throw ('Region: {0} not found in template' -f $Region)
            }

            # SAVE FILE
            if ($PSBoundParameters.ContainsKey('Force')) {
                Write-Verbose -Message ('"Force" parameter found. Overwriting file "{0}"' -f $Path)
                $template | ConvertTo-Json -Depth 12 | Set-Content -Path $Path -Confirm:$false
            }
            elseif ($PSCmdlet.ShouldContinue("Overwrite file ""$Path""?", 'Confirm')) {
                $template | ConvertTo-Json -Depth 12 | Set-Content -Path $Path -Confirm:$false
            }
        }
    }
}
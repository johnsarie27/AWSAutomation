function New-HealthCheck {
    <#
    .SYNOPSIS
        Create new Route53 Health Check
    .DESCRIPTION
        Create Route53 Health Check with set values and add "Name" tag
    .PARAMETER Name
        Health Check name (tag)
    .PARAMETER DNS
        Domain name
    .PARAMETER ResourcePath
        URI or resource path
    .PARAMETER Type
        Health Check type
    .PARAMETER SearchString
        Search string
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS Region
    .INPUTS
        None.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> New-HealthCheck
        Explanation of what the example does
    .NOTES
        Name:     New-HealthCheck
        Author:   Justin Johns
        Version:  0.1.1 | Last Edit: 2024-01-25
        - 0.1.1 - (2024-01-25) Added support for ShouldProcess
        - 0.1.0 - (2022-05-26) Initial version
        Comments: <Comment(s)>
        General notes
    #>
    [CmdletBinding(DefaultParameterSetName = '__crd', SupportsShouldProcess, ConfirmImpact = 'High')]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'Health Check name (tag)')]
        [ValidatePattern('^[\w-]+$')]
        [System.String] $Name,

        [Parameter(Mandatory = $true, HelpMessage = 'Domain name')]
        [ValidatePattern('^[\w\.-]+$')]
        [System.String] $DNS,

        [Parameter(Mandatory = $true, HelpMessage = 'URI or resource path')]
        [ValidateNotNullOrEmpty()]
        [System.String] $ResourcePath,

        [Parameter(Mandatory = $true, HelpMessage = 'Health Check type')]
        [ValidateSet('HTTPS', 'HTTPS_STR_MATCH')]
        [System.String] $Type,

        [Parameter(Mandatory = $false, HelpMessage = 'Search string')]
        [System.String] $SearchString,

        [Parameter(Mandatory = $true, ParameterSetName = '__pro', HelpMessage = 'AWS Profile object')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory = $true, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory = $true, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET CREDENTIALS
        if ($PSCmdlet.ParameterSetName -EQ '__pro') {
            $awsCreds = @{ ProfileName = $ProfileName; Region = $Region }
        }
        elseif ($PSCmdlet.ParameterSetName -EQ '__crd') {
            $awsCreds = @{ Credential = $Credential; Region = $Region }
        }

        # VALIDATE SEARCH STRING
        if ($Type -EQ 'HTTPS_STR_MATCH' -AND -NOT $PSBoundParameters.ContainsKey('SearchString')) {
            Throw 'No SearchString found. Health check type String Match must contain string.'
        }
    }
    Process {

        # SET HEALTH CHECK PARAMETERS
        $newHcParams = @{
            CallerReference                            = (New-Guid).Guid
            HealthCheckConfig_EnableSNI                = $true
            HealthCheckConfig_FailureThreshold         = 3
            HealthCheckConfig_FullyQualifiedDomainName = $DNS
            HealthCheckConfig_Port                     = 443
            HealthCheckConfig_RequestInterval          = 30 # ONLY 10 OR 30 VALID
            HealthCheckConfig_ResourcePath             = $ResourcePath
            HealthCheckConfig_Type                     = $Type
            HealthCheckConfig_Region                   = @('us-east-1', 'us-west-1', 'us-west-2')
            Select                                     = '*'
            ErrorAction                                = 1 # Stop
            #AlarmIdentifier_Name                       = ''
            #HealthCheckConfig_SearchString             = # COMMENT OUT FOR HTTPS
            #HealthCheckConfig_Disabled                 = $false
            #HealthCheckConfig_Inverted                 = $false
            #HealthCheckConfig_MeasureLatency           = $false
            #HealthCheckConfig_HealthThreshold          = 0 # FOR CALCULATED HEALTH CHECKS ONLY
        }

        # SET SEARCH STRING
        if ($Type -EQ 'HTTPS_STR_MATCH') {
            $newHcParams['HealthCheckConfig_SearchString'] = $SearchString
        }

        # SHOULD PROCESS
        if ($PSCmdlet.ShouldProcess($Name, "Create new Route53 Health Check")) {

            # CREATE NEW HEALTCH CHECK
            $newHC = New-R53HealthCheck @newHcParams @awsCreds
        }

        # GET EXISTING TAGS
        #Get-R53TagsForResource -ResourceId $newHC.HealthCheck.Id -ResourceType 'healthcheck' @awsCreds

        # CREATE NAME FOR HEALTH CHECK
        $tagParams = @{
            ResourceId   = $newHC.HealthCheck.Id
            ResourceType = 'healthcheck'
            AddTag       = @{ Key = 'Name'; Value = $Name }
            Select       = '*'
            ErrorAction  = 1 # STOP
        }
        Edit-R53TagsForResource @tagParams @awsCreds
    }
}
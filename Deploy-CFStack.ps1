function Deploy-CFStack {
    <# =========================================================================
    .SYNOPSIS
        Deploy CloudFomration Stack
    .DESCRIPTION
        Deploy CloudFomration Stack
    .PARAMETER StackName
        CloudFormation Stack Name
    .PARAMETER TemplateURL
        URL to existing CloudFormation Stack
    .PARAMETER ProfileName
        AWS Credential Profie with key and secret
    .PARAMETER StackParams
        CloudFormation Stack Parameters
    .PARAMETER Region
        AWS Region
    .INPUTS
        None.
    .OUTPUTS
        System.String.
    .EXAMPLE
        PS C:\> Deploy-CFStack -StackName myVpc -TemplateURL https://path.template -ProfileName myAccount`
                -StackParams @{ pVpcCIDR = '172.16.0.0/16'; pVpcName = 'myNewVpc' }
        Creates a new CloudFormation Stack using template path.template and parameters "pVpcCIDR" and pVpcName
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'CloudFormation Stack Name')]
        [string] $StackName,

        [Parameter(Mandatory, HelpMessage = 'URL to existing CloudFormation Stack')]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string] $TemplateURL,

        [Parameter(Mandatory, HelpMessage = 'AWS Credential Profie with key and secret')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(Mandatory, HelpMessage = 'CloudFormation Stack Parameters')]
        [hashtable] $StackParams,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1', 'us-east-2', 'us-west-1', 'us-west-2')]
        [string] $Region = 'us-east-1'
    )

    # CREATE NEW PARAMETER OBJECTS FROM PARAMETER NAMES AND VALUES
    $paramList = [System.Collections.Generic.List[Amazon.CloudFormation.Model.Parameter]]::new()
    foreach ( $p in $StackParams.Keys ) {
        $new = New-Object -TypeName Amazon.CloudFormation.Model.Parameter
        $new.ParameterKey = $p ; $new.ParameterValue = $StackParams[$p]
        $paramList.Add($new)
    }

    # DEPLOY CLOUDFORMATION STACK
    $newStackParams = @{
        ProfileName = $ProfileName
        Region      = $Region
        StackName   = $StackName
        TemplateURL = $TemplateURL
        Parameter   = $paramList
    }
    New-CFNStack @newStackParams
}

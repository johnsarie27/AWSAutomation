function Edit-AWSProfile {
    <# =========================================================================
    .SYNOPSIS
        Manage AWS Credential Profiles
    .DESCRIPTION
        Allows for managemnt of AWS Profile Credentials by prompting the user
        for the necessary information to perform an initialization task.
        Profiles can be created, updated, set as default, or removed.
    .PARAMETER List
        List profiles
    .PARAMETER Create
        Create new profile
    .PARAMETER Update
        Update existing profile
    .PARAMETER Delete
        Remove existing profile
    .PARAMETER Default
        Set profile as default
    .PARAMETER Region
        Set AWS Region
    .PARAMETER ProfileName
        Profile name
    .INPUTS
        System.String.
    .OUTPUTS
        System.String.
    .EXAMPLE
        PS C:\> Edit-AWSProfile -List
        Display all existing profiles
    .EXAMPLE
        PS C:\> Edit-AWSProfile -Create -ProfileName MyProfile
        Create new profile named MyProfile
    .EXAMPLE
        PS C:\> Edit-AWSProfile -Update -ProfileName Profile1
        Update existing profile Profile1
    .LINK
        https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html#pstools-cred-provider-chain
    .NOTES
        Using "-AsSecureString" prevents from copy and past when running the script
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ParameterSetName = '_list', HelpMessage = 'List profiles')]
        [switch] $List,

        [Parameter(Mandatory, ParameterSetName = '_create', HelpMessage = 'Create new profile')]
        [Parameter(Mandatory, ParameterSetName = '_create_default', HelpMessage = 'Create new profile')]
        [switch] $Create,

        [Parameter(Mandatory, ParameterSetName = '_update', HelpMessage = 'Update existing profile')]
        [Parameter(Mandatory, ParameterSetName = '_update_default', HelpMessage = 'Update existing profile')]
        [switch] $Update,

        [Parameter(Mandatory, ParameterSetName = '_delete', HelpMessage = 'Remove existing profile')]
        [switch] $Delete,

        [Parameter(Mandatory, ParameterSetName = '_create_default', HelpMessage = 'Set profile as default')]
        [Parameter(Mandatory, ParameterSetName = '_update_default', HelpMessage = 'Set profile as default')]
        [switch] $Default,

        [Parameter(Mandatory, ParameterSetName = '_create_default', HelpMessage = 'Set AWS Region')]
        [Parameter(Mandatory, ParameterSetName = '_update_default', HelpMessage = 'Set AWS Region')]
        [ValidateSet('us-east-1', 'us-east-2', 'us-west-1' , 'us-west-2')]
        [string] $Region,

        [Parameter(ParameterSetName = '_create', HelpMessage = 'New profile name')]
        [Parameter(ParameterSetName = '_create_default', HelpMessage = 'New profile name')]
        [Parameter(Mandatory, ParameterSetName = '_delete', HelpMessage = 'Profile name')]
        [Parameter(Mandatory, ParameterSetName = '_update', HelpMessage = 'Profile name')]
        [Parameter(Mandatory, ParameterSetName = '_update_default', HelpMessage = 'Profile name')]
        [string] $ProfileName
    )

    Begin {
        # VARS
        $OpParams = @('Default', 'Region', 'ProfileName')

        # FUNCTIONS
        function Confirm-Profile ([string] $ProfileName) {
            $ProfileExists = (Get-AWSCredential -ListProfileDetail).ProfileName -contains $ProfileName
            Return $ProfileExists
        }

        function Read-Input ([string] $Prompt) {
            $UInput = Read-Host -Prompt $Prompt
            Return $UInput
        }
    }

    Process {

        $Result = switch ( $PSBoundParameters.Keys | Where-Object {$_ -notin $OpParams} ) {
            List {
                Get-AWSCredential -ListProfileDetail | Sort-Object ProfileName | Out-String
            }
            Create {
                if ( $PSBoundParameters.ContainsKey('ProfileName') ) {
                    if ( Confirm-Profile -ProfileName $ProfileName ) {
                        do {
                            Clear-Host
                            $ProfileName = Read-Input -Prompt 'Please enter a unique profile name'
                        } while ( Confirm-Profile -ProfileName $ProfileName )
                    }
                }
                else {
                    $ProfileName = Read-Input -Prompt 'Profile name'
                    if ( Confirm-Profile -ProfileName $ProfileName ) {
                        do {
                            Clear-Host
                            $ProfileName = Read-Input -Prompt 'Please enter a unique profile name'
                        } while ( Confirm-Profile -ProfileName $ProfileName )
                    }
                }

                Write-Output `n
                $AccessKey = Read-Host -Prompt 'Access Key'
                $SecretKey = Read-Host -Prompt 'Secret Key'
                Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs $ProfileName
                if ( $PSBoundParameters.ContainsKey('Default') ) {
                    Initialize-AWSDefaultConfiguration -ProfileName $ProfileName -Region $Region
                }

                'Profile [{0}] created.' -f $ProfileName
            }
            Update {
                if ( !(Confirm-Profile -ProfileName $ProfileName) ) { Write-Error ('Profile [{0}] not found' -f $ProfileName); Break }

                Write-Output `n
                $AccessKey = Read-Host -Prompt 'Access Key'
                $SecretKey = Read-Host -Prompt 'Secret Key'
                Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs $ProfileName
                if ( $PSBoundParameters.ContainsKey('Default') ) {
                    Initialize-AWSDefaultConfiguration -ProfileName $ProfileName -Region $Region
                }

                'Profile [{0}] updated.' -f $ProfileName
            }
            Delete {
                if ( !(Confirm-Profile -ProfileName $ProfileName) ) { Write-Error ('Profile [{0}] not found' -f $ProfileName); Break }
                Remove-AWSCredentialProfile -ProfileName $ProfileName
                'Profile [{0}] removed.' -f $ProfileName
            }
        }
    }

    End {
        if ( $PSBoundParameters.ContainsKey('List') ) { Write-Output $Result }
        else { Write-Output $Result `n }
    }
}
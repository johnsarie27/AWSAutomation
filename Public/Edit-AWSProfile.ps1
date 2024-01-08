function Edit-AWSProfile {
    <#
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
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ParameterSetName = '_list', HelpMessage = 'List profiles')]
        [System.Management.Automation.SwitchParameter] $List,

        [Parameter(Mandatory, ParameterSetName = '_create', HelpMessage = 'Create new profile')]
        [Parameter(Mandatory, ParameterSetName = '_create_default', HelpMessage = 'Create new profile')]
        [System.Management.Automation.SwitchParameter] $Create,

        [Parameter(Mandatory, ParameterSetName = '_update', HelpMessage = 'Update existing profile')]
        [Parameter(Mandatory, ParameterSetName = '_update_default', HelpMessage = 'Update existing profile')]
        [System.Management.Automation.SwitchParameter] $Update,

        [Parameter(Mandatory, ParameterSetName = '_delete', HelpMessage = 'Remove existing profile')]
        [System.Management.Automation.SwitchParameter] $Delete,

        [Parameter(Mandatory, ParameterSetName = '_create_default', HelpMessage = 'Set profile as default')]
        [Parameter(Mandatory, ParameterSetName = '_update_default', HelpMessage = 'Set profile as default')]
        [System.Management.Automation.SwitchParameter] $Default,

        [Parameter(Mandatory, ParameterSetName = '_create_default', HelpMessage = 'Set AWS Region')]
        [Parameter(Mandatory, ParameterSetName = '_update_default', HelpMessage = 'Set AWS Region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region,

        [Parameter(Mandatory, ParameterSetName = '_create', HelpMessage = 'Profile name')]
        [Parameter(Mandatory, ParameterSetName = '_create_default', HelpMessage = 'Profile name')]
        [Parameter(Mandatory, ParameterSetName = '_delete', HelpMessage = 'Profile name')]
        [Parameter(Mandatory, ParameterSetName = '_update', HelpMessage = 'Profile name')]
        [Parameter(Mandatory, ParameterSetName = '_update_default', HelpMessage = 'Profile name')]
        [System.String] $ProfileName
    )
    Begin {
        # OPERATIONAL PARAMETERS
        $OpParams = @('Default', 'Region', 'ProfileName')

        # HELPER FUNCTION
        function Confirm-Profile ([string] $ProfileName) {
            $ProfileExists = (Get-AWSCredential -ListProfileDetail).ProfileName -contains $ProfileName
            Return $ProfileExists
        }
    }
    Process {
        # SWITCH ON PARAMETER ARGUMENTS
        $Result = switch ($PSBoundParameters.Keys | Where-Object {$_ -notin $OpParams}) {
            List {
                # RETURN ARRAY OF AWS CREDENTIAL PROFILES
                Get-AWSCredential -ListProfileDetail | Sort-Object ProfileName | Out-String
            }
            Create {
                if ($PSBoundParameters.ContainsKey('ProfileName')) {
                    if ( Confirm-Profile -ProfileName $ProfileName ) {
                        do {
                            Clear-Host
                            $ProfileName = Read-Host -Prompt 'Please enter a unique profile name'
                        } while (Confirm-Profile -ProfileName $ProfileName)
                    }
                }
                else {
                    $ProfileName = Read-Host -Prompt 'Profile name'
                    if (Confirm-Profile -ProfileName $ProfileName) {
                        do {
                            Clear-Host
                            $ProfileName = Read-Host -Prompt 'Please enter a unique profile name'
                        } while (Confirm-Profile -ProfileName $ProfileName)
                    }
                }

                # PROMPT FOR KEYS
                Write-Output -InputObject `n
                $AccessKey = Read-Host -Prompt 'Access Key'
                $SecretKey = Read-Host -Prompt 'Secret Key' -MaskInput

                # CREATE NEW CREDENTIAL PROFILE
                Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs $ProfileName

                # SET NEW PROFILE AS DEFAULT IF SWITCH PARAMETER DETECTED
                if ($PSBoundParameters.ContainsKey('Default')) {
                    Initialize-AWSDefaultConfiguration -ProfileName $ProfileName -Region $Region
                }

                # RETURN TEXT RESULT
                'Profile [{0}] created.' -f $ProfileName
            }
            Update {
                if (-Not (Confirm-Profile -ProfileName $ProfileName)) {
                    Write-Error -Message ('Profile [{0}] not found' -f $ProfileName); Break
                }

                # PROMPT FOR KEYS
                Write-Output -InputObject `n
                $AccessKey = Read-Host -Prompt 'Access Key'
                $SecretKey = Read-Host -Prompt 'Secret Key' -MaskInput

                # UPDATE CREDENTIAL PROFILE WITH NEW KEYS
                Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs $ProfileName

                # SET AS DEFAULT PROFILE
                if ($PSBoundParameters.ContainsKey('Default')) {
                    Initialize-AWSDefaultConfiguration -ProfileName $ProfileName -Region $Region
                }

                # RETURN TEXT RESULT
                'Profile [{0}] updated.' -f $ProfileName
            }
            Delete {
                if (-Not (Confirm-Profile -ProfileName $ProfileName)) {
                    Write-Error -Message ('Profile [{0}] not found' -f $ProfileName); Break
                }

                Remove-AWSCredentialProfile -ProfileName $ProfileName

                # RETURN TEXT RESULT
                'Profile [{0}] removed.' -f $ProfileName
            }
        }
    }
    End {
        if ($PSBoundParameters.ContainsKey('List')) {
            Write-Output -InputObject $Result
        }
        else {
            Write-Output -InputObject $Result, `n
        }
    }
}
﻿# ==============================================================================
# Module manifest for module 'AWSAutomation'
# Generated by: Justin Johns
# Generated on: 3/23/2018
# ==============================================================================

@{
    # Script module or binary module file associated with this manifest.
    RootModule        = 'AWSAutomation.psm1'

    # Version number of this module.
    ModuleVersion     = '0.8.10'

    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID              = 'a3b8f9d3-ac13-425b-a0bc-59d5463cc6af'

    # Author of this module
    Author            = 'Justin Johns'

    # Company or vendor of this module
    # CompanyName     = 'Unknown'

    # Copyright statement for this module
    Copyright         = '(c) 2018 Justin Johns. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Functions used for reporting on AWS resources and configurations including some to create CloudFormation templates from existing AWS infrastructure'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules   = @(
        'ImportExcel'
        #'AWSPowerShell'
        'AWS.Tools.Common'
        'AWS.Tools.CloudFormation'
        #'AWS.Tools.CloudFront'
        'AWS.Tools.CloudWatch'
        'AWS.Tools.EC2'
        'AWS.Tools.ElasticLoadBalancingV2'
        'AWS.Tools.IdentityManagement'
        'AWS.Tools.KeyManagementService'
        'AWS.Tools.RDS'
        'AWS.Tools.Route53'
        'AWS.Tools.S3'
        'AWS.Tools.SimpleSystemsManagement'
        'AWS.Tools.SecurityToken'
        'AWS.Tools.SSO'
        'AWS.Tools.SSOOIDC'
    )

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @('EC2Instance.ps1')

    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @(
        './Private/Certificate.types.ps1xml'
        './Private/EBS.types.ps1xml'
        './Private/EC2.types.ps1xml'
        './Private/ELB.types.ps1xml'
        './Private/ELB2.types.ps1xml'
        './Private/ELB2.Listener.types.ps1xml'
        './Private/Snapshot.types.ps1xml'
        './Private/SSM.types.ps1xml'
        './Private/Volume.types.ps1xml'
    )

    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = @(
        'ConvertFrom-CFLog'
        'ConvertFrom-ELBLog'
        'ConvertTo-CFStackParam'
        'Copy-EC2Instance'
        'Edit-AWSProfile'
        'Export-CFNStackDrift'
        'Export-EC2UsageReport'
        'Export-IAMRolePolicy'
        'Export-SECSecret'
        'Find-InsecureS3BucketPolicy'
        'Find-NextSubnet'
        'Find-PublicS3Object'
        'Get-AssociationStatus'
        'Get-CertificateReport'
        'Get-IAMReport'
        'Get-Instance'
        'Get-LoadBalancer'
        'Get-NetworkInfo'
        'Get-PatchInfo'
        'Get-RoleCredential'
        'Get-R53Record'
        'Get-S3Report'
        'Get-S3Url'
        'Get-ScanStatus'
        'Get-SecurityGroupInfo'
        'Get-SSMInstance'
        'Get-SSMNonCompliance'
        'Get-WindowsDisk'
        'Invoke-SSMRunCommand'
        'New-CWRecoveryAlarm'
        'New-HealthCheck'
        'New-HealthCheckAlarm'
        'Set-AwsSsoCredential'
        'Update-CFNStackAMI'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport   = @()

    # Variables to export from this module
    VariablesToExport = @(
        #'RegionTable'
        #'IllegalChars'
        'AlphabetList'
        'VolumeLookupTable'
    )

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport   = @(
        'Get-AwsCreds'
    )

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/johnsarie27/AWSAutomation'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI       = 'https://github.com/johnsarie27/AWSAutomation'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}
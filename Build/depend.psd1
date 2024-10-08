@{
    # Defaults for all dependencies
    PSDependOptions  = @{
        Target     = 'CurrentUser'
        Parameters = @{
            # Use a local repository for offline support
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }

    }

    # Dependency Management modules
    # PackageManagement = '1.2.2'
    # PowerShellGet     = '2.0.1'

    # Common modules
    BuildHelpers                        = '2.0.16'
    Pester                              = '5.6.1'
    PlatyPS                             = '0.14.2'
    psake                               = '4.9.0'
    #PSDeploy         = '1.0.5'
    PSScriptAnalyzer                    = '1.22.0'
    # REQUIRED FOR THIS SPECIFIC MODULE
    ImportExcel                         = '7.8.9'
    'AWS.Tools.Common'                  = '4.1.666'
    'AWS.Tools.CloudFormation'          = '4.1.666'
    'AWS.Tools.CloudWatch'              = '4.1.666'
    'AWS.Tools.EC2'                     = '4.1.666'
    'AWS.Tools.ElasticLoadBalancingV2'  = '4.1.666'
    'AWS.Tools.IdentityManagement'      = '4.1.666'
    'AWS.Tools.KeyManagementService'    = '4.1.666'
    'AWS.Tools.RDS'                     = '4.1.666'
    'AWS.Tools.Route53'                 = '4.1.666'
    'AWS.Tools.S3'                      = '4.1.666'
    'AWS.Tools.SimpleSystemsManagement' = '4.1.666'
    'AWS.Tools.SecurityToken'           = '4.1.666'
    'AWS.Tools.SSO'                     = '4.1.666'
    'AWS.Tools.SSOOIDC'                 = '4.1.666'
}

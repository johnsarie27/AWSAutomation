@{
    ExcludeRules = @(
        'PSAvoidGlobalVars'
        'PSAvoidUsingConvertToSecureStringWithPlainText'
        'PSUsePSCredentialType'
    )
    Severity     = @(
        'Warning',
        'Error'
    )
    Rules        = @{}
}

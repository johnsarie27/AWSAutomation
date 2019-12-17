# ==============================================================================
# Updated:      2019-12-16
# Created by:   Justin Johns
# Filename:     AWSAutomation.psm1
# Link:         https://github.com/johnsarie27/AWSAutomation
# ==============================================================================

# THIS IS NEEDED TO CREATE THE CONSTRUCTOR FOR EC2INSTANCE CLASS
#Requires -Modules AWS.Tools.EC2

# CFTEMPLATEBUILDER FUNCTIONS
. $PSScriptRoot\ConvertTo-SecurityGroupObject.ps1
. $PSScriptRoot\ConvertTo-VpcObject.ps1
. $PSScriptRoot\ConvertTo-SubnetObject.ps1
. $PSScriptRoot\ConvertTo-RouteTableObject.ps1
. $PSScriptRoot\Export-SecurityGroup.ps1
. $PSScriptRoot\New-ResourceObject.ps1

# IAM FUNCTIONS
. $PSScriptRoot\Edit-AWSProfile.ps1
. $PSScriptRoot\Get-IAMReport.ps1
. $PSScriptRoot\Revoke-StaleAccessKey.ps1
. $PSScriptRoot\Disable-InactiveUserKey.ps1
. $PSScriptRoot\Disable-InactiveUserProfile.ps1
. $PSScriptRoot\Export-IAMRolePolicy.ps1

# INVENTORY AND BUDGETARY FUNCTIONS
. $PSScriptRoot\Find-InsecureS3BucketPolicy.ps1
. $PSScriptRoot\Find-PublicS3Objects.ps1
. $PSScriptRoot\Get-SecurityGroupInfo.ps1
. $PSScriptRoot\Get-NetworkInfo.ps1
. $PSScriptRoot\Get-ELB.ps1
. $PSScriptRoot\Get-EC2.ps1
. $PSScriptRoot\Get-AvailableEBS.ps1
. $PSScriptRoot\Export-EC2UsageReport.ps1
. $PSScriptRoot\Export-AWSPriceData.ps1
. $PSScriptRoot\Remove-LapsedAMI.ps1
. $PSScriptRoot\Get-R53Record.ps1
. $PSScriptRoot\Copy-DBSnapshotToRegion.ps1
. $PSScriptRoot\Unregister-DBSnapshot.ps1
. $PSScriptRoot\Get-ScanStatus.ps1

# CREATION FUNCTIONS
. $PSScriptRoot\New-CWRecoveryAlarm.ps1
. $PSScriptRoot\Deploy-Instance.ps1
. $PSScriptRoot\Find-NextSubnet.ps1
. $PSScriptRoot\ConvertTo-CFStackParam.ps1
. $PSScriptRoot\New-Instance.ps1

# INTERNAL FUNCTIONS
. $PSScriptRoot\Get-CostInfo.ps1

# VARIABLES
$AlphabetList = 0..25 | ForEach-Object { [char](65 + $_) }

[int] $i = 0 ; $VolumeLookupTable = @{}
foreach ( $letter in $AlphabetList ) {
    $key = 'T' + $i.ToString("00") ; [string] $value = ('xvd' + $letter).ToLower()
    $VolumeLookupTable.Add( $key, $value ) ; $i++
}
$VolumeLookupTable.T00 = '/dev/sda1/'

# EXPORT MEMBERS
# EXPORTING IS SPECIFIED IN THE MODULE MANIFEST AND UNNECESSARY HERE
#Export-ModuleMember -Function *
#Export-ModuleMember -Variable *

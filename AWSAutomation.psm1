# ==============================================================================
# Filename: AWSAutomation.psm1
# Version:  0.1.1 | Updated: 2024-01-04
# Author:   Justin Johns
# ==============================================================================

# REQUIRED FOR THE CONSTRUCTOR OF EC2INSTANCE
# Requires -Modules AWS.Tools.EC2

# IMPORT ALL FUNCTIONS
foreach ( $directory in @('Public', 'Private') ) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object -Process { . $_.FullName }
}

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

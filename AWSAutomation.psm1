# ==============================================================================
# Filename: AWSAutomation.psm1
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

$VolumeLookupTable = @{}
for ($i = 0; $i -lt $AlphabetList.Count; $i++) {
    $key = 'T' + $i.ToString('00')
    [System.String] $value = ('xvd' + $AlphabetList[$i]).ToLower()
    $VolumeLookupTable.Add($key, $value)
}
$VolumeLookupTable.T00 = '/dev/sda1/'

# EXPORT MEMBERS
# FUNCTIONS ARE EXPORTED VIA THE MANIFEST; VARIABLES AND ALIASES ARE
# EXPORTED HERE SO THE MANIFEST'S VariablesToExport / AliasesToExport
# LISTS ARE HONORED REGARDLESS OF HOW THE MODULE IS LOADED.
Export-ModuleMember -Variable * -Alias *
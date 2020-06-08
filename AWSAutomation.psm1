# REQUIRED FOR THE CONSTRUCTOR OF EC2INSTANCE
#Requires -Modules AWS.Tools.EC2

# IMPORT ALL FUNCTIONS
foreach ( $directory in @('Public', 'Private') ) {
    Get-ChildItem -Path "$PSScriptRoot\$directory\*.ps1" | ForEach-Object -Process { . $_.FullName }
}

# CLASSES
class EC2Instance {
    [String] $Id
    [String] $Name
    [String] $Environment
    [String] $Type
    [String] $Reserved
    [String] $AZ
    [String] $PrivateIp
    [String] $PublicIp
    [String[]] $AllPrivateIps
    [String] $State
    [String] $DR_Region
    [DateTime] $LastStart
    [Int] $DaysStopped
    [Int] $DaysRunning
    [String] $Stopper
    [DateTime] $LastStopped
    [double] $OnDemandPrice
    [double] $ReservedPrice
    [string] $Savings
    [string] $ProfileName
    [string] $Region
    [bool] $IllegalName
    [string[]] $NameTags
    [string] $VpcId
    [string] $VpcName
    [string] $SubnetId
    [string] $SubnetName
    [string[]] $SecurityGroups

    # DEFAULT CONSTRUCTOR
    EC2Instance() { }

    # CUSTOM CONSTRUCTOR
    EC2Instance([Amazon.EC2.Model.Instance]$EC2) {
        $this.Id = $EC2.InstanceId
        $this.Name = ( $EC2.Tags | Where-Object Key -ceq Name ).Value
        $this.Environment = 'unknown'
        $this.Type = $EC2.InstanceType.Value
        $this.Reserved = ( $EC2.Tags | Where-Object Key -eq RI_Candidate ).Value
        $this.AZ = $EC2.Placement.AvailabilityZone
        $this.PrivateIP = $EC2.PrivateIpAddress
        $this.PublicIP = $EC2.PublicIpAddress
        $this.AllPrivateIps = $EC2.NetworkInterfaces.PrivateIpAddresses.PrivateIpAddress
        $this.State = $EC2.State.Name.Value
        $this.DR_Region = ( $EC2.Tags | Where-Object Key -eq DR_Region ).Value
        if ( $EC2.LaunchTime ) { $this.LastStart = $EC2.LaunchTime }
        $this.ProfileName = ""
        $this.Region = $EC2.Placement.AvailabilityZone.Remove($EC2.Placement.AvailabilityZone.Length - 1)
        $this.GetDaysRunning()
        $illegalChars = '(!|"|#|\$|%|&|''|\*|\+|,|:|;|\<|=|\>|\?|@|\[|\\|\]|\^|`|\{|\||\}|~)'
        if ( $this.Name -match $illegalChars ) { $this.IllegalName = $true }
        $this.NameTags = ($EC2.Tags | Where-Object Key -EQ name).Value
        $this.VpcId = $EC2.VpcId
        $this.SubnetId = $EC2.SubnetId
        $this.SecurityGroups = $EC2.SecurityGroups.GroupName
    }
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

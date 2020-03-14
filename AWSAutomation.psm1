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

    [string] ToString() { return ( "{0}" -f $this.Id ) }

    [void] GetEnvironment() {
        switch -Regex ($this.Name) {
            '^.*PRD.*$' { $this.Environment = 'Production' }
            '^.*STG.*$' { $this.Environment = 'Staging' }
            '^.*REF.*$' { $this.Environment = 'Reference' }
            default { $this.Environment = 'n/a' }
        }
    }

    [void] GetNetInfo($ProfileName, $Credential) {
        $creds = @{ Region = $this.Region }
        if ( $ProfileName ) { $creds['ProfileName'] = $ProfileName }
        if ( $Credential ) { $creds.Add('Credential', $Credential) }
        $this.VpcName = ((Get-EC2Vpc -VpcId $this.VpcId @creds).Tags | Where-Object Key -EQ Name).Value
        $this.SubnetName = ((Get-EC2Subnet -SubnetId $this.SubnetId @creds).Tags | Where-Object Key -eq Name).Value
    }

    [void] GetDaysRunning() {
        if ( $this.State -eq 'running' ) {
            $this.DaysRunning = (New-TimeSpan -Start $this.LastStart -End (Get-Date)).Days
        }
        else { $this.DaysRunning = 0 }
    }

    [void] GetStopInfo($ProfileName, $Credential) {
        $creds = @{ Region = $this.Region }
        if ( $ProfileName ) { $creds['ProfileName'] = $ProfileName }
        if ( $Credential ) { $creds.Add('Credential', $Credential) }
        if ( $this.State -eq 'stopped' ) {
            $event = Find-CTEvent @creds -LookupAttribute @{
                AttributeKey = "ResourceName"; AttributeValue = $this.Id
            } | Where-Object EventName -eq 'StopInstances' | Select-Object -First 1
            if ( $event ) {
                $this.LastStopped = $event.EventTime
                $this.Stopper = $event.Username
                $this.DaysStopped = (New-TimeSpan -Start $event.EventTime -End (Get-Date)).Days
            }
            else {
                $this.DaysStopped = 99 ; $this.Stopper = 'unknown'
            }
        }
        else {
            $this.Stopper = 'N/A'
        }
    }

    [void] GetCostInfo() {
        $regionTable = @{
            'us-east-1' = 'US East (N. Virginia)'
            'us-east-2' = 'US East (Ohio)'
            'us-west-1' = 'US West (N. California)'
            'us-west-2' = 'US West (Oregon)'
        }
        $dataFile = Export-AWSPriceData

        $priceInfo = Import-Csv -Path $dataFile | Where-Object Location -eq $regionTable[$this.Region]
        foreach ( $price in $priceInfo ) {
            if ( $price.'Instance Type' -eq $this.Type -and $price.TermType -eq 'OnDemand' -and $price.CapacityStatus -eq 'Used' ) {
                [double]$ODP = [math]::Round($price.PricePerUnit, 3)
                $this.OnDemandPrice = [math]::Round( $ODP * 24 * 365 )
            }

            if ( ( $this.Type -eq $price.'Instance Type' ) -and ( $price.TermType -eq 'Reserved' ) ) {
                $this.ReservedPrice = $price.PricePerUnit
            }
        }
        $this.Savings = ( 1 - ( $this.ReservedPrice / $this.OnDemandPrice ) ).ToString("P")
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

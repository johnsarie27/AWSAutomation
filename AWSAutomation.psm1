# ==============================================================================
# Updated:      2019-12-16
# Created by:   Justin Johns
# Filename:     AWSAutomation.psm1
# Link:         https://github.com/johnsarie27/AWSAutomation
# ==============================================================================

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

# CLASS
class EC2Instance {
    [String] $Id
    [String] $Name
    [String] $Environment
    [String] $Type
    [String] $Reserved
    [String] $AZ
    [String] $PrivateIp = $null
    [String] $PublicIp = $null
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
    [bool] $IllegalName = $false
    [string[]] $NameTags
    [string] $VpcId
    [string] $VpcName
    [string] $SubnetId
    [string] $SubnetName
    [string[]] $SecurityGroups

    # DEFAULT CONSTRUCTOR
    EC2Instance() {}

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
        $this.Region = ""
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

    [void] GetNetInfo($ProfileName, $Region) {
        $this.VpcName = ((Get-EC2Vpc -VpcId $this.VpcId -Region $Region -ProfileName $ProfileName).Tags | Where-Object Key -EQ Name).Value
        $this.SubnetName = ((Get-EC2Subnet -SubnetId $this.SubnetId -Region $Region -ProfileName $ProfileName).Tags | Where-Object Key -eq Name).Value
    }

    [void] GetDaysRunning() {
        if ( $this.State -eq 'running' ) {
            $this.DaysRunning = (New-TimeSpan -Start $this.LastStart -End (Get-Date)).Days
        } else { $this.DaysRunning = 0 }
    }

    [void] GetStopInfo() {
        if ( $this.State -eq 'stopped' ) {
            $event = Find-CTEvent -Region $this.Region -ProfileName $this.ProfileName -LookupAttribute @{
                AttributeKey = "ResourceName"; AttributeValue = $this.Id
                } | Where-Object EventName -eq 'StopInstances' | Select-Object -First 1
            if ( $event ) {
                $this.LastStopped = $event.EventTime
                $this.Stopper = $event.Username
                $this.DaysStopped = (New-TimeSpan -Start $event.EventTime -End (Get-Date)).Days
            } else {
                $this.DaysStopped = 99 ; $this.Stopper = 'unknown'
            }
        } else { $this.Stopper = '(running)' }
    }

    [void] GetCostInfo() {
        $RegionTable = @{
            'us-east-1' = 'US East (N. Virginia)'
            'us-east-2' = 'US East (Ohio)'
            'us-west-1' = 'US West (N. California)'
            'us-west-2' = 'US West (Oregon)'
        }
        $dataFile = Export-AWSPriceData

        $priceInfo = Import-Csv -Path $dataFile | Where-Object Location -eq $RegionTable[$this.Region]
        foreach ( $price in $priceInfo ) {
            if ( $price.'Instance Type' -eq $this.Type -and $price.TermType -eq 'OnDemand' -and $price.CapacityStatus -eq 'Used' ) {
                [double]$ODP = [math]::Round($price.PricePerUnit,3)
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
$RegionTable = @{
    'us-east-1' = 'US East (N. Virginia)'
    'us-east-2' = 'US East (Ohio)'
    'us-west-1' = 'US West (N. California)'
    'us-west-2' = 'US West (Oregon)'
}

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

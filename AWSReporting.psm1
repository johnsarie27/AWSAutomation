# ==============================================================================
# Updated:      2019-02-21
# Created by:   Justin Johns
# Filename:     AWSReporting.psm1
# Link:         https://github.com/johnsarie27/AWSReporting
# ==============================================================================

# CFTEMPLATEBUILDER FUNCTIONS
. $PSScriptRoot\ConvertTo-SecurityGroupObject.ps1
. $PSScriptRoot\ConvertTo-VpcObject.ps1
. $PSScriptRoot\ConvertTo-SubnetObject.ps1
. $PSScriptRoot\ConvertTo-RouteTableObject.ps1
. $PSScriptRoot\Export-SecurityGroup.ps1

# IMPORT
. $PSScriptRoot\Find-InsecureS3BucketPolicy.ps1
. $PSScriptRoot\Find-PublicS3Objects.ps1
. $PSScriptRoot\Get-SecurityGroupInfo.ps1
. $PSScriptRoot\Get-NetworkInfo.ps1
. $PSScriptRoot\Get-ELB.ps1
. $PSScriptRoot\Get-IAMReport.ps1

# FUNCTIONS
function Get-EC2 {
    <# =========================================================================
    .SYNOPSIS
        Get all EC2 instances for given list of accounts
    .DESCRIPTION
        This function returns a list of the EC2 instances in production or in
        all available AWS credential profiles.
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Region
        AWS region
    .PARAMETER All
        Use all locally stored AWS credential profiles
    .PARAMETER AWSPowerShell
        Return objects of type Amazon.EC2.Model.Reservation instead of custom
        objects
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> $All = Get-EC2 -Region us-west-2 -All
        Return all EC2 instances in all AWS accounts represented by the locally
        stored AWS credential profiles in the us-west-2 region.
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Profile containing access key and secret')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [Alias('Profile')]
        [string[]] $ProfileName,

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2')]
        [ValidateNotNullOrEmpty()]
        [string] $Region = 'us-east-1',

        [Parameter(HelpMessage = 'All Profiles')]
        [switch] $All,

        [Parameter(HelpMessage = 'Use AWSPowerShell module')]
        [switch] $AWSPowerShell
    )

    $Results = @()

    if ( $PSBoundParameters.ContainsKey('All') ) {
        $ProfileName = Get-AWSCredential -ListProfileDetail | Select-Object -EXP ProfileName
        if ( $PSBoundParameters.ContainsKey('AWSPowerShell') ) {
            foreach ( $PN in $ProfileName ) {
                $Results += (Get-EC2Instance -ProfileName $PN -Region $Region).Instances
            }
        } else { $Results = Get-InstanceList -ProfileName $ProfileName -Region $Region }
    } else {
        if ( $PSBoundParameters.ContainsKey('AWSPowerShell') ) {
            foreach ( $PN in $ProfileName ) {
                $Results += (Get-EC2Instance -ProfileName $PN -Region $Region).Instances
            }
        } else { $Results = Get-InstanceList -ProfileName $ProfileName -Region $Region }
    }

    $Results
}

function Get-AvailableEBS {
    <# =========================================================================
    .SYNOPSIS
        Get "unattached" Elastic Block Store volumes
    .DESCRIPTION
        This function returns a list of custom objects with properties from AWS
        EBS volume objects where each EBS volume is available (unattached).
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Region
        AWS region
    .PARAMETER AllProfiles
        Pull data from all available AWS Credential Profiles.
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-AvailableEBS -AllProfiles | Group -Property Account | Select Name, Count
        Get unattached EBS volumes, group them by Account, and display Name and Count
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = 'all')]
    Param(
        [Parameter(Mandatory, ParameterSetName = 'targeted', HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('Profile', 'Name')]
        [string[]] $ProfileName,

        [Parameter(HelpMessage = 'Name of desired AWS Region.')]
        [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2')]
        [String] $Region = 'us-east-1',

        [Parameter(Mandatory, ParameterSetName = 'all', HelpMessage = 'All available AWS Credential Profiles')]
        [Alias('All')]
        [switch] $AllProfiles
    )

    # GET PROFILE LIST
    if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $ProfileList = $ProfileName }
    if ( $PSBoundParameters.ContainsKey('AllProfiles') ) {
        $ProfileList = Get-AWSCredential -ListProfileDetail | Select-Object -ExpandProperty ProfileName
    }

    $AllVolumes = @() ; $Date = Get-Date
    foreach ( $name in $ProfileList ) {
        # GET ALL AVAILABLE VOLUMES
        $VolumeList = Get-EC2Volume -Filter @{Name="status";Values="available"} -ProfileName $name -Region $Region

        foreach ( $volume in $VolumeList ) {
            # CREATE NEW OBJECT AND ADD PROPERTIES
            $New = New-Object -TypeName psobject
            $New | Add-Member -MemberType NoteProperty -Name Id -Value $volume.VolumeId
            $New | Add-Member -MemberType NoteProperty -Name Account -Value $name
            $New | Add-Member -MemberType NoteProperty -Name CreateTime -Value $volume.CreateTime
            $New | Add-Member -MemberType NoteProperty -Name Status -Value $volume.Status
            $New | Add-Member -MemberType NoteProperty -Name Encrypted -Value $volume.Encrypted
            $New | Add-Member -MemberType NoteProperty -Name AvailabilityZone -Value $volume.AvailabilityZone
            $New | Add-Member -MemberType NoteProperty -Name Iops -Value $volume.Iops
            if ( $volume.KmsKeyId ) { $Key = $volume.KmsKeyId } else { $Key = $null }
            $New | Add-Member -MemberType NoteProperty -Name KmsKeyId -Value $Key
            $New | Add-Member -MemberType NoteProperty -Name Size -Value $volume.Size
            $New | Add-Member -MemberType NoteProperty -Name SnapshotId -Value $volume.SnapshotId
            $New | Add-Member -MemberType NoteProperty -Name Tags -Value $volume.Tags
            $New | Add-Member -MemberType NoteProperty -Name VolumeType -Value $volume.VolumeType
            $Age = New-TimeSpan -Start $volume.CreateTime -End $Date
            $New | Add-Member -MemberType NoteProperty -Name AgeInDays -Value $Age.Days

            $AllVolumes += $New
        }

        # CLEAR LIST
        $VolumeList = $null
    }

    # RETURN LIST
    $AllVolumes
}

function New-QuarterlyReport {
    <# =========================================================================
    .SYNOPSIS
        Generate reports for instances offline and running without reservation
    .DESCRIPTION
        This script iterates through all instances in a give AWS Region and creates
        a list of specific attributes. It then finds the last stop time, user who
        stopped the instance, and calculates the number of days the system has been
        stopped (if possible) and creates a data sheet (CSV). The data sheet is then
        imported into Excel and formatted.  This can be done for a single or
        multiple accounts based on AWS Credentail Profiles.
    .PARAMETER ProfileName
        This is the name of the AWS Credential profile containing the Access Key and
        Secret Key.
    .PARAMETER Region
        This is the AWS region containing the desired resources to be processed
    .INPUTS
        System.String.
    .OUTPUTS
        Excel spreadsheet.
    .EXAMPLE
        PS C:\>New-QuarterlyReport -Region us-west-1 -ProfileName MyAccount
        Generate new EC2 report for all instances in MyAccount in the us-west-1
        region
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Credential Profie with key and secret')]
        [ValidateScript({(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('Profile', 'PN')]
        [string[]] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2')]
        [string] $Region = 'us-east-1'
    )

    Import-Module UtilityFunctions

    $XlsxFile = '{0}\{1}_AWS-Quarterly-Report.xlsx' -f (Get-Folder -Description 'Save folder'), (Get-Date).ToString("yyyy-MM-dd")

    $InstanceList = @()

    $InstanceList += Get-InstanceList -Region $Region -ProfileName $ProfileName
    foreach ( $instance in $InstanceList ) { $instance.GetStopInfo() }
    Get-CostInfo -Region $Region -InstanceList $InstanceList | Out-Null

    $90DayList = @( $InstanceList | Where-Object State -eq 'stopped' |
        Select-Object ProfileName, Id, Name, LastStart, LastStopped, DaysStopped, Stopper |
        Sort-Object DaysStopped )

    $60DayList = @( $InstanceList | Where-Object State -eq 'running' |
        Select-Object ProfileName, Name, Type, Reserved, LastStart, DaysRunning, OnDemandPrice, ReservedPrice, Savings |
        Sort-Object LastStart )

    $AllVolumes = Get-AvailableEBS -ProfileName $ProfileName | Group-Object -Property Account | Select-Object Name, Count

    $Splat = @{ SavePath = $XlsxFile; AutoSize = $true; Freeze = $true; SuppressOpen = $true }
    if ( $60DayList.Count -ge 1 ) { $60DayList | Export-ExcelBook @Splat -SheetName '60-Day Report' }
    $Splat.Remove('SavePath'); $Splat.Path = $XlsxFile
    if ( $90DayList.Count -gt 0 ) { $90DayList | Export-ExcelBook @Splat -SheetName '90-Day Report' }
    $Splat.Remove('SuppressOpen')
    if ( $AllVolumes ) { $AllVolumes | Export-ExcelBook @Splat -SheetName 'Unattached EBS' }
}

function New-ResourceObject {
    [CmdletBinding(DefaultParameterSetName = 'EIP')]
    Param(
        [Parameter(Mandatory, ParameterSetName = 'EIP', HelpMessage = 'Elastic IP')]
        [switch] $EIP,

        [Parameter(Mandatory, ParameterSetName = 'NGW', HelpMessage = 'NAT Gateway')]
        [switch] $NGW,

        [Parameter(Mandatory, ParameterSetName = 'IGW', HelpMessage = 'Internet Gateway')]
        [switch] $IGW,

        [Parameter(Mandatory, ParameterSetName = 'VGA', HelpMessage = 'VPC Gateway Attachment')]
        [switch] $VGA,

        [Parameter(HelpMessage = 'Value for name tag')]
        [ValidateScript({ $_ -match '[A-Z0-9-_]' })]
        [string] $NameTag,

        [Parameter(Mandatory, ParameterSetName = 'NGW', HelpMessage = 'Elast IP name')]
        [ValidateScript({ $_ -match '[A-Z0-9-_]' })]
        [string] $EipName,

        [Parameter(Mandatory, ParameterSetName = 'NGW', HelpMessage = 'Subnet name')]
        [ValidateScript({ $_ -match '[A-Z0-9-_]' })]
        [string] $SubnetName
    )

    $ParamSwitch = @('EIP', 'NGW', 'IGW', 'VGA')
    switch ( $PSBoundParameters.Keys | Where-Object { $_ -in $ParamSwitch } ) {
        'EIP' {
            $ResourceType = 'EIP'
            $Hash = @{ Domain = "vpc" }
        }
        'NGW' {
            $ResourceType = 'NatGateway'
            $Hash = @{
                AllocationId = [PSCustomObject] @{ "Fn::GetAtt" = @($EipName, "AllocationId") }
                SubnetId     = [PSCustomObject] @{ Ref = "$SubnetName" } 
            }    
        }
        'IGW' { $ResourceType = 'InternetGateway' }
        'VGA' {
            $ResourceType = 'VPCGatewayAttachment'
            $Hash = @{
                VpcId = [PSCustomObject] @{ Ref = "rVPC" }
                InternetGatewayId = [PSCustomObject] @{ Ref = "rInternetGateway" }
            }
        }
    }

    if ( $Hash -and $NameTag ) { $Hash.Tags = [PSCustomObject] @{ Key = "Name" ; Value = $NameTag } }
    if ( -not $Hash -and $NameTag ) { $Hash = @{ Tags = [PSCustomObject] @{ Key = "Name" ; Value = $NameTag } } }

    # ADD DATA VALUES AND OBJECTS
    $Object = [PSCustomObject] @{ Type = "AWS::EC2::$ResourceType" }
    if ( $Hash ) { $Properties = [PSCustomObject] $Hash }
    $Object | Add-Member -MemberType NoteProperty -Name "Properties" -Value $Properties

    # RETURN MASTER OBJECT
    $Object
}

# ******************** DEPRICATE? ********************
function Get-CostInfo {
    <# =========================================================================
    .DESCRIPTION
        This function looks for the presence of the price data csv file
        generated by Get-AWSPriceData and fills in values for the provided list of
        EC2 instances.
    .EXAMPLE
        PS C:\> Get-CostInfo
    .PARAMETER InstanceList
        blah
    .PARAMETER Region
        blah
    ========================================================================= #>
    Param(
        [System.Object[]] $InstanceList, # [EC2Instance[]]
        [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2')]
        [string] $Region
    )
    $DataFile = "$env:ProgramData\AWS\AmazonEC2_PriceData.csv"
    if ( -not ( Test-Path $DataFile ) ) { Get-AWSPriceData }

    $PriceInfo = Import-Csv -Path $DataFile | Where-Object Location -eq $RegionTable[$Region]
    foreach ( $instance in $InstanceList ) {
        foreach ( $price in $PriceInfo ) {
            if ( ( $instance.Type -eq $price.'Instance Type' ) -and ( $price.TermType -eq 'OnDemand' ) ) {
                [double]$ODP = [math]::Round($price.PricePerUnit,3)
                $instance.OnDemandPrice = [math]::Round( $ODP * 24 * 365 )
            }
            if ( ( $instance.Type -eq $price.'Instance Type' ) -and ( $price.TermType -eq 'Reserved' ) ) {
                $instance.ReservedPrice = $price.PricePerUnit
            }
        }
        $instance.Savings = ( 1 - ( $instance.ReservedPrice / $instance.OnDemandPrice ) ).ToString("P")
    }
    $InstanceList
}
# ******************** DEPRICATE? ********************

function Get-InstanceList {
    <# =========================================================================
    .SYNOPSIS
        Get list of EC2 instances
    .DESCRIPTION
        This function queries AWS EC2 API for all instances in a given region
        for a given account. It requires an AWS Credential Profile and uses a
        custom class to store the data.
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Region
        AWS region
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-InstanceList -Region us-east-1 -ProfileName MyAccount
        Get a list of all EC2 instances in the AWS account represented by
        MyAccount in the us-east-1 region
    ========================================================================= #>
    [Alias('gil')]
    Param(
        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Profile containing access key and secret')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [Alias('Profile')]
        [string[]] $ProfileName,

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2')]
        [ValidateNotNullOrEmpty()]
        [string] $Region = 'us-east-1'
    )

    $IllegalChars = '(!|"|#|\$|%|&|''|\*|\+|,|:|;|\<|=|\>|\?|@|\[|\\|\]|\^|`|\{|\||\}|~)'

    if ( -not $PSBoundParameters.ContainsKey('ProfileName') ) {
        $ProfileName = Get-AWSCredential -ListProfileDetail | Select-Object -EXP ProfileName
    }

    $InstanceList = @()
    foreach ( $Name in $ProfileName ) {
        # GET ALL INSTANCES
        $EC2Instances = (Get-EC2Instance -ProfileName $Name -Region $Region).Instances

        # CREATE NEW OBJECTS
        foreach ( $ec2 in $EC2Instances ) {
            $new = New-Object EC2Instance #-TypeName EC2Instance
            $new.DR_Region = ( $ec2.Tags | Where-Object Key -eq DR_Region ).Value
            $new.Id = $ec2.InstanceId
            $new.Name = ( $ec2.Tags | Where-Object Key -ceq Name ).Value
            $new.Type = $ec2.InstanceType.Value
            $new.Reserved = ( $ec2.Tags | Where-Object Key -eq RI_Candidate ).Value
            $new.AZ = $ec2.Placement.AvailabilityZone
            $new.PrivateIP = $ec2.PrivateIpAddress
            $new.PublicIP = $ec2.PublicIpAddress
            $new.AllPrivateIps = $ec2.NetworkInterfaces.PrivateIpAddresses.PrivateIpAddress
            $new.State = $ec2.State.Name.Value
            if ( $ec2.LaunchTime ) { $new.LastStart = $ec2.LaunchTime }
            $new.ProfileName = $Name
            $new.Region = $Region
            $new.GetDaysRunning()
            if ( $new.Name -match $IllegalChars ) { $new.IllegalName = $true }
            $new.NameTags = $ec2.Tags | Where-Object Key -EQ name | Select-Object -EXP Value
            $new.VpcId = $ec2.VpcId
            $new.SubnetId = $ec2.SubnetId
            $new.SecurityGroups = $ec2.SecurityGroups.GroupName
            $InstanceList += $new
        }
    }

    $InstanceList | Sort-Object -Property Name
}

function Get-AWSPriceData {
    <# =========================================================================
    .SYNOPSIS
        Get price data for EC2 resources
    .DESCRIPTION
        This function retrieves the EC2 price data for AWS us-east-1 region and
        returns a CSV file with the relevant data.
    .PARAMETER OfferCode
        Offer code for price object resources. Only AmazonEC2 supported at this time
    .PARAMETER Format
        Output format of resulting file. Only CSV supported at this time
    .INPUTS
        System.String.
    .OUTPUTS
        CSV file.
    .EXAMPLE
        PS C:\> GetPriceInfo -Region us-west-2
    .NOTES
        https://aws.amazon.com/blogs/aws/new-aws-price-list-api/
        https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/{offer_code}/current/index.{format}
        https://blogs.technet.microsoft.com/heyscriptingguy/2015/01/30/powertip-use-powershell-to-round-to-specific-decimal-place/
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage='AWS offer code')]
        [ValidateSet({'AmazonEC2'})]
        [string] $OfferCode = 'AmazonEC2',

        [Parameter(HelpMessage = 'Output format')]
        [ValidateSet('.csv')]
        [Alias('Output')]
        [string] $Format = '.csv'
    )

    # SET VARS
    $URL = "https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/{0}/current/index{1}" -f $OfferCode, $Format
    $DataFile = '{0}\{1}_Raw{2}' -f $env:TEMP, $OfferCode, $Format

    # DOWNLOAD RAW DATA
    $WC = New-Object System.Net.WebClient
    $WC.DownloadFile($URL, $DataFile)

    # GET DATA AND STRIP OUT HEADER INFO
    $TotalLines = (Get-Content -Path $DataFile | Measure-Object -Line).Lines
    $RawData = Import-Csv $DataFile -Tail ($TotalLines-5)

    # CULL DOWN TO RELEVANT DATA FOR ALL US REGIONS
    $Output = '{0}\AWS\{1}_PriceData{2}' -f $env:ProgramData, $OfferCode, $Format
    $RawData | Where-Object {
        (
            $_.Location -eq 'US East (N. Virginia)' -or `
            $_.Location -eq 'US East (Ohio)' -or `
            $_.Location -eq 'US West (N. California)' -or `
            $_.Location -eq 'US West (Oregon)'
        ) -and `
        $_.'Operating System' -eq 'Windows' -and `
        $_.Tenancy -eq 'Shared' -and `
        $_.'Pre Installed S/W' -eq 'NA' -and `
        $_.'License Model' -ne 'Bring your own license' -and `
        #$_.PriceDescription -notcontains 'BYOL' -and `
        (
            (
                $_.OfferingClass -eq 'standard' -and `
                $_.PurchaseOption -eq 'All Upfront' -and `
                $_.Unit -eq 'Quantity' -and `
                $_.LeaseContractLength -eq '1yr'  #*** EDIT/REMOVE THIS VALUE TO GET MORE INFO ***
            ) -or `
            $_.TermType -eq 'OnDemand'
        )
    } | Sort-Object -Property 'Instance Type' | Export-Csv $Output -NoTypeInformation

    # DELETE REMNANT ARTIFACTS
    Remove-Item -Path $DataFile -Force
}

# CLASS
class EC2Instance {
    [String] $Id
    [String] $Name
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

    <# 
    # DEFAULT CONSTRUCTOR
    EC2Instance() {}

    # CUSTOM CONSTRUCTOR
    EC2Instance([Amazon.EC2.Model.Instance] $EC2) {
        
        $this.DR_Region = ( $EC2.Tags | Where-Object Key -eq DR_Region ).Value
        $this.Id = $EC2.InstanceId
        $this.Name = ( $EC2.Tags | Where-Object Key -ceq Name ).Value
        $this.Type = $EC2.InstanceType.Value
        $this.Reserved = ( $EC2.Tags | Where-Object Key -eq RI_Candidate ).Value
        $this.AZ = $EC2.Placement.AvailabilityZone
        $this.PrivateIP = $EC2.PrivateIpAddress
        $this.PublicIP = $EC2.PublicIpAddress
        $this.AllPrivateIps = $EC2.NetworkInterfaces.PrivateIpAddresses.PrivateIpAddress
        $this.State = $EC2.State.Name.Value
        if ( $EC2.LaunchTime ) { $this.LastStart = $EC2.LaunchTime }
        $this.ProfileName = ""
        $this.Region = ""
        $this.GetDaysRunning()
        $IllegalChars = '(!|"|#|\$|%|&|''|\*|\+|,|:|;|\<|=|\>|\?|@|\[|\\|\]|\^|`|\{|\||\}|~)'
        if ( $this.Name -match $IllegalChars ) { $this.IllegalName = $true }
        $this.NameTags = $EC2.Tags | Where-Object Key -EQ name | Select-Object -EXP Value
        $this.VpcId = $EC2.VpcId
        $this.SubnetId = $EC2.SubnetId
        $this.SecurityGroups = $EC2.SecurityGroups.GroupName
        
    }
    #>

    [string] ToString() { return ( "{0}" -f $this.Id ) }

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
        $DataFile = "$env:ProgramData\AWS\AmazonEC2_PriceData.csv"
        if ( -not ( Test-Path $DataFile ) ) { Get-AWSPriceData }

        $PriceInfo = Import-Csv -Path $DataFile | Where-Object Location -eq $RegionTable[$this.Region]
        foreach ( $price in $PriceInfo ) {
            if ( ( $this.Type -eq $price.'Instance Type' ) -and ( $price.TermType -eq 'OnDemand' ) ) {
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

$IllegalChars = '(!|"|#|\$|%|&|''|\*|\+|,|:|;|\<|=|\>|\?|@|\[|\\|\]|\^|`|\{|\||\}|~)'

$AlphabetList = 0..25 | ForEach-Object { [char](65 + $_) }

[int] $i = 0 ; $VolumeLookupTable = @{}
foreach ( $letter in $AlphabetList ) {
    $key = 'T' + $i.ToString("00") ; [string] $value = ('xvd' + $letter).ToLower()
    $VolumeLookupTable.Add( $key, $value ) ; $i++
}
$VolumeLookupTable.T00 = '/dev/sda1/'

# EXPORT MEMBERS
# THESE ARE SPECIFIED IN THE MODULE MANIFEST AND THEREFORE DON'T NEED TO BE LISTED HERE
#Export-ModuleMember -Function *
#Export-ModuleMember -Variable *

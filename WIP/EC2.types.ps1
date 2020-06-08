# ==============================================================================
# Updated:      2020-06-06
# Created by:   Justin Johns
# Filename:     EC2.types.ps1
# Version:      0.0.2
# ==============================================================================

# NEW SCRIPT PROPERTIES
$propHash = @{
    Name          = { $this.Tags.Where( { $_.Key -ceq "Name" }).Value }
    Type          = { $this.InstanceType.Value }
    Reserved      = { $this.Tags.Where( { $_.Key -eq "RI_Candidate" }).Value }
    AZ            = { $this.Placement.AvailabilityZone }
    AllPrivateIps = { $this.NetworkInterfaces.PrivateIpAddresses.PrivateIpAddress }
    Status        = { $this.State.Name.Value }
    DRRegion      = { $this.Tags.Where( { $_.Key -eq "DR_Region" }).Value }
    Region        = { $this.Placement.AvailabilityZone.Remove($this.Placement.AvailabilityZone.Length - 1) }
    IllegalName   = { if ( $this.Name -match '(!|"|#|\$|%|&|''|\*|\+|,|:|;|\<|=|\>|\?|@|\[|\\|\]|\^|`|\{|\||\}|~)' ) { $true } else { $false } }
    Environment   = { switch -Regex ($this.Name) { '^.*PRD.*$' { 'Production' }; '^.*STG.*$' { 'Staging' }; '^.*REF.*$' { 'Reference' }; default { 'Unknown' } } }
    DaysRunning   = { if ( $this.Status -eq 'running' ) { (New-TimeSpan -Start $this.LastStart -End (Get-Date)).Days } else { 0 } }
}

$params = @{
    TypeName   = "Amazon.EC2.Model.Instance"
    MemberType = "ScriptProperty"
    MemberName = ""
    Value      = ""
    Force      = $true
}

$prophash.GetEnumerator() | ForEach-Object {
    $params['MemberName'] = $_.key
    $params['Value'] = $_.value
    Update-TypeData @params
}

# NEW ALIAS PROPERTIES
$params['MemberType'] = "AliasProperty"

$propHash = @{
    Id        = "InstanceId"
    PrivateIP = "PrivateIpAddress"
    PublicIP  = "PublicIpAddress"
    LastStart = "LaunchTime"
}

$prophash.GetEnumerator() | ForEach-Object {
    $params['MemberName'] = $_.key
    $params['Value'] = $_.value
    Update-TypeData @params
}

Update-TypeData -AppendPath "$PSScriptRoot\Ec2.types.ps1xml"

# NEW CUSTOM METHOD
$params = @{
    TypeName   = "Amazon.EC2.Model.Instance"
    MemberType = "ScriptMethod"
    MemberName = "Randomize"
    Value      = { ($this.ToCharArray() | Get-Random -Count $this.Length) -join "" }
    Force      = $true
}

Update-TypeData @params

<# -- SKIPPED
OnDemandPrice
ReservedPrice
Savings
ProfileName
NameTags
#>

<# -- UNNECESSARY
Stopper
VpcName
SubnetName
#>

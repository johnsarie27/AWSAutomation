function Get-ELB {
    <# =========================================================================
    .SYNOPSIS
        Get Elastic Load Balancers
    .DESCRIPTION
        This function will return a list of AWS Elastic Load Balancers based on
        the Region and credentials (ProfileName) provided it. Not all properties
        are included and a few custom properties, namely IPAddress, has been
        added.
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Region
        AWS region
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-ELB -ProfileName MyAccount
        Get all Elastic Load Balancers in account represented by MyAccount profile
    .NOTES
        Uses [PSCustomObject] rather than $New = New-Object -TypeName psobject
    ========================================================================= #>
    [CmdletBinding()]
    [Alias('gelb')]
    Param(
        [Parameter(ValueFromPipeline, HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [Alias('Profile')]
        [string[]] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateSet("us-east-1", "us-east-2", "us-west-1", "us-west-2")]
        [ValidateNotNullOrEmpty()]
        [string] $Region = "us-east-1"
    )

    # IMPORT DNSCLIENT MODULE
    if ( $PSVersionTable.PSVersion.Major -ge 6 ) {
        Import-WinModule -Name DnsClient -ErrorAction SilentlyContinue
    }

    if ( -not $PSBoundParameters.ContainsKey('ProfileName') ) {
        $ProfileName = Get-AWSCredential -ListProfileDetail | Select-Object -EXP ProfileName
    }

    $AllELBs = @()

    foreach ( $Name in $ProfileName ) {
        # GET NETWORK ELASTIC LOAD BALANCERS (ELBs)
        $ELBList = Get-ELBLoadBalancer -ProfileName $Name -Region $Region # | Where-Object Scheme -NE 'internal'

        # GET ALL NETWORK INTERFACES
        $Net = Get-EC2NetworkInterface -ProfileName $Name -Region $Region

        # BUILD CUSTOM OBJECT FOR EACH WITH CUSTOM ATTRIBUTES
        foreach ( $ELB in $ELBList ) {
            # CREATE CUSTOM OBJECT
            $new = @{ 'LoadBalancerName' = $ELB.LoadBalancerName }
            #$new.AvailabilityZones = $ELB.AvailabilityZones
            #$new.CanonicalHostedZoneName = $ELB.CanonicalHostedZoneName
            $new.CreatedTime = $ELB.CreatedTime
            $new.DNSName = $ELB.DNSName
            #$new.HealthCheck = $ELB.HealthCheck
            $new.Instances = $ELB.Instances # | Select-Object -EXP Instances | Select-Object -EXP InstanceId
            $new.IpAddress = (Resolve-DnsName $ELB.DNSName).IPAddress
            #$new.ListenerDescriptions = $ELB.ListenerDescription
            #$new.Policies = $ELB.Policies
            $new.ProfileName = $Name
            $new.Scheme = $ELB.Scheme
            $new.SecurityGroups = $ELB.SecurityGroups
            #$new.SourceSecurityGroup = $ELB.SourceSecurityGroup
            #$new.Subnets = $ELB.Subnets
            $new.VPCId = $ELB.VPCId
            $new.Type = 'classic'
            $new.PrivateIp = @()

            # ADD CUSTOM OBJECT TO LIST
            $AllELBs += [PSCustomObject] $new
        }

        # GET APPLICATION LOAD BALANCERS (ALBS)
        $ALBList = Get-ELB2LoadBalancer -ProfileName $Name -Region $Region

        foreach ( $ALB in $ALBList ) {
            $new = @{ 'LoadBalancerName' = $ALB.LoadBalancerName }
            #$new.CanonicalHostedZoneId = $ALB.CanonicalHostedZoneId
            $new.CreatedTime = $ALB.CreatedTime
            $new.DNSName = $ALB.DNSName
            #$new.LoadBalancerArn = $ALB.LoadBalancerArn
            $new.Instances = 'N/A'
            $new.IpAddress = (Resolve-DnsName $ALB.DNSName).IPAddress
            $new.ProfileName = $Name
            $new.Scheme = $ALB.Scheme
            $new.SecurityGroups = $ALB.SecurityGroups
            $new.VPCId = $ALB.VPCId
            $new.Type = $ALB.Type
            $new.PrivateIp = @()

            # ADD CUSTOM OBJECT TO LIST
            $AllELBs += [PSCustomObject] $new
        }

        # LOOP ALL ELBS
        foreach ( $elb in $AllELBs ) {
            # LOOP ALL NETWORK INTERFACES
            $Net | ForEach-Object -Process {
                if ( $_.Description -match ('^ELB\s{0}' -f $elb.LoadBalancerName) ) {
                    $elb.PrivateIp += $_.PrivateIpAddress
                }
            }
        }
    }

    $AllELBs | Sort-Object -Property ProfileName
}

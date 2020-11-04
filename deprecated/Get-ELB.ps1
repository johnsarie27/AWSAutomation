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
    .PARAMETER Credential
        AWS Credential Object
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
    Param(
        [Parameter(ValueFromPipeline, HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [string] $Region = "us-east-1"
    )

    Begin {
        <# # IMPORT DNSCLIENT MODULE
        if ( $PSVersionTable.PSVersion.Major -ge 6 ) {
            Import-WinModule -Name DnsClient -ErrorAction SilentlyContinue
        } #>

        $awsParams = @{ Region = $Region }

        # CHECK FOR AUTHENTICATION METHOD
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $awsParams['ProfileName'] = $ProfileName }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $awsParams['Credential'] = $Credential }

        $allElbs = [System.Collections.Generic.List[System.Object]]::new()
    }

    Process {
        # GET ALL NETWORK INTERFACES
        $networkInterface = Get-EC2NetworkInterface @awsParams

        # GET NETWORK ELASTIC LOAD BALANCERS (ELBs)
        foreach ( $elb in (Get-ELBLoadBalancer @awsParams) ) { # | Where-Object Scheme -NE 'internal'
            # CREATE CUSTOM OBJECT
            $new = @{ 'LoadBalancerName' = $elb.LoadBalancerName }
            #$new.AvailabilityZones = $elb.AvailabilityZones
            #$new.CanonicalHostedZoneName = $elb.CanonicalHostedZoneName
            $new.CreatedTime = $elb.CreatedTime
            $new.DNSName = $elb.DNSName
            #$new.HealthCheck = $elb.HealthCheck
            $new.Instances = $elb.Instances # | Select-Object -EXP Instances | Select-Object -EXP InstanceId
            $new.IpAddress = (Resolve-DnsName $elb.DNSName).IPAddress
            #$new.ListenerDescriptions = $elb.ListenerDescription
            #$new.Policies = $elb.Policies
            $new.ProfileName = $ProfileName
            $new.Scheme = $elb.Scheme
            $new.SecurityGroups = $elb.SecurityGroups
            #$new.SourceSecurityGroup = $elb.SourceSecurityGroup
            #$new.Subnets = $elb.Subnets
            $new.VPCId = $elb.VPCId
            $new.Type = 'classic'
            $new.PrivateIp = @()

            # ADD CUSTOM OBJECT TO LIST
            $allElbs.Add([PSCustomObject] $new)
        }

        # GET APPLICATION LOAD BALANCERS (ALBS)
        foreach ( $ALB in (Get-ELB2LoadBalancer @awsParams) ) {
            $new = @{ 'LoadBalancerName' = $ALB.LoadBalancerName }
            #$new.CanonicalHostedZoneId = $ALB.CanonicalHostedZoneId
            $new.CreatedTime = $ALB.CreatedTime
            $new.DNSName = $ALB.DNSName
            #$new.LoadBalancerArn = $ALB.LoadBalancerArn
            $new.Instances = 'N/A'
            $new.IpAddress = (Resolve-DnsName $ALB.DNSName).IPAddress
            $new.ProfileName = $ProfileName
            $new.Scheme = $ALB.Scheme
            $new.SecurityGroups = $ALB.SecurityGroups
            $new.VPCId = $ALB.VPCId
            $new.Type = $ALB.Type
            $new.PrivateIp = @()

            # ADD CUSTOM OBJECT TO LIST
            $allElbs.Add([PSCustomObject] $new)
        }

        # LOOP ALL ELBS
        foreach ( $elb in $allElbs ) {

            # LOOP ALL NETWORK INTERFACES
            foreach ( $n in $networkInterface ) {
                if ( $n.Description -match ('^ELB\s{0}' -f $elb.LoadBalancerName) ) {
                    $elb.PrivateIp += $n.PrivateIpAddress
                }
            }
        }
    }

    End {
        # RETURN RESULTS
        $allElbs | Sort-Object -Property ProfileName
    }
}

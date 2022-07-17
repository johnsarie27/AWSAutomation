function ConvertFrom-ELBLog {
    <# =========================================================================
    .SYNOPSIS
        Convert from Application Load Balancer log file to objects
    .DESCRIPTION
        Convert from Application Load Balancer log file to objects
    .PARAMETER Path
        Path to raw log file
    .INPUTS
        System.String.
    .OUTPUTS
        System.Management.Automation.PSCustomObject.
    .EXAMPLE
        PS C:\> ConvertFrom-ELBLog -Path "D:\logs\elb_log.log"
        Convert contents of log file to objects
    .NOTES
        Name:     ConvertFrom-ELBLog
        Author:   Justin Johns
        Version:  0.1.0 | Last Edit: 2022-07-17
        - 0.1.0 - Initial version
        - 0.1.1 - Added support for pipeline input and ordered properties
        Comments: <Comment(s)>
        https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
        Testing:
        $line = Get-Content -Path <log_path>.log | Select-Object -Skip 1 -First 1

        $parenSplit = $line.Split('"')
        for ($i=0; $i -le $parenSplit.Count; $i++) {
            [PSCustomObject] @{ Index = $i; Item = $parenSplit[$i] }
        }

        $spcSplit = $line.Split(' ')
        for ($i = 0; $i -le $spcSplit.Count; $i++) {
            [PSCustomObject] @{ Index = $i; Item = $spcSplit[$i] }
        }
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'Path to raw log file')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf -Filter "*.log" })]
        [System.String] $Path
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
    }
    Process {

        foreach ($line in (Get-Content -Path $Path)) {

            # SPLIT BY DELIMETERS
            $parSplit = $line.Split('"')
            $spcSplit = $line.Split(' ')

            # CREATE AND OUTPUT CUSTOM OBJECT
            [PSCustomObject] [Ordered] @{
                type                     = $spcSplit[0]
                time                     = $spcSplit[1]
                elb                      = $spcSplit[2]
                client_port              = $spcSplit[3]
                target_port              = $spcSplit[4]
                request_processing_time  = $spcSplit[5]
                target_processing_time   = $spcSplit[6]
                response_processing_time = $spcSplit[7]
                elb_status_code          = $spcSplit[8]
                target_status_code       = $spcSplit[9]
                received_bytes           = $spcSplit[10]
                sent_bytes               = $spcSplit[11]
                request                  = $parSplit[1]
                user_agent               = $parSplit[3]
                ssl_cipher               = $parSplit[4].Split(' ')[1] #$spcSplit[19]
                ssl_protocol             = $parSplit[4].Split(' ')[2] #$spcSplit[20]
                target_group_arn         = $parSplit[4].Split(' ')[3] #$spcSplit[21]
                trace_id                 = $parSplit[5]
                domain_name              = $parSplit[7]
                chosen_cert_arn          = $parSplit[9]
                matched_rule_priority    = $spcSplit[10].Split(' ')[0] #$spcSplit[25]
                request_creation_time    = $spcSplit[10].Split(' ')[1] #$spcSplit[26]
                actions_executed         = $parSplit[11]
                redirect_url             = $parSplit[13]
                error_reason             = $parSplit[15]
                target_port_list         = $parSplit[17]
                target_status_code_list  = $parSplit[19]
                classification           = $parSplit[21]
                classification_reason    = $parSplit[23]
            }
        }
    }
}
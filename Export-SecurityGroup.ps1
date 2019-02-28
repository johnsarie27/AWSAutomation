function Export-SecurityGroup {
    <# =========================================================================
    .SYNOPSIS
        Export Security Groups from a CloudFormation template
    .DESCRIPTION
        Export Security Groups from a CloudFormation template to an Excel spreadsheet
    .PARAMETER TemplateFile
        Path to CloudFormation template file in .json or .template format
    .INPUTS
        System.String.
    .OUTPUTS
        Excel Workbook
    .EXAMPLE
        PS C:\> Export-SecurityGroup -TF C:\template.template
        Exports Security Groups from template.template
    .NOTES
        A log of work to be done here
        1. Create parameter input as a "Resource" object from a CF Template
        2. Export spreadsheet with multiple tabs?
        3. Clean up codes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'CloudFormation template file')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf -Include @("*.json", "*.template") })]
        [Alias('TF', 'Template', 'CF', 'File', 'Path', 'CloudFormation')]
        [string] $TemplateFile
    )

    Begin {
        function ConvertTo-SGObject {
            <# =========================================================================
            .SYNOPSIS
                Convert CloudFormation template to Security Group objects
            .DESCRIPTION
                Convert CloudFormation template to custom Security Group objects that
                can be easily written to a CSV or Excel file
            .PARAMETER TemplateFile
                Path to CloudFormation template file in .json or .template format
            .INPUTS
                System.String.
            .OUTPUTS
                System.Object.
            .EXAMPLE
                PS C:\> ConvertTo-SGObject -TemplateFile C:\CloudFormation.template
                Convert all Security Group resources in C:\CloudFormation.template into
                custom objects.
            .NOTES
                General notes
            ========================================================================= #>
            [CmdletBinding()]
            Param(
                [Parameter(Mandatory, HelpMessage = 'CloudFormation template file')]
                [ValidateScript({ Test-Path -Path $_ -PathType Leaf -Include @("*.json", "*.template") })]
                [Alias('TF', 'Template', 'CF', 'File', 'Path', 'CloudFormation')]
                [string] $TemplateFile
            )

            # GET CLOUDFORMATION TEMPLATE DATA
            $CF = Get-Content -Path $TemplateFile | ConvertFrom-Json

            # CREATE LIST
            $SecurityGroups = @()

            # GET SECURITY GROUP RESOURCES
            $SGResource = @()
            ($CF.Resources | Get-Member -MemberType NoteProperty).Name | ForEach-Object -Process {
                if ( $CF.Resources.$_.Type -eq 'AWS::EC2::SecurityGroup' ) { $SGResource += $_ }
            }

            # LOOP TEMPLATE FOR SECURITY GROUPS
            foreach ( $sg in $SGResource ) {

                # CREATE NEW OBJECT
                $New = @{ Name = $sg ; Rules = @() }

                # ADD TRAFFIC DIRECTION
                $CF.Resources.$sg.Properties.SecurityGroupIngress | ForEach-Object -Process {
                    $Rule = [PSCustomObject] @{
                        IpProtocol = $_.IpProtocol
                        FromPort   = $_.FromPort
                        ToPort     = $_.ToPort
                        CidrIp     = $_.CidrIp
                        Direction  = 'Ingress'
                    }
                    $New.Rules += $Rule
                }
                $CF.Resources.$sg.Properties.SecurityGroupEgress | ForEach-Object -Process {
                    $Rule = [PSCustomObject] @{
                        IpProtocol = $_.IpProtocol
                        FromPort   = $_.FromPort
                        ToPort     = $_.ToPort
                        CidrIp     = $_.CidrIp
                        Direction  = 'Egress'
                    }
                    $New.Rules += $Rule
                }

                # ADD IT TO THE LIST
                $SecurityGroups += [PSCustomObject] $New
            }

            # RETURN LIST
            $SecurityGroups
        }

        # IMPORT MODULE FOR EXCEL CREATION
        Import-Module -Name UtilityFunctions

        $Output = Join-Path -Path "$HOME\Desktop" -ChildPath ('CFSecGroup-{0}.xlsx' -f (Get-Date -F "yyyy-MM-ddTHHmmss"))
        $Splat = @{
            Autosize     = $true
            SavePath     = $Output
            SuppressOpen = $true
        }
    }
    
    Process {
        # GET AND CONVERT
        $SGObjects = ConvertTo-SGObject -TemplateFile $TemplateFile

    }
    
    End {
        # EXPORT TO EXCEL FILE
        $i=0
        $SGObjects | ForEach-Object -Process {
            #$_.Name
            #$_.Rules | Format-Table
            if ( $i -eq 1 ) { $Splat.Remove('SavePath') ; $Splat.Path = $Output }
            if ( $_ -eq $SGObjects[($SGObjects.Count-1)] ) { $Splat.Remove('SuppressOpen') }
            $_.Rules | Export-ExcelBook @Splat -SheetName $_.Name
            $i++
        }

        <# # OUTPUT TO CSV
        $SgName = 'rSecurityGroupDomainServices'
        $Props = @('Direction', 'IpProtocol', 'FromPort', 'ToPort', 'CidrIp')

        ($SecurityGroups | Where-Object Name -EQ $SgName).Rules | Select-Object -Property $Props |
            Export-Csv -NoTypeInformation -Path ('{0}\Desktop\{1}.csv' -f $HOME, $SgName)
        #>
        # END
    }
}

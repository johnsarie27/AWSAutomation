function Get-AwsServiceReference {
    <#
    .SYNOPSIS
        Gets the reference object for the provided AWS Service(s).
    .DESCRIPTION
        See https://docs.aws.amazon.com/service-authorization/latest/reference/service-reference.html
    .PARAMETER ServiceName
        AWS Service Name
    .INPUTS
        None.
    .OUTPUTS
        System.Object
    .EXAMPLE
        PS C:\> Get-AwsServiceReference
        Returns list of all AWS Services and their reference URLs.

        PS C:\> Get-AwsServiceReference -ServiceName 'ssm'
        Returns the reference information for the AWS Systems Manager (SSM) service.

        PS C:\> Get-AwsServiceReference -ServiceName 'ssm','s3'
        Returns the reference information for the AWS Systems Manager (SSM) and Amazon Simple Storage Service (S3) services.
    .NOTES
        Name:     Get-AwsServiceReference
        Author:   Phillip Glodowski
        Version:  0.0.1 | Last Edit: 2025-08-28
        - Version history is captured in repository commit history
        Comments:
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = 'Service Name(s)')]
        [System.String[]] $ServiceName
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
    }
    Process {

        # SET REQUEST PARAMETERS
        $restParams = @{
            Uri    = 'https://servicereference.us-east-1.amazonaws.com'
            Method = 'GET'
        }

        # GET SERVICE REFERENCE LIST
        $serviceReferenceList = Invoke-RestMethod @restParams

        # CHECK FOR SERVICE NAME PARAMETER
        if ($PSBoundParameters.ContainsKey('ServiceName')) {

            # CREATE OUTPUT COLLECTION
            $referenceCollection = [System.Collections.Generic.List[System.Object]]::new()

            # ITERATE THROUGH SERVICE NAMES
            foreach ($service in $ServiceName) {

                # VALIDATE SERVICE NAME
                if ($serviceReferenceList.service -cnotcontains $service) {
                    Write-Error -Message ('Service [{0}] not found in AWS Service Reference List.' -f $service) -ErrorAction Stop
                }
                else {
                    Write-Verbose -Message ('Getting reference information for service [{0}]' -f $service)

                    # GET SERVICE URL
                    $url = ($serviceReferenceList | Where-Object -Property service -EQ $service).url

                    # SET REQUEST PARAMETERS
                    $restParams = @{
                        Uri    = $url
                        Method = 'GET'
                    }

                    # ADD TO COLLECTION
                    $referenceCollection.Add((Invoke-RestMethod @restParams))
                }
            }

            # RETURN REFERENCE COLLECTION
            $referenceCollection
        }
        else {

            # RETURN FULL SERVICE REFERENCE LIST
            $serviceReferenceList
        }
    }
}
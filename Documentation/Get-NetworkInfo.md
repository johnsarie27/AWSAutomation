# Get-NetworkInfo

## SYNOPSIS
Get AWS network infrastructure

## SYNTAX

```
Get-NetworkInfo [[-ProfileName] <String>] [[-Credential] <AWSCredentials>] [[-Region] <String>]
 [-VpcId] <String> [<CommonParameters>]
```

## DESCRIPTION
This function iterates through the networking infrastructure (VPC's,
Subnets, and Route Tables) and outputs a list of objects using the
Route Tables as a connection point.

## EXAMPLES

### EXAMPLE 1
```
Get-NetworkInfo -ProfileName $P $Region 'us-east-1' -VpcId vpc-12345678
Get network infrastructure details for VPC vpc-12345678 in us-east-1 for store profile.
```

## PARAMETERS

### -ProfileName
Name property of an AWS credential profile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
AWS Credential Object

```yaml
Type: AWSCredentials
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
AWS region

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VpcId
Id of an AWS VPC

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String. Get-SecurityGroupInfo accepts string values for all parameters
## OUTPUTS

### System.Object.
## NOTES
The output is not printable so I used the following code to format it:
    $Output = ""
    foreach ( $item in $list ) {
        $Output += $item | Select-Object Name, Id, VpcId | Out-String
        $Output += $item | Select-Object -EXP Routes | Out-String
        $Output += $item | Select-Object -EXP Subnets | Out-String
    }
    $Output

## RELATED LINKS

# Get-SecurityGroupInfo

## SYNOPSIS
Retrieve security group information from an AWS VPC

## SYNTAX

```
Get-SecurityGroupInfo [[-ProfileName] <String>] [[-Credential] <AWSCredentials>] [[-Region] <String>]
 [-VpcId] <String> [<CommonParameters>]
```

## DESCRIPTION
This function retrieves all security groups from the provided VPC and
outputs an object with a subset of the data, including the EC2
instances, in a format easy to use

## EXAMPLES

### EXAMPLE 1
```
$a = Get-SecurityGroupInfo -ProfileName $P -VpcId $V
Store all security groups from Profile $P and VPC $V in varibale $a
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

## RELATED LINKS

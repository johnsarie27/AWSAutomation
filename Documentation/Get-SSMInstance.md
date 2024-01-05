# Get-SSMInstance

## SYNOPSIS
Get SSM Fleet

## SYNTAX

### __crd (Default)
```
Get-SSMInstance [-Credential] <AWSCredentials[]> [[-Region] <String>] [<CommonParameters>]
```

### __pro
```
Get-SSMInstance [-ProfileName] <String[]> [[-Region] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get SSM Fleet

## EXAMPLES

### EXAMPLE 1
```
$All = Get-SSMInstance -Region us-west-2
Return all SSM fleet instances using the local system's EC2 Instance Profile
in the us-west-2 region.
```

## PARAMETERS

### -ProfileName
Name property of an AWS credential profile

```yaml
Type: String[]
Parameter Sets: __pro
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
AWS Credential Object

```yaml
Type: AWSCredentials[]
Parameter Sets: __crd
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Region
AWS region

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Amazon.Runtime.AWSCredentials.
## OUTPUTS

### Amazon.SimpleSystemsManagement.Model.InstanceInformation.
## NOTES
General notes

## RELATED LINKS

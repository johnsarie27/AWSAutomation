# Get-SSMNonCompliance

## SYNOPSIS
Get non-compliant items

## SYNTAX

### __crd (Default)
```
Get-SSMNonCompliance [-Credential] <AWSCredentials[]> [-Region] <String> [<CommonParameters>]
```

### __pro
```
Get-SSMNonCompliance [-ProfileName] <String[]> [-Region] <String> [<CommonParameters>]
```

## DESCRIPTION
Get non-compliant SSM items of type Association or Patch

## EXAMPLES

### EXAMPLE 1
```
$socCreds.Values | Get-SSMNonCompliance -Region us-east-2
Get any non-compliant items for all accounts in us-east-2 contained in $socCreds
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

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Amazon.Runtime.AWSCredentials.
## OUTPUTS

### Amazon.SimpleSystemsManagement.Model.ComplianceItem.
## NOTES
General notes

## RELATED LINKS

# Get-PatchInfo

## SYNOPSIS
Get AWS Systems Manager Patch information

## SYNTAX

### __pro
```
Get-PatchInfo [-PatchGroup] <String> [-ProfileName] <String[]> [[-Region] <String>] [<CommonParameters>]
```

### __crd
```
Get-PatchInfo [-PatchGroup] <String> [-Credential] <AWSCredentials[]> [[-Region] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get AWS Systems Manager Patch information for all instances in a give
Patch Group

## EXAMPLES

### EXAMPLE 1
```
Get-PatchInfo PatchGroup 'staging*' -Credential $c -Region us-west-2
Explanation of what the example does
```

## PARAMETERS

### -PatchGroup
Patch Group

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS credential profile name

```yaml
Type: String[]
Parameter Sets: __pro
Aliases:

Required: True
Position: 2
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
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Region
AWS Region

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Amazon.Runtime.AWSCredentials.
## OUTPUTS

### System.Object.
## NOTES
General notes

## RELATED LINKS

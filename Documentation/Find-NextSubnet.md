# Find-NextSubnet

## SYNOPSIS
Find next unused subnet

## SYNTAX

### _profile (Default)
```
Find-NextSubnet -ProfileName <String[]> [-Region <String>] [<CommonParameters>]
```

### _creds
```
Find-NextSubnet -Credential <AWSCredentials[]> [-Region <String>] [<CommonParameters>]
```

## DESCRIPTION
Find next unused subnet and return the second octet of the subnet CIDR range

## EXAMPLES

### EXAMPLE 1
```
Find-NextSubnet -ProfileName $myProfile
Returns the second octet of the next available subnet CIDR range
```

## PARAMETERS

### -ProfileName
AWS Credential Profile Name

```yaml
Type: String[]
Parameter Sets: _profile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
AWS Credential Object

```yaml
Type: AWSCredentials[]
Parameter Sets: _creds
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
AWS Region

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### System.Int32
## NOTES
General notes

## RELATED LINKS

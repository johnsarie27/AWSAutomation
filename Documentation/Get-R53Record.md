# Get-R53Record

## SYNOPSIS
Get R53 DNS records

## SYNTAX

```
Get-R53Record [[-ProfileName] <String>] [[-Credential] <AWSCredentials>] [-ZoneName] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Get R53 Hosted zone DNS data for all "A" and "CNAME" records

## EXAMPLES

### EXAMPLE 1
```
Get-R53Record -ProfileName MyProfile -ZoneName 'myDomain.com.'
Get all "A" and "CNAME" records for the zone 'myDomain.com.'
```

## PARAMETERS

### -ProfileName
AWS Profile name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Profile

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

### -ZoneName
AWS R53 Hosted zone name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Zone, ZN

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### System.Object[].
## NOTES
General notes

## RELATED LINKS

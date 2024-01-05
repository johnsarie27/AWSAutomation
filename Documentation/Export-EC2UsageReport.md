# Export-EC2UsageReport

## SYNOPSIS
Generate reports for instances offline and running without reservation

## SYNTAX

```
Export-EC2UsageReport [[-OutputDirectory] <String>] [[-ProfileName] <String[]>]
 [[-Credential] <AWSCredentials[]>] [[-Region] <String>] [-PassThru] [<CommonParameters>]
```

## DESCRIPTION
This script iterates through all instances in a give AWS Region and creates
a list of specific attributes.
It then finds the last stop time, user who
stopped the instance, and calculates the number of days the system has been
stopped (if possible) and creates a data sheet (CSV).
The data sheet is then
imported into Excel and formatted. 
This can be done for a single or
multiple accounts based on AWS Credentail Profiles.

## EXAMPLES

### EXAMPLE 1
```
Export-EC2UsageReport -Region us-west-1 -ProfileName MyAccount
Generate new EC2 report for all instances in MyAccount in the us-west-1
region
```

## PARAMETERS

### -OutputDirectory
Path to existing folder for report

```yaml
Type: String
Parameter Sets: (All)
Aliases: DestinationPath

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
This is the name of the AWS Credential profile containing the Access Key and
Secret Key.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: PN

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
AWS Credential Object

```yaml
Type: AWSCredentials[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
This is the AWS region containing the desired resources to be processed

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Return path to report file

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### None.
## NOTES

## RELATED LINKS

# ConvertFrom-ELBLog

## SYNOPSIS
Convert from Application Load Balancer log file to objects

## SYNTAX

```
ConvertFrom-ELBLog [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Convert from Application Load Balancer log file to objects

## EXAMPLES

### EXAMPLE 1
```
ConvertFrom-ELBLog -Path "D:\logs\elb_log.log"
Convert contents of log file to objects
```

## PARAMETERS

### -Path
Path to raw log file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String.
## OUTPUTS

### System.Management.Automation.PSCustomObject.
## NOTES
Name:     ConvertFrom-ELBLog
Author:   Justin Johns
Version:  0.1.0 | Last Edit: 2022-07-17
- 0.1.0 - Initial version
- 0.1.1 - Added support for pipeline input and ordered properties
Comments: \<Comment(s)\>
https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html
Testing:
$line = Get-Content -Path \<log_path\>.log | Select-Object -Skip 1 -First 1

$parenSplit = $line.Split('"')
for ($i=0; $i -le $parenSplit.Count; $i++) {
    \[PSCustomObject\] @{ Index = $i; Item = $parenSplit\[$i\] }
}

$spcSplit = $line.Split(' ')
for ($i = 0; $i -le $spcSplit.Count; $i++) {
    \[PSCustomObject\] @{ Index = $i; Item = $spcSplit\[$i\] }
}

## RELATED LINKS

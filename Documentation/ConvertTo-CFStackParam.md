# ConvertTo-CFStackParam

## SYNOPSIS
Convert hashtable to CloudFormation Parameter object

## SYNTAX

```
ConvertTo-CFStackParam [-Parameter] <Hashtable> [<CommonParameters>]
```

## DESCRIPTION
Convert hashtable to CloudFormation Parameter object

## EXAMPLES

### EXAMPLE 1
```
ConvertTo-CFStackParam -Parameter @{ pVpcCIDR = '172.16.0.0/16'; pVpcName = 'myNewVpc' }
Output new [Amazon.CloudFormation.Model.Parameter] objects for "pVpcCIDR" and "pVpcName"
```

## PARAMETERS

### -Parameter
Hashtable with CloudFormation Stack Parameter(s)

```yaml
Type: Hashtable
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

### None.
## OUTPUTS

### Amazon.CloudFormation.Model.Parameter[].
## NOTES
General notes

## RELATED LINKS

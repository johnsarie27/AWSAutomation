# Get-LoadBalancer

## SYNOPSIS
Get Elastic Load Balancer v2

## SYNTAX

### __crd (Default)
```
Get-LoadBalancer [-Credential] <AWSCredentials[]> [[-Region] <String>] [<CommonParameters>]
```

### __pro
```
Get-LoadBalancer [-ProfileName] <String[]> [[-Region] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get Elastic Load Balancer v2

## EXAMPLES

### EXAMPLE 1
```
<example usage>
Explanation of what the example does
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

### Amazon.Runtime.AWSCredential.
## OUTPUTS

### Amazon.ElasticLoadBalancingV2.Model.LoadBalancer.
## NOTES
General notes

## RELATED LINKS

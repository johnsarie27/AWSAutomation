---
external help file: AWSAutomation-help.xml
Module Name: AWSAutomation
online version:
schema: 2.0.0
---

# New-ResourceObject

## SYNOPSIS
Create a CloudFormation resource

## SYNTAX

### EIP (Default)
```
New-ResourceObject [-EIP] [-NameTag <String>] [<CommonParameters>]
```

### NGW
```
New-ResourceObject [-NGW] [-NameTag <String>] -EipName <String> -SubnetName <String> [<CommonParameters>]
```

### IGW
```
New-ResourceObject [-IGW] [-NameTag <String>] [<CommonParameters>]
```

### VGA
```
New-ResourceObject [-VGA] [-NameTag <String>] [<CommonParameters>]
```

## DESCRIPTION
Generate a new CloudFormation resource object

## EXAMPLES

### Example 1
```powershell
PS C:\> New-ResourceObject -EIP
```

Create a generic Elastic IP resource object for CloudFormation

## PARAMETERS

### -EIP
Elastic IP

```yaml
Type: SwitchParameter
Parameter Sets: EIP
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EipName
Elast IP name

```yaml
Type: String
Parameter Sets: NGW
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IGW
Internet Gateway

```yaml
Type: SwitchParameter
Parameter Sets: IGW
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NGW
NAT Gateway

```yaml
Type: SwitchParameter
Parameter Sets: NGW
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NameTag
Value for name tag

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

### -SubnetName
Subnet name

```yaml
Type: String
Parameter Sets: NGW
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -VGA
VPC Gateway Attachment

```yaml
Type: SwitchParameter
Parameter Sets: VGA
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS

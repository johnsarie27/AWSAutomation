# New-HealthCheck

## SYNOPSIS
Create new Route53 Health Check

## SYNTAX

### __crd (Default)
```
New-HealthCheck -Name <String> -DNS <String> -ResourcePath <String> -Type <String> [-SearchString <String>]
 -Credential <AWSCredentials> -Region <String> [<CommonParameters>]
```

### __pro
```
New-HealthCheck -Name <String> -DNS <String> -ResourcePath <String> -Type <String> [-SearchString <String>]
 -ProfileName <String> -Region <String> [<CommonParameters>]
```

## DESCRIPTION
Create Route53 Health Check with set values and add "Name" tag

## EXAMPLES

### EXAMPLE 1
```
New-HealthCheck
Explanation of what the example does
```

## PARAMETERS

### -Name
Health Check name (tag)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DNS
Domain name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ResourcePath
URI or resource path

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Health Check type

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchString
Search string

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

### -ProfileName
Name property of an AWS credential profile

```yaml
Type: String
Parameter Sets: __pro
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
Type: AWSCredentials
Parameter Sets: __crd
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

Required: True
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

### None.
## NOTES
Name:     New-HealthCheck
Author:   Justin Johns
Version:  0.1.0 | Last Edit: 2022-05-26
- \<VersionNotes\> (or remove this line if no version notes)
Comments: \<Comment(s)\>
General notes

## RELATED LINKS

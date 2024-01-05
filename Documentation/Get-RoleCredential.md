# Get-RoleCredential

## SYNOPSIS
Get IAM credential object

## SYNTAX

### _profile (Default)
```
Get-RoleCredential -ProfileName <String> -Region <String> -Account <Object[]> -RoleName <String>
 [-SerialNumber <String>] [-TokenCode <String>] [-DurationInSeconds <Int32>] [<CommonParameters>]
```

### _keys
```
Get-RoleCredential -Keys <PSCredential> -Region <String> -Account <Object[]> -RoleName <String>
 [-SerialNumber <String>] [-TokenCode <String>] [-DurationInSeconds <Int32>] [<CommonParameters>]
```

## DESCRIPTION
Get IAM Credential from IAM Role

## EXAMPLES

### EXAMPLE 1
```
$acc = [PSCustomObject] @{ Name = 'myAccount'; Id = '012345678901' }
PS C:\> Get-RoleCredential -ProfileName myProfile -Region us-east-1 -Acount $acc -RoleName mySuperRole
Get AWS Credential object(s) for account ID 012345678901 and Role name mySuperRole
```

## PARAMETERS

### -ProfileName
AWS Credential Profile name

```yaml
Type: String
Parameter Sets: _profile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Keys
AWS access key and secret keys in a PSCredential object

```yaml
Type: PSCredential
Parameter Sets: _keys
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

### -Account
Custom object containing AWS Account Name and Id properties

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RoleName
Name of AWS IAM Role to utilize and obtain credentials

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

### -SerialNumber
MFA device serial number

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

### -TokenCode
Value provided by MFA device

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

### -DurationInSeconds
Duration of temporary credential in seconds

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 3600
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### System.Object.
## NOTES
General notes
https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_configure-api-require.html
https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=Use-STSRole.html&tocid=Use-STSRole

## RELATED LINKS

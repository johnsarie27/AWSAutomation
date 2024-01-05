# Set-AwsSsoCredential

## SYNOPSIS
Set or update AWS Credential Profiles

## SYNTAX

```
Set-AwsSsoCredential [[-Region] <String>] [[-StartUrl] <Uri>] [-Force] [-Account] <Object[]>
 [<CommonParameters>]
```

## DESCRIPTION
Use AWS named profiles and AWS Tools for PowerShell to store and refresh credentials for multiple accounts from a single IAM Identity Center.
Stores IAM Identity Center session data in memory for refreshing credentials without logging into IAM Identity Center again.
Stores account credentials in the default location (~/.aws/credentials) which are picked up by AWS Tools for PowerShell

## EXAMPLES

### EXAMPLE 1
```
Set-AwsSsoCredential -Account
Explanation of what the example does
```

## PARAMETERS

### -Region
Identity Center Region

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: Us-east-1
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartUrl
Identity Center URL

```yaml
Type: Uri
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Https://mcssec.awsapps.com/start/
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Force add new accounts

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

### -Account
Array of account info

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

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

### None.
## NOTES
Name:     Set-AwsSsoCredential
Author:   Michael Hatcher
Version:  0.1.0 | Last Edit: 2023-07-19
- 0.1.0 - Initial version
Comments: \<Comment(s)\>
General notes
https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/update-aws-cli-credentials-from-aws-iam-identity-center-by-using-powershell.html

## RELATED LINKS

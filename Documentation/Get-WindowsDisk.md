# Get-WindowsDisk

## SYNOPSIS
List the Windows disks

## SYNTAX

```
Get-WindowsDisk
```

## DESCRIPTION
List the Windows disks

## EXAMPLES

### EXAMPLE 1
```
Get-WindowsDisk
Returns a mapping of the Windows disk(s) and associated EBS volume information
```

## PARAMETERS

## INPUTS

### None.
## OUTPUTS

### System.Object[].
## NOTES
General notes
This function requires a default AWS Credential Profile or an IAM Instance
Profile to be set with permissions for ec2:Describe*
Several design choices were made for compatibility with PS 4.0

## RELATED LINKS

[https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-windows-volumes.html#windows-volume-mapping](https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-windows-volumes.html#windows-volume-mapping)


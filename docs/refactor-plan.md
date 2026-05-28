# AWSAutomation — Refactor Plan

> **Temporary working document.** This file tracks the analysis and proposed
> sequencing for the refactor work in issue #66. It must be deleted from the
> branch before the refactor PR is merged. See the corresponding checklist item
> on issue #66.

Compared the codebase against the team `powershell` skill (universal
standards + `references/module-structure.md` + `references/advanced-functions.md`).
The module is functional and follows the right *shape* (`Public/`, `Private/`,
manifest-driven exports, PSake build, Help/Manifest/Meta tests, validate +
release workflows). Most gaps are universal-standards drift and inconsistency
across the 36 public functions.

## High-priority gaps

### 1. `Throw` used for terminating errors (preference violation)

6 occurrences. Replace each with
`Write-Error -Message '...' -ErrorAction Stop` (also applies inside
`ValidateScript` blocks per stored user preferences).

- [Public/Export-SECSecret.ps1](../Public/Export-SECSecret.ps1) line 73
- [Public/Find-PublicS3Object.ps1](../Public/Find-PublicS3Object.ps1) line 50
- [Public/Get-IAMReport.ps1](../Public/Get-IAMReport.ps1) line 70
- [Public/New-HealthCheck.ps1](../Public/New-HealthCheck.ps1) line 86
- [Public/Set-AwsSsoCredential.ps1](../Public/Set-AwsSsoCredential.ps1) line 137
- [Public/Update-CFNStackAMI.ps1](../Public/Update-CFNStackAMI.ps1) line 86

### 2. `[OutputType()]` missing on ~80% of public functions

Only 7 of 36 functions declare `[OutputType()]`. Every function that returns
data needs one with a full .NET type. Use `[OutputType([System.Void])]` for
action-only functions like `New-HealthCheck`, `Edit-AWSProfile`,
`Invoke-SSMRunCommand`.

### 3. Type accelerators (`[string]`, `[int]`, `[char]`) still in use

Promote all to `System.*` full names.

- [Public/Edit-AWSProfile.ps1](../Public/Edit-AWSProfile.ps1) line 78
- [Public/Export-EC2UsageReport.ps1](../Public/Export-EC2UsageReport.ps1) line 71
- [Public/Find-InsecureS3BucketPolicy.ps1](../Public/Find-InsecureS3BucketPolicy.ps1) line 69
- [Public/Find-NextSubnet.ps1](../Public/Find-NextSubnet.ps1) line 69
- [Public/Get-WindowsDisk.ps1](../Public/Get-WindowsDisk.ps1) lines 25, 30, 36

### 4. Double-quoted string interpolation

The standard requires the `-f` format operator over `"$(...)"`. Concentrated
in [Public/Set-AwsSsoCredential.ps1](../Public/Set-AwsSsoCredential.ps1) (e.g.
`"$($IdentityCenterName)_..."`). Convert to
`'{0}_identity_center_token' -f $IdentityCenterName`, etc.

### 5. `Set-AwsSsoCredential` is a standards hot-spot

Single biggest deviation in the module:

- Uses `Write-Output` for user-facing prompts (should be
  `Write-Information -InformationAction Continue` or `Write-Warning`).
- Uses `$Global:` scoped variables for token caching — violates "prefer
  function-local scope".
- Header is the old `Name/Author/Version/Last Edit` block instead of the
  `Status: ...` convention.
- Catches and re-throws via `throw $PSItem` plus a string-interpolated
  `Write-Error`.
- Hardcoded org default `'https://mcssec.awsapps.com/start/'` — should be a
  parameter without a built-in default, or read from config.
- `Mandatory = $false` written out explicitly (use shorthand `Mandatory` only
  when true; omit otherwise).

### 6. `Get-IAMReport` legacy patterns

[Public/Get-IAMReport.ps1](../Public/Get-IAMReport.ps1) builds output with
`New-Object psobject` + repeated `Add-Member` calls. Replace with
`[PSCustomObject] @{ ... }`. Also uses `Throw` (#1) and PascalCase locals
(`$Date`, `$Accounts`, `$IAMReport`) — should be `$date`, `$accounts`,
`$iamReport`.

### 7. Comment-based help — `.NOTES` format

Almost every function uses the old `Name/Author/Version/Last Edit` block (see
`New-HealthCheck`, `Set-AwsSsoCredential`). Standard now is a single line
`Status: <Stable|Beta|Experimental|Deprecated>` plus optional comments/links;
git history owns the version/author trail. Many help blocks also have
`Explanation of what the example does` placeholder text that needs real
content.

## Medium-priority gaps

### 8. Manifest hygiene ([AWSAutomation.psd1](../AWSAutomation.psd1))

- `CompatiblePSEditions` not set — add `@('Core', 'Desktop')`.
- `PowerShellVersion = '5.1'` but the skill targets PS 7+; decide whether
  this module is dual-edition (then keep 5.1) or PS 7+ only (raise to `'7.4'`
  and allow `Clean` blocks etc.).
- `Copyright = '(c) 2018 ...'` — bump year.
- `ProjectUri` still points to personal fork (`johnsarie27/AWSAutomation`) —
  should be `PS-MCS/AWSAutomation` now that the repo lives in the org.
- `LicenseUri`, `Tags`, `ReleaseNotes` commented out — populate at least
  `Tags` and `LicenseUri`.
- `RequiredModules` entries use bare names — pin to exact versions per the
  universal standard
  (`@{ ModuleName='AWS.Tools.EC2'; ModuleVersion='4.1.x' }`). This also
  surfaces the inconsistency where
  [Public/Set-AwsSsoCredential.ps1](../Public/Set-AwsSsoCredential.ps1) pins
  `4.1.269` but the manifest does not.
- `AlphabetList` / `VolumeLookupTable` exported as variables — consider
  whether the module surface really needs these; if internal-only, drop from
  `VariablesToExport`.
- `Get-AwsCreds` alias listed in `AliasesToExport` — confirm a `Set-Alias`
  actually exists (none found in `.psm1` or any function file).

### 9. Root module ([AWSAutomation.psm1](../AWSAutomation.psm1))

Close to the reference pattern but:

- The `$VolumeLookupTable` builder uses semicolons-as-statement-separators on
  single lines — split to one statement per line.
- Per the standard, omit `Export-ModuleMember -Function *` (already done) but
  consider explicitly `Export-ModuleMember -Variable * -Alias *` so the
  manifest's variable/alias exports are honored regardless of how the module
  is dot-sourced.

### 10. CI workflows ([.github/workflows](../.github/workflows))

- Both workflows reference actions by floating tags
  (`actions/checkout@v6`, `actions/upload-artifact@v7`). Standard requires
  **commit-SHA pinning** with a trailing version comment.
- `validate.yml` runs on `pull_request` only — standard also runs on
  `push: branches: [main]` and adds a `concurrency` block to cancel
  superseded runs.
- Both workflows use Windows-style path separator `.\Build\build.ps1` while
  running on `ubuntu-latest`. Works under `pwsh` but `./Build/build.ps1` is
  cross-platform-idiomatic.

### 11. Tests directory layout

There is no `Tests/Unit/` directory — only `Tests/Common/` with
`Help.Tests.ps1`, `Manifest.Tests.ps1`, `Meta.Tests.ps1`. Standard expects a
per-function `Tests/Unit/Verb-Noun.tests.ps1`. None exist today; this is a
long-tail debt item but worth flagging.

### 12. `Begin`/`Process` discipline

Many functions either omit `Begin` or do real work outside `Process`.
[Public/Get-Instance.ps1](../Public/Get-Instance.ps1) is `Process`-only
(fine, pipeline-friendly). But
[Public/Get-IAMReport.ps1](../Public/Get-IAMReport.ps1) does parameter setup
*and* the full report fetch (a blocking polling loop with `Start-Sleep`)
inside `Begin`, then iterates inside `Process`. Per the standard, `Begin` is
for init only.

### 13. `deprecated/` and `WIP/` cleanup

`deprecated/` (16 files) and `WIP/` (7 files) are not referenced by the
manifest or `.psm1`. They are visible in the repo tree and confuse
contributors. Either:

- Delete them (git history retains them), or
- Move under a single `Archive/` folder explicitly excluded from packaging
  and CI, with a README explaining why they remain.

## Low-priority / polish

- **Hashtable comments next to code** (e.g., `ErrorAction = 1 # Stop`)
  violate "no inline comments". Move above the key or drop the magic-number
  alias and use `'Stop'` directly.
- **Backtick line continuation** — none seen in spot-checks, good. Splatting
  use is reasonable but inconsistent (some calls still pass 3+ named params
  directly).
- **`Find-PublicS3Object`, `Find-InsecureS3BucketPolicy`** etc. have lengthy
  `Where-Object` pipelines that should be extracted to a `$where`
  script-block variable per the universal standard.
- **`Get-WindowsDisk`** uses inline `param([string]$Path)` nested
  functions — minor, but full types still apply.
- **`Get-LatestImage` / `Get-Instance` / `Get-LoadBalancer`** etc. validate
  `ProfileName` with
  `(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_`
  duplicated 15+ times. Candidate for a `Private/` validator helper or a
  shared `[ValidateScript]` constant.
- **`AwsSecurityFinding.types.ps1xml` etc.** are referenced in
  `TypesToProcess` with `./Private/...` — works on both editions, but
  `Private/...` (manifest-relative) is more portable.

## Recommended sequencing for the refactor branch

Doing this in one PR will be huge. Suggested per-commit slicing (still under
issue #66):

1. **Manifest + workflow housekeeping** (#8, #10) — small, low-risk,
   immediate CI improvement.
2. **`Throw` -> `Write-Error -ErrorAction Stop` sweep** (#1) — mechanical,
   6 sites.
3. **Type accelerators + `OutputType` sweep** (#2, #3) — mechanical across
   all `Public/*.ps1`.
4. **Help block normalization to `Status:` notes + remove placeholder
   examples** (#7).
5. **`Get-IAMReport` modernization** (#6) — `[PSCustomObject]` rewrite +
   naming.
6. **`Set-AwsSsoCredential` rewrite** (#5) — biggest single change;
   consider its own PR.
7. **`deprecated/` + `WIP/` cleanup decision** (#13).
8. **Per-function unit tests under `Tests/Unit/`** (#11) — long tail, can be
   incremental.

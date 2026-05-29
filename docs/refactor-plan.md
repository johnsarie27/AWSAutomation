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

### 1. `Throw` used for terminating errors (preference violation) — **CLOSED**

All 6 `Throw` sites in `Public/` replaced with
`Write-Error -Message '...' -ErrorAction Stop` during the early refactor
sweep. `Get-IAMReport` will be re-checked as part of gap #6.

### 2. `[OutputType()]` missing on ~80% of public functions — **CLOSED**

All 36 public functions now declare `[OutputType()]` with concrete
SDK/.NET types (or `[System.Void]` for action-only cmdlets). Closed in
commit `6632b6f`.

### 3. Type accelerators (`[string]`, `[int]`, `[char]`) still in use — **CLOSED**

All listed type accelerators promoted to full `System.*` names alongside
the OutputType sweep in commit `6632b6f`.

### 4. Double-quoted string interpolation — **CLOSED (deferred for `Set-AwsSsoCredential`)**

The only function flagged was `Set-AwsSsoCredential`, which is upstream
AWS-authored code (see the prescriptive-guidance URL in its `.NOTES`).
Per maintainer decision, the upstream style is preserved; only the
`.NOTES` header and any `Throw` sites are aligned to our standards.

### 5. `Set-AwsSsoCredential` is a standards hot-spot — **CLOSED (scoped)**

This function is upstream AWS-authored code shared via the prescriptive
guidance URL in its `.NOTES`. By maintainer decision, the upstream
implementation is preserved as-is **except** for:

- `.NOTES` header normalized to the `Status:` convention (commit
  `0a529c8`).
- `throw $PSItem` replaced with `Write-Error -ErrorAction Stop` (already
  in place; verified during gap #5 review).

The remaining deviations (`Write-Output` prompts, `$Global:` token cache,
hardcoded default Start URL, explicit `Mandatory = $false`,
double-quoted interpolation) are intentionally left to stay close to the
upstream source.

### 6. `Get-IAMReport` legacy patterns — **CLOSED**

`New-Object psobject` + 13 `Add-Member` calls replaced with a single
`[PSCustomObject]` literal; PascalCase locals lowered to camelCase per
standard; duplicate `Get-IAMGroupForUser` call collapsed. Output schema
and order preserved. Gap #12 (Begin/Process discipline for this
function) is intentionally left for a later pass.

### 7. Comment-based help — `.NOTES` format — **CLOSED**

All 36 public functions normalized to the `Status:` convention; substantive
content (URLs, permission notes, prescriptive guidance) preserved under
`Comments:`. Placeholder example text replaced with real one-liners.
`CONTRIBUTING.md` template updated to match. Closed in commit `0a529c8`.

## Medium-priority gaps

### 8. Manifest hygiene ([AWSAutomation.psd1](../AWSAutomation.psd1)) — **CLOSED (scoped)**

Applied this pass:

- `CompatiblePSEditions = @('Core', 'Desktop')` added.
- `Copyright` bumped to `(c) 2018-2026 Justin Johns. All rights reserved.`
- `Tags` populated (`AWS, Automation, CloudFormation, EC2, IAM, S3,
  Reporting`).
- `LicenseUri` populated to the LICENSE file in the org repo.
- `Get-AwsCreds` removed from `AliasesToExport` (it was never wired up
  via `Set-Alias`); the matching `[Alias('Get-AwsCreds')]` attribute
  removed from `Get-RoleCredential.ps1`.

Intentionally **not** changed per maintainer:

- `PowerShellVersion` stays at `'5.1'` (module remains dual-edition).
- `ProjectUri` stays at the personal repo URL for now.
- `RequiredModules` left as bare names (no exact-version pinning).
- `AlphabetList` / `VolumeLookupTable` continue to be exported.

### 9. Root module ([AWSAutomation.psm1](../AWSAutomation.psm1)) — **CLOSED**

- `$VolumeLookupTable` builder split to one statement per line; the `;`
  statement separators are gone.
- `[int]` / `[string]` accelerators inside the builder replaced with
  `[System.Int32]` / `[System.String]`.
- Added explicit `Export-ModuleMember -Variable * -Alias *` so the
  manifest's `VariablesToExport` / `AliasesToExport` lists are honored
  regardless of how the module is loaded. `-Function` is still left to
  the manifest.
- Stale `Version:` / `Updated:` header line removed (git owns version
  history).

Verified `Import-Module` still surfaces `AlphabetList` and
`VolumeLookupTable` via `Get-Module`.

### 10. CI workflows ([.github/workflows](../.github/workflows)) — **CLOSED**

- `actions/checkout@v6` and `actions/upload-artifact@v7` swapped for
  full commit SHAs with a trailing version comment in both
  `validate.yml` and `release.yml`. `softprops/action-gh-release` was
  already SHA-pinned.
- `validate.yml` now also triggers on `push: branches: [main]` and has
  a `concurrency` group keyed by `github.ref` with
  `cancel-in-progress: true` so superseded runs are cancelled.
- All `.\Build\build.ps1` invocations changed to `./Build/build.ps1`
  for cross-platform idiomatic paths under `pwsh` on `ubuntu-latest`.

### 11. Tests directory layout — **CLOSED (skeleton + Tier A examples)**

`Tests/Unit/` directory created with a README that documents the
`Verb-Noun.tests.ps1` per-function convention, the build task to run the
suite (`./Build/build.ps1 -TaskList Test`), the BuildHelpers env vars
(`$env:BHProjectName`, `$env:BHPSModuleManifest`), and points at the
team-wide PowerShell skill (`references/pester-testing.md`) for full
conventions.

Seven example test files (31 tests, all passing) cover the highest-value
functions across the three core archetypes so future contributors can
copy the closest pattern:

- Pure transform: `ConvertTo-CFStackParam`, `Get-S3Url`
- File-fixture parser (TestDrive): `ConvertFrom-CFLog`, `ConvertFrom-ELBLog`
- AWS-cmdlet mock + `[ValidateScript]` shim: `Find-NextSubnet`,
  `Get-LatestImage`, `Get-IAMReport`

Coverage for the remaining "thin wrapper" `Get-*`/`Find-*` functions
(Tier B) is tracked in #69. Orchestration wrappers, side-effect-heavy
exporters, local/interactive functions, and multi-call aggregators are
intentionally out of scope until they get a refactor pass.

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

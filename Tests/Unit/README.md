# Tests/Unit

Per-function unit tests for the public surface of `AWSAutomation`. These
complement the suite-wide checks under [Tests/Common](../Common) (help,
manifest, and meta tests that iterate every public function).

## Convention

- One file per public function, named `Tests/Unit/Verb-Noun.tests.ps1`,
  mirroring the layout under `Public/`.
- Pester 5+ syntax. Tests must not reach AWS — stub external calls with
  `Mock -ModuleName $env:BHProjectName`.
- Import the module via the BuildHelpers env vars set by the `Init`
  build task:

  ```powershell
  BeforeDiscovery {
      if (-not (Get-Module -Name $env:BHProjectName)) {
          Import-Module -Name $env:BHPSModuleManifest -ErrorAction Stop -Force
      }
  }
  ```

- Use keyword-style args throughout: `Describe -Name '...' -Fixture { }`,
  `Context -Name '...' -Fixture { }`, `It -Name '...' -Test { }`.

See [`Get-IAMReport.tests.ps1`](./Get-IAMReport.tests.ps1) as the
in-repo template. Full team-wide conventions (mocking, the
`[ValidateScript]` gotcha, what to assert) live in the PowerShell skill
under `references/pester-testing.md`.

## Running

```pwsh
./Build/build.ps1 -ResolveDependency -TaskList Test
```

## Status

Coverage is being added incrementally. New or modified functions should
land with a matching `Tests/Unit/` file going forward.

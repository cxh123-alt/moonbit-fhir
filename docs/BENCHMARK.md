# Benchmark record

This record captures a reproducible smoke benchmark for the current package. It measures end-to-end CLI wall-clock time, including MoonBit's cached `moon run` orchestration, rather than presenting a synthetic throughput claim.

## Environment

- Date: 2026-08-23
- Host: Windows workstation, PowerShell
- MoonBit: `moon 0.1.20260807 (4da23f8 2026-08-07)`
- Command: `moon run cmd/main -- --benchmark 100`
- Samples: 6 sequential warm-cache invocations

## Result

| Metric | Result |
| --- | ---: |
| Minimum wall time | 132.17 ms |
| Average wall time | 149.12 ms |
| Maximum wall time | 165.77 ms |
| Benchmark output | `validation=100; ndjson-validation=100` |

The benchmark command generates and validates 100 Observation resources and validates a 100-line NDJSON payload. The source-level scenario matrix also covers Bundle analysis over 100 entries and a search scan over 1,000 generated observations; those cases are exposed by `benchmark_scenario_csv()` and covered by the benchmark fixture tests.

## Reproduce

PowerShell:

```powershell
$samples = 1..6 | ForEach-Object {
  $m = Measure-Command { moon run cmd/main -- --benchmark 100 | Out-Null }
  [math]::Round($m.TotalMilliseconds, 2)
}
$samples
```

For a lower-level comparison, run the benchmark functions from a MoonBit test or application and report the toolchain, target, compiler mode, fixture count, and whether build time is included. Results from a different host are not directly comparable to this record.

## Source and test inventory

The repository currently contains 70 MoonBit source and test files with 7,696 non-generated `.mbt` lines, excluding `_build` and `target` directories. The default and native test targets each pass 37 tests. These figures are measured from the working tree and are not estimates of generated code.

# moonbit-fhir

`moonbit-fhir` is a MoonBit-native toolkit for practical FHIR JSON processing. It combines structural validation, resource summaries, JSON-path-style queries, Bundle analysis, NDJSON batch inspection, profile rules, terminology checks, privacy transforms, quality metrics, and a small command-line interface.

The library is designed for ingestion gateways, ETL jobs, conformance checks, test fixtures, and interoperability services that need predictable behavior without pulling a full server stack into a MoonBit program.

## Requirements

MoonBit stable with `moonc v0.10.9` or newer. The repository CI checks this minimum before compiling the project.

## Core capabilities

- FHIR R4/R5-style resource detection and validation for common clinical, workflow, identity, and administrative resources.
- Bundle entry extraction, graph/reference analysis, transaction checks, and compact summaries.
- JSON Pointer and path queries with scalar, existence, count, and CSV-oriented results.
- NDJSON validation with line-level errors, success rates, resource-type counts, and issue statistics.
- Profile rules for required fields, primitive types, allowed values, and minimum collection sizes.
- Date, period, identifier, coding, reference, terminology, and quality-rule helpers.
- Canonical JSON, redaction policies, narrative tools, export pipelines, and resource metrics.
- Deterministic benchmark fixtures and scenario functions that can be reused from MoonBit tests.

## Quick start

```bash
moon check --deny-warn
moon test --deny-warn
moon run cmd/main -- --example patient
moon run cmd/main -- --example observation
moon run cmd/main -- --example bundle
```

Validate an inline resource:

```bash
moon run cmd/main -- --json '{"resourceType":"Observation","status":"final","code":{"text":"heart rate"}}'
```

Use the library from another MoonBit module:

```bash
moon add cxh123-alt/moonbit-fhir@0.2.1
```

Then import the package and call the validation, query, batch, and export APIs shown below.

## CLI

The `fhir-validate` example CLI is dependency-free and useful for smoke tests and small pipelines:

```text
--example patient|observation|bundle     validate a bundled fixture
--json '<resource JSON>'                 validate one resource
--summary '<resource JSON>'              print a compact summary
--query '<JSON>' '<path>'                count matching values
--ndjson '<line\nline>'                  validate an NDJSON payload
--benchmark <count>                      run deterministic in-process scenarios
```

## Library usage

```mbt check
///|
test "validate and query an Observation" {
  let value = parse_json(example_observation_json()).unwrap()
  let report = validate_resource(value)
  inspect(report.resource_type, content="Observation")
  inspect(is_valid(value), content="true")
  let result = query_result(value, "status")
  inspect(query_result_first_text(result), content="final")
}
```

The main entry points are `parse_json`, `validate_resource`, `validate_ndjson`, `validate_with_profile`, `query_result`, `bundle_graph_summary`, `resource_metrics`, `canonical_json`, and `redact_by_policy`. Public model and report types are defined in the root package and are available to downstream MoonBit modules through the module name `cxh123-alt/moonbit-fhir`.

## Architecture

The implementation is organized as small composable layers:

1. JSON access and resource detection provide safe field extraction.
2. Resource validators produce structured `ValidationReport` values.
3. Queries, summaries, profiles, terminology, dates, and quality rules build reusable domain operations.
4. Bundle, batch, privacy, export, and processing modules compose those operations for application workflows.
5. Fixtures, benchmark scenarios, and the CLI exercise the public surface end to end.

The package keeps parsing and transformation deterministic. It does not make network calls, store PHI, or claim conformance to every implementation guide. Applications should add their jurisdictional profiles, terminology servers, authorization, and audit retention policies where required.

## Benchmarks

Reproducible benchmark fixtures are in `benchmark_fixtures.mbt`; scenario definitions are in `benchmark_scenarios.mbt`. The benchmark measures actual library operations over generated Patient/Observation resources, Bundles, NDJSON, and search scans. Results and the measurement command are recorded in [docs/BENCHMARK.md](docs/BENCHMARK.md) and should be regenerated on a materially different machine or toolchain.

## Tests and CI

Run the local quality gate:

```bash
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon check --target native --deny-warn
moon test --target native --deny-warn
moon info
```

GitHub Actions runs the stable MoonBit toolchain on Ubuntu, macOS, and Windows, checks formatting and generated interface metadata, executes the full test suite, and runs native and coverage checks on Ubuntu. See `.github/workflows/test.yml`.

## Repository layout

```text
types.mbt / resource.mbt / validate.mbt     public model and validation core
json_access.mbt / pointer.mbt / path_*.mbt  safe traversal and query operations
summaries.mbt / resource_family_*.mbt       clinical and workflow summaries
profile_*.mbt / terminology_*.mbt            conformance helpers
bundle_*.mbt / ndjson_*.mbt                  batch and Bundle workflows
privacy_*.mbt / export_*.mbt / processing_*  data handling and export utilities
benchmark_*.mbt / *_test.mbt                 fixtures, measurements, and boundary tests
cmd/main                                      example CLI
docs                                          roadmap, sources, and benchmark record
```

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE).

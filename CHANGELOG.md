# Changelog

## 0.2.1

- Added integration coverage for text APIs, Bundle diagnostics, path operations, terminology, privacy, references, narratives, and service workflows.
- Added stable MoonBit compiler checks requiring `moonc v0.10.9` or newer across the test and publish workflows.
- Refreshed package metadata and documentation for the current FHIR interoperability surface.

## 0.2.0

- Added validation and summaries for broader clinical, workflow, identity, and administrative resource families.
- Added NDJSON reports, profile rules, terminology catalogs, date rules, Bundle analytics, reference resolution, quality metrics, and privacy/export helpers.
- Added deterministic benchmark fixtures, scenario reports, CLI summary/query/NDJSON/benchmark commands, and boundary regression tests.
- Added multi-platform stable-toolchain CI with native and coverage jobs.

## 0.1.0

- Added FHIR resource detection for Patient, Observation, Medication, DiagnosticReport, Encounter, and Bundle.
- Added structured validation reports with error and warning severities.
- Added Bundle entry extraction.
- Added JSON Pointer traversal.
- Added summary extraction and Observation CSV conversion.
- Added `fhir-validate` CLI entry point.
- Added examples, documentation, and CI.

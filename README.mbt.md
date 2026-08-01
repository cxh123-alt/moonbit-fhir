# moonbit-fhir

MoonBit healthcare interoperability toolkit for FHIR JSON resources.

`moonbit-fhir` focuses on the first practical layer that many clinical data exchange tools need: reading FHIR JSON, checking common structural rules, extracting useful summaries, traversing payloads with JSON Pointer, and validating Bundles from a small CLI.

## Scope

The current implementation targets FHIR R4/R5-style JSON resources and covers:

- `Patient`
- `Observation`
- `Medication`
- `DiagnosticReport`
- `Encounter`
- `Bundle`

It is intentionally lightweight. The library does not try to replace a full HL7 validator; instead it provides a MoonBit-native base that can grow toward profile validation, terminology checks, NDJSON streams, and richer conversions.

## Quick Start

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

## Library Usage

```mbt check
///|
test "validate an example Observation" {
  let value = parse_json(example_observation_json()).unwrap()
  let report = validate_resource(value)
  inspect(report.resource_type, content="Observation")
  inspect(is_valid(value), content="true")
}
```

```mbt check
///|
test "query a Bundle with JSON Pointer" {
  let bundle = parse_json(example_bundle_json()).unwrap()
  match json_pointer(bundle, "/entry/1/resource/resourceType") {
    Some(String(kind)) => inspect(kind, content="Observation")
    _ => fail("resourceType not found")
  }
}
```

## API Highlights

- `parse_json(text)` parses JSON into MoonBit `Json`.
- `validate_resource(value, version=R4)` returns a structured `ValidationReport`.
- `is_valid(value)` reports whether the resource has blocking errors.
- `bundle_entries(bundle)` extracts `fullUrl`, nested `resourceType`, and `id`.
- `json_pointer(value, pointer)` implements RFC 6901-style pointer traversal.
- `patient_summary`, `observation_summary`, `medication_summary`, `diagnostic_report_summary`, and `encounter_summary` flatten common fields for integration code.
- `observation_csv_row(value)` provides a small conversion example for data export.

## Repository Layout

```text
.
|-- types.mbt              # public model and report types
|-- json_access.mbt        # private JSON access helpers
|-- resource.mbt           # resource detection and Bundle parsing
|-- validate.mbt           # resource-level validation rules
|-- pointer.mbt            # JSON Pointer traversal
|-- summaries.mbt          # lightweight resource summaries and conversion
|-- examples.mbt           # bundled example resources
|-- cmd/main               # fhir-validate CLI
|-- docs                   # proposal, source notes, roadmap
`-- .github/workflows      # CI for MoonBit checks and tests
```

## Validation Policy

Errors are reserved for structural problems that break the declared resource shape, such as missing `resourceType`, missing `Observation.code`, or a malformed `Bundle.entry`.

Warnings are used for forward-compatible situations, such as resources outside the first supported set or unusual status values. This follows FHIR JSON's compatibility posture where later versions may introduce fields that older software can choose to ignore.

## Development

```bash
moon fmt
moon fmt --check
moon check --deny-warn
moon test --deny-warn
moon info
moon run cmd/main -- --example bundle
```

The project is released under Apache-2.0. See [docs/SOURCES.md](docs/SOURCES.md) for standards references and implementation boundaries.

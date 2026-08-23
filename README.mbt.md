# moonbit-fhir

MoonBit-native FHIR JSON validation and interoperability utilities.

## Quick start

```bash
moon check --deny-warn
moon test --deny-warn
moon run cmd/main -- --example patient
moon run cmd/main -- --json '{"resourceType":"Observation","status":"final","code":{"text":"heart rate"}}'
```

## API

The root package provides resource validation, Bundle and NDJSON processing, path queries, profile and terminology rules, canonicalization, privacy transforms, metrics, and deterministic benchmark fixtures.

```mbt check
///|
test "validate an Observation" {
  let value = parse_json(example_observation_json()).unwrap()
  inspect(is_valid(value), content="true")
}
```

See [README.md](README.md) for architecture, CLI commands, benchmark methodology, CI, and repository layout.

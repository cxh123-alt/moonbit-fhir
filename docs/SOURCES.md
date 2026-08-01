# Sources And Originality

## Standards References

- HL7 FHIR JSON representation: https://build.fhir.org/json.html
- FHIR published versions directory: https://hl7.org/fhir/directory.html
- RFC 6901 JSON Pointer: https://www.rfc-editor.org/rfc/rfc6901
- MoonBit package registry used for overlap checks: https://mooncakes.io

## Ecosystem Overlap Check

Searches on mooncakes.io and public web search for `FHIR`, `healthcare`, `medical`, `json pointer`, and adjacent MoonBit package names did not show a mature MoonBit FHIR toolkit with the same scope at the time this repository was prepared.

Nearby ecosystem packages exist for JSON handling and generic tooling, but this project's healthcare-specific resource validation, Bundle parsing, summaries, and CLI are implemented as a dedicated package.

## Implementation Boundary

This repository contains original MoonBit source code for:

- FHIR resource kind detection.
- R4/R5 validation report modeling.
- First-pass validators for Patient, Observation, Medication, DiagnosticReport, Encounter, and Bundle.
- JSON Pointer traversal.
- Resource summary extraction and a lightweight Observation CSV row converter.
- Example payloads and CLI entry point.

The FHIR names, resource names, and general JSON representation rules are standards facts from HL7. No HL7 source code or generated schemas are vendored in this repository.

## Known Limits

- It is not yet a complete StructureDefinition validator.
- Terminology bindings are checked only with small common value sets.
- XML, RDF, NDJSON, and profile-specific validation are planned future work.
- Decimal precision is preserved according to the underlying MoonBit JSON parser behavior; high-precision clinical decimal handling is a future extension.

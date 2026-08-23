# Sources And Originality

## Standards References

- HL7 FHIR JSON representation: https://build.fhir.org/json.html
- FHIR published versions directory: https://hl7.org/fhir/directory.html
- RFC 6901 JSON Pointer: https://www.rfc-editor.org/rfc/rfc6901
- MoonBit package registry used for overlap checks: https://mooncakes.io

## Ecosystem Overlap Check

The package is intentionally focused on a MoonBit-native FHIR processing layer. It does not vendor HL7 implementation code or generated StructureDefinitions; it composes general JSON operations with standards-derived resource and field rules.

Nearby ecosystem packages exist for JSON handling and generic tooling, but this project's healthcare-specific resource validation, Bundle parsing, summaries, and CLI are implemented as a dedicated package.

## Implementation Boundary

This repository contains original MoonBit source code for:

- FHIR resource kind detection.
- R4/R5 validation report modeling.
- Validators and summaries for clinical, workflow, identity, administrative, and Bundle resources.
- JSON Pointer and FHIRPath-inspired path traversal.
- NDJSON, profile, terminology, date, quality, privacy, and export helpers.
- Deterministic fixtures, benchmark scenarios, boundary tests, and CLI entry points.

The FHIR names, resource names, and general JSON representation rules are standards facts from HL7. No HL7 source code or generated schemas are vendored in this repository.

## Known Limits

- It is not yet a complete StructureDefinition validator.
- Terminology bindings are checked only with small common value sets.
- XML and RDF are outside the current JSON-focused scope.
- Profile-specific validation uses local rules; generated StructureDefinition support is planned.
- Decimal precision is preserved according to the underlying MoonBit JSON parser behavior; high-precision clinical decimal handling is a future extension.

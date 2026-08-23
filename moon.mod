// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "cxh123-alt/moonbit-fhir"

version = "0.2.0"

readme = "README.mbt.md"

repository = "https://github.com/cxh123-alt/moonbit-fhir"

license = "Apache-2.0"

keywords = [
  "fhir",
  "healthcare",
  "json",
  "interoperability",
  "validation",
  "ndjson",
  "terminology",
]

preferred_target = "wasm-gc"

description = "FHIR R4/R5 JSON validation, Bundle parsing, JSON Pointer query, summaries, and CLI tooling for MoonBit healthcare interoperability."

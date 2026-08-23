///|
fn report_has_error(report : ValidationReport) -> Bool {
  report.issues.any(fn(issue) { issue.severity == "error" })
}

///|
fn ndjson_error(line : Int, message : String, raw : String) -> NdjsonLineError {
  { line, message, raw }
}

///|
pub fn validate_ndjson(
  text : String,
  version? : FhirVersion = R4,
) -> NdjsonReport {
  let mut total = 0
  let mut blank = 0
  let mut valid = 0
  let mut invalid = 0
  let resources : Array[Json] = []
  let errors : Array[NdjsonLineError] = []
  for number, line_view in text.split("\n") {
    let line = line_view.to_owned()
    total += 1
    let trimmed = line.trim().to_owned()
    if trimmed == "" {
      blank += 1
    } else {
      match parse_json(trimmed) {
        None => {
          invalid += 1
          errors.push(ndjson_error(number + 1, "invalid JSON", line))
        }
        Some(value) => {
          let report = validate_resource(value, version~)
          if report_has_error(report) {
            invalid += 1
            errors.push(
              ndjson_error(number + 1, "FHIR validation failed", line),
            )
          } else {
            valid += 1
            resources.push(value)
          }
        }
      }
    }
  }
  {
    total_lines: total,
    blank_lines: blank,
    valid_lines: valid,
    invalid_lines: invalid,
    resources,
    errors,
  }
}

///|
pub fn validate_ndjson_lines(
  lines : Array[String],
  version? : FhirVersion = R4,
) -> NdjsonReport {
  validate_ndjson(lines.join("\n"), version~)
}

///|
pub fn ndjson_errors(
  text : String,
  version? : FhirVersion = R4,
) -> Array[NdjsonLineError] {
  validate_ndjson(text, version~).errors
}

///|
pub fn ndjson_resources(
  text : String,
  version? : FhirVersion = R4,
) -> Array[Json] {
  validate_ndjson(text, version~).resources
}

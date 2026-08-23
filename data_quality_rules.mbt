///|
pub(all) struct QualityFinding {
  rule : String
  severity : String
  path : String
  message : String
  score : Int
} derive(Debug, Eq, ToJson)

///|
fn finding(
  rule : String,
  severity : String,
  path : String,
  message : String,
  score : Int,
) -> QualityFinding {
  { rule, severity, path, message, score }
}

///|
pub fn quality_finding_count(value : Json) -> Int {
  quality_findings(value).length()
}

///|
pub fn quality_findings(value : Json) -> Array[QualityFinding] {
  let output : Array[QualityFinding] = []
  let kind = resource_type(value).unwrap_or("")
  if kind == "" {
    output.push(
      finding(
        "resource-type", "error", "/resourceType", "resourceType is missing", 0,
      ),
    )
  } else if !is_known_resource_type(kind) {
    output.push(
      finding(
        "resource-type", "warning", "/resourceType", "resource type is outside metadata catalog",
        2,
      ),
    )
  }
  for issue_item in resource_quality_report(value).issues {
    let score = if issue_item.severity == "error" { 0 } else { 2 }
    output.push(
      finding(
        issue_item.code,
        issue_item.severity,
        issue_item.path,
        issue_item.message,
        score,
      ),
    )
  }
  match resource_type(value) {
    Some("Observation") =>
      match observation_measurement(value) {
        Some(number) =>
          if number < 0.0 {
            output.push(
              finding(
                "negative-measurement", "warning", "/valueQuantity/value", "measurement is negative",
                1,
              ),
            )
          }
        None => ()
      }
    _ => ()
  }
  output
}

///|
pub fn quality_score(value : Json) -> Int {
  let findings = quality_findings(value)
  let penalty = findings.fold(init=0, fn(total, item) {
    total + (10 - item.score)
  })
  if penalty >= 100 {
    0
  } else {
    100 - penalty
  }
}

///|
pub fn quality_status(value : Json) -> String {
  let score = quality_score(value)
  if score >= 90 {
    "excellent"
  } else if score >= 70 {
    "acceptable"
  } else if score >= 40 {
    "needs-review"
  } else {
    "rejected"
  }
}

///|
pub fn batch_quality_findings(values : Array[Json]) -> Array[QualityFinding] {
  values.fold(init=[], fn(output, value) {
    output.append(quality_findings(value)[:])
    output
  })
}

///|
pub fn batch_quality_score_average(values : Array[Json]) -> Int {
  if values.length() == 0 {
    100
  } else {
    values.fold(init=0, fn(total, value) { total + quality_score(value) }) /
    values.length()
  }
}

///|
pub fn validate_temporal_consistency(value : Json) -> Array[Issue] {
  let output : Array[Issue] = []
  let start = query_text(value, "period.start", fallback="")
  let end = query_text(value, "period.end", fallback="")
  if start != "" && end != "" && !period_is_valid(start, end) {
    output.push(
      issue("/period", "value", "period.start must be before period.end"),
    )
  }
  let birth = query_text(value, "birthDate", fallback="")
  let issued = query_text(value, "issued", fallback="")
  if birth != "" && issued != "" && date_is_after(birth, issued) {
    output.push(
      issue("/birthDate", "value", "birthDate must not be after issued"),
    )
  }
  output
}

///|
pub fn validate_reference_targets(
  value : Json,
  values : Array[Json],
) -> Array[Issue] {
  unresolved_references(value, values).map(fn(reference) {
    issue(
      "",
      "reference",
      "reference target is not present: \{reference}",
      severity="warning",
    )
  })
}

///|
pub fn complete_quality_report(
  value : Json,
  values : Array[Json],
) -> ValidationReport {
  let report = resource_quality_report(value)
  report.issues.append(validate_temporal_consistency(value)[:])
  report.issues.append(validate_reference_targets(value, values)[:])
  report
}

///|
pub fn complete_quality_is_valid(value : Json, values : Array[Json]) -> Bool {
  report_error_count(complete_quality_report(value, values)) == 0
}

///|
pub fn quality_dashboard_rows(values : Array[Json]) -> Array[String] {
  values.map(fn(value) {
    csv_row([
      resource_type(value).unwrap_or(""),
      field_string(value, "id").unwrap_or(""),
      quality_status(value),
      "\{quality_score(value)}",
      "\{quality_finding_count(value)}",
    ])
  })
}

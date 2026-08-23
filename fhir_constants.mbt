///|
pub(all) enum ValidationMode {
  Lenient
  Standard
  Strict
} derive(Debug, Eq, ToJson)

///|
pub fn validation_mode_name(mode : ValidationMode) -> String {
  match mode {
    Lenient => "lenient"
    Standard => "standard"
    Strict => "strict"
  }
}

///|
pub fn validation_mode_rejects_warnings(mode : ValidationMode) -> Bool {
  mode is Strict
}

///|
pub fn validation_mode_options(mode : ValidationMode) -> ProcessingOptions {
  match mode {
    Lenient => ProcessingOptions::default()
    Standard => ProcessingOptions::default()
    Strict => ProcessingOptions::strict()
  }
}

///|
pub fn severity_rank(severity : String) -> Int {
  match severity {
    "error" => 3
    "warning" => 2
    "info" => 1
    _ => 0
  }
}

///|
pub fn issue_sort_key(item : Issue) -> String {
  "\{severity_rank(item.severity)}|\{item.path}|\{item.code}"
}

///|
pub fn sort_issues(issues : Array[Issue]) -> Array[Issue] {
  let output = issues.map(fn(item) { item })
  output.sort_by(fn(left, right) {
    String::compare(issue_sort_key(right), issue_sort_key(left))
  })
  output
}

///|
pub fn sorted_report(report : ValidationReport) -> ValidationReport {
  { ..report, issues: sort_issues(report.issues) }
}

///|
pub fn version_supports(version : FhirVersion, kind : String) -> Bool {
  match version {
    R4 => kind == "Patient" || kind == "Observation" || kind == "Bundle"
    R5 => is_known_resource_type(kind)
  }
}

///|
pub fn version_name(version : FhirVersion) -> String {
  version.to_string()
}

///|
pub fn resource_version_warning(value : Json, version : FhirVersion) -> Issue? {
  let kind = resource_type(value).unwrap_or("")
  if kind != "" && !version_supports(version, kind) {
    Some(
      issue(
        "/resourceType",
        "version",
        "\{kind} is not in the configured \{version.to_string()} support set",
        severity="warning",
      ),
    )
  } else {
    None
  }
}

///|
pub fn versioned_validate(
  value : Json,
  version : FhirVersion,
) -> ValidationReport {
  let report = validate_resource(value, version~)
  match resource_version_warning(value, version) {
    Some(item) => {
      report.issues.push(item)
      report
    }
    None => report
  }
}

///|
pub fn validation_mode_summary(
  mode : ValidationMode,
  version : FhirVersion,
) -> String {
  "\{validation_mode_name(mode)} / \{version.to_string()}"
}

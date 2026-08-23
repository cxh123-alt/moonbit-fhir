///|
pub(all) struct ReportDelta {
  added : Int
  removed : Int
  unchanged : Int
  added_codes : Array[String]
  removed_codes : Array[String]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ResourceDiff {
  added_fields : Array[String]
  removed_fields : Array[String]
  changed_fields : Array[String]
} derive(Debug, Eq, ToJson)

///|
fn issue_key(item : Issue) -> String {
  "\{item.path}|\{item.code}|\{item.severity}|\{item.message}"
}

///|
pub fn report_error_count(report : ValidationReport) -> Int {
  report.issues.count_if(fn(item) { item.severity == "error" })
}

///|
pub fn report_warning_count(report : ValidationReport) -> Int {
  report.issues.count_if(fn(item) { item.severity == "warning" })
}

///|
pub fn report_info_count(report : ValidationReport) -> Int {
  report.issues.count_if(fn(item) { item.severity == "info" })
}

///|
pub fn report_is_warning_only(report : ValidationReport) -> Bool {
  report_error_count(report) == 0 && report_warning_count(report) > 0
}

///|
pub fn report_is_clean(report : ValidationReport) -> Bool {
  report.issues.length() == 0
}

///|
pub fn issue_fingerprints(report : ValidationReport) -> Array[String] {
  report.issues.map(issue_key)
}

///|
pub fn compare_reports(
  before : ValidationReport,
  after : ValidationReport,
) -> ReportDelta {
  let before_keys = issue_fingerprints(before)
  let after_keys = issue_fingerprints(after)
  let added_codes : Array[String] = []
  let removed_codes : Array[String] = []
  for key in after_keys {
    if !before_keys.contains(key) {
      added_codes.push(key)
    }
  }
  for key in before_keys {
    if !after_keys.contains(key) {
      removed_codes.push(key)
    }
  }
  let unchanged = after_keys.length() - added_codes.length()
  {
    added: added_codes.length(),
    removed: removed_codes.length(),
    unchanged,
    added_codes,
    removed_codes,
  }
}

///|
pub fn merge_validation_reports(
  reports : Array[ValidationReport],
) -> ValidationReport {
  let issues : Array[Issue] = []
  let resource_type = reports
    .get(0)
    .map(fn(report) { report.resource_type })
    .unwrap_or("")
  let version = reports.get(0).map(fn(report) { report.version }).unwrap_or(R4)
  for report in reports {
    issues.append(report.issues[:])
  }
  { resource_type, version, issues }
}

///|
pub fn report_json(report : ValidationReport) -> Json {
  Json::object(
    Map([
      ("resourceType", Json::string(report.resource_type)),
      ("version", Json::string(report.version.to_string())),
      ("errorCount", Json::number(report_error_count(report).to_double())),
      ("warningCount", Json::number(report_warning_count(report).to_double())),
      ("issues", Json::array(report.issues.map(fn(item) { Json::Json(item) }))),
    ]),
  )
}

///|
pub fn report_text(report : ValidationReport) -> String {
  let status = if report_error_count(report) == 0 { "valid" } else { "invalid" }
  "\{report.resource_type} \{status}: errors=\{report_error_count(report)} warnings=\{report_warning_count(report)}"
}

///|
pub fn resource_diff(before : Json, after : Json) -> ResourceDiff {
  let before_fields = json_object_keys(before)
  let after_fields = json_object_keys(after)
  let added = after_fields.filter(fn(field) { !before_fields.contains(field) })
  let removed = before_fields.filter(fn(field) { !after_fields.contains(field) })
  let changed : Array[String] = []
  for field in before_fields {
    match query_first(before, field) {
      None => ()
      Some(left) =>
        match query_first(after, field) {
          Some(right) => if !Json::equal(left, right) { changed.push(field) }
          None => ()
        }
    }
  }
  { added_fields: added, removed_fields: removed, changed_fields: changed }
}

///|
pub fn resource_diff_count(before : Json, after : Json) -> Int {
  let diff = resource_diff(before, after)
  diff.added_fields.length() +
  diff.removed_fields.length() +
  diff.changed_fields.length()
}

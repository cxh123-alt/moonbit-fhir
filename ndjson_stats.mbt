///|
fn increment_count(map : Map[String, Int], key : String) -> Unit {
  map[key] = map.get(key).unwrap_or(0) + 1
}

///|
pub fn ndjson_statistics(report : NdjsonReport) -> NdjsonStatistics {
  let type_counts : Map[String, Int] = Map([])
  let issue_counts : Map[String, Int] = Map([])
  for value in report.resources {
    increment_count(type_counts, resource_type(value).unwrap_or(""))
    let validation = validate_resource(value)
    for item in validation.issues {
      increment_count(issue_counts, item.code)
    }
  }
  {
    resource_count: report.resources.length(),
    valid_count: report.valid_lines,
    invalid_count: report.invalid_lines,
    blank_count: report.blank_lines,
    type_counts,
    issue_counts,
  }
}

///|
pub fn ndjson_summary(report : NdjsonReport) -> String {
  let stats = ndjson_statistics(report)
  "lines=\{report.total_lines} valid=\{stats.valid_count} invalid=\{stats.invalid_count} blank=\{stats.blank_count} resources=\{stats.resource_count} success=\{report.success_rate()}%"
}

///|
pub fn ndjson_type_count(report : NdjsonReport, kind : String) -> Int {
  ndjson_statistics(report).type_counts.get(kind).unwrap_or(0)
}

///|
pub fn ndjson_issue_count(report : NdjsonReport, code : String) -> Int {
  let stats = ndjson_statistics(report)
  stats.issue_counts.get(code).unwrap_or(0)
}

///|
pub fn ndjson_partition(
  report : NdjsonReport,
) -> (Array[Json], Array[NdjsonLineError]) {
  (report.resources, report.errors)
}

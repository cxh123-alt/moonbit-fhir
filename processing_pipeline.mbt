///|
pub(all) struct ProcessingOptions {
  version : FhirVersion
  profile : Profile?
  privacy_policy : PrivacyPolicy?
  reject_warnings : Bool
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ProcessingResult {
  reports : Array[ValidationReport]
  accepted : Array[Json]
  rejected : Array[Json]
  redacted : Array[Json]
  quality : BatchQuality
} derive(Debug, Eq, ToJson)

///|
pub fn ProcessingOptions::default() -> ProcessingOptions {
  { version: R4, profile: None, privacy_policy: None, reject_warnings: false }
}

///|
pub fn ProcessingOptions::strict() -> ProcessingOptions {
  {
    version: R4,
    profile: None,
    privacy_policy: Some(PrivacyPolicy::strict()),
    reject_warnings: true,
  }
}

///|
fn pipeline_report(
  value : Json,
  options : ProcessingOptions,
) -> ValidationReport {
  match options.profile {
    None => validate_resource(value, version=options.version)
    Some(profile) =>
      validate_with_profile(value, profile, version=options.version)
  }
}

///|
pub fn process_resources(
  values : Array[Json],
  options : ProcessingOptions,
) -> ProcessingResult {
  let reports : Array[ValidationReport] = []
  let accepted : Array[Json] = []
  let rejected : Array[Json] = []
  let redacted : Array[Json] = []
  for value in values {
    let report = pipeline_report(value, options)
    reports.push(report)
    let has_error = report_error_count(report) > 0
    let has_warning = report_warning_count(report) > 0
    if has_error || (options.reject_warnings && has_warning) {
      rejected.push(value)
    } else {
      accepted.push(value)
      match options.privacy_policy {
        None => ()
        Some(policy) => redacted.push(redact_by_policy(value, policy))
      }
    }
  }
  { reports, accepted, rejected, redacted, quality: batch_quality(values) }
}

///|
pub fn process_ndjson(
  text : String,
  options : ProcessingOptions,
) -> ProcessingResult {
  let input = validate_ndjson(text, version=options.version).resources
  process_resources(input, options)
}

///|
pub fn processing_is_successful(result : ProcessingResult) -> Bool {
  result.rejected.length() == 0
}

///|
pub fn processing_error_count(result : ProcessingResult) -> Int {
  result.reports.fold(init=0, fn(total, report) {
    total + report_error_count(report)
  })
}

///|
pub fn processing_warning_count(result : ProcessingResult) -> Int {
  result.reports.fold(init=0, fn(total, report) {
    total + report_warning_count(report)
  })
}

///|
pub fn processing_summary(result : ProcessingResult) -> String {
  "input=\{result.quality.total} accepted=\{result.accepted.length()} rejected=\{result.rejected.length()} errors=\{processing_error_count(result)} warnings=\{processing_warning_count(result)}"
}

///|
pub fn processing_export(
  result : ProcessingResult,
  options : ExportOptions,
) -> String {
  export_resources(result.accepted, options)
}

///|
pub fn processing_redacted_export(
  result : ProcessingResult,
  options : ExportOptions,
) -> String {
  export_resources(result.redacted, options)
}

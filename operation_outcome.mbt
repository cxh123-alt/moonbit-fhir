///|
pub(all) struct OperationOutcomeIssue {
  severity : String
  code : String
  diagnostics : String
  location : Array[String]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct OperationOutcome {
  resource_type : String
  issues : Array[OperationOutcomeIssue]
} derive(Debug, Eq, ToJson)

///|
fn outcome_issue(item : Issue) -> OperationOutcomeIssue {
  {
    severity: item.severity,
    code: item.code,
    diagnostics: item.message,
    location: [item.path],
  }
}

///|
pub fn operation_outcome(report : ValidationReport) -> OperationOutcome {
  {
    resource_type: report.resource_type,
    issues: report.issues.map(outcome_issue),
  }
}

///|
pub fn operation_outcome_from_text(text : String) -> OperationOutcome {
  match parse_json(text) {
    None =>
      {
        resource_type: "",
        issues: [
          {
            severity: "error",
            code: "invalid",
            diagnostics: "invalid JSON input",
            location: [],
          },
        ],
      }
    Some(value) => operation_outcome(validate_resource(value))
  }
}

///|
pub fn operation_outcome_error_count(outcome : OperationOutcome) -> Int {
  outcome.issues.count_if(fn(item) { item.severity == "error" })
}

///|
pub fn operation_outcome_warning_count(outcome : OperationOutcome) -> Int {
  outcome.issues.count_if(fn(item) { item.severity == "warning" })
}

///|
pub fn operation_outcome_is_success(outcome : OperationOutcome) -> Bool {
  operation_outcome_error_count(outcome) == 0
}

///|
pub fn operation_outcome_json(outcome : OperationOutcome) -> Json {
  Json::Json(outcome)
}

///|
pub fn operation_outcome_text(outcome : OperationOutcome) -> String {
  let status = if operation_outcome_is_success(outcome) {
    "success"
  } else {
    "failure"
  }
  "\{outcome.resource_type} \{status}: errors=\{operation_outcome_error_count(outcome)} warnings=\{operation_outcome_warning_count(outcome)}"
}

///|
pub fn operation_outcome_locations(outcome : OperationOutcome) -> Array[String] {
  outcome.issues.fold(init=[], fn(output, item) {
    output.append(item.location[:])
    output
  })
}

///|
pub fn operation_outcome_codes(outcome : OperationOutcome) -> Array[String] {
  outcome.issues.map(fn(item) { item.code })
}

///|
pub fn operation_outcome_has_code(
  outcome : OperationOutcome,
  code : String,
) -> Bool {
  operation_outcome_codes(outcome).contains(code)
}

///|
pub fn operation_exit_status(outcome : OperationOutcome) -> Int {
  if operation_outcome_is_success(outcome) {
    0
  } else {
    1
  }
}

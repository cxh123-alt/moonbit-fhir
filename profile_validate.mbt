///|
fn profile_path(path : String) -> String {
  if path.has_prefix("/") {
    path
  } else {
    "\/{path}"
  }
}

///|
fn profile_type_matches(value : Json, expected : String) -> Bool {
  match expected {
    "object" => value is Object(_)
    "array" => value is Array(_)
    "string" => value is String(_)
    "number" => value is Number(_, ..)
    "boolean" =>
      match value {
        True | False => true
        _ => false
      }
    "null" => value is Null
    _ => false
  }
}

///|
fn profile_rule_issues(
  issues : Array[Issue],
  value : Json,
  rule : ProfileRule,
) -> Unit {
  match rule {
    Required(path) =>
      if query_first(value, path) is None {
        issues.push(
          issue(
            profile_path(path),
            "required",
            "profile field \{path} is required",
          ),
        )
      }
    Type(path, expected) =>
      match query_first(value, path) {
        None => ()
        Some(actual) =>
          if !profile_type_matches(actual, expected) {
            issues.push(
              issue(
                profile_path(path),
                "type",
                "profile field \{path} must be a \{expected}",
              ),
            )
          }
      }
    Allowed(path, allowed) =>
      match query_first(value, path) {
        None => ()
        Some(actual) =>
          match as_scalar_text(actual) {
            None =>
              issues.push(
                issue(
                  profile_path(path),
                  "type",
                  "profile allowed values require a scalar field",
                ),
              )
            Some(text) =>
              if !allowed.contains(text) {
                issues.push(
                  issue(
                    profile_path(path),
                    "value",
                    "profile field \{path} is outside the allowed values",
                  ),
                )
              }
          }
      }
    MinItems(path, minimum) => {
      let count = query_values(value, path).length()
      if count < minimum {
        issues.push(
          issue(
            profile_path(path),
            "required",
            "profile field \{path} must contain at least \{minimum} item(s)",
          ),
        )
      }
    }
  }
}

///|
pub fn validate_with_profile(
  value : Json,
  profile : Profile,
  version? : FhirVersion = R4,
) -> ValidationReport {
  let report = validate_resource(value, version~)
  for rule in profile.rules {
    profile_rule_issues(report.issues, value, rule)
  }
  report
}

///|
pub fn validate_profile_only(
  value : Json,
  profile : Profile,
) -> ValidationReport {
  let report = {
    resource_type: resource_type(value).unwrap_or(""),
    version: R4,
    issues: [],
  }
  for rule in profile.rules {
    profile_rule_issues(report.issues, value, rule)
  }
  report
}

///|
pub fn profile_is_valid(value : Json, profile : Profile) -> Bool {
  let report = validate_with_profile(value, profile)
  !report.issues.any(fn(item) { item.severity == "error" })
}

///|
pub fn profile_issue_count(value : Json, profile : Profile) -> Int {
  validate_with_profile(value, profile).issues.length()
}

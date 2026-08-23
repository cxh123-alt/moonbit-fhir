///|
pub fn terminology_contains(value_set : ValueSet, code : String) -> Bool {
  value_set.contains(code)
}

///|
pub fn validate_code(
  path : String,
  system : String?,
  code : String,
  value_set : ValueSet,
) -> TerminologyIssue? {
  let system_matches = match value_set.system {
    None => true
    Some(expected) =>
      match system {
        Some(actual) => expected == actual
        None => false
      }
  }
  if system_matches && !value_set.contains(code) {
    Some({
      path,
      system,
      code,
      message: "code is not in value set \{value_set.name}",
    })
  } else if !system_matches {
    Some({
      path,
      system,
      code,
      message: "coding system does not match value set \{value_set.name}",
    })
  } else {
    None
  }
}

///|
pub fn validate_codeable_concept(
  value : Json,
  path : String,
  value_set : ValueSet,
) -> Array[TerminologyIssue] {
  let output : Array[TerminologyIssue] = []
  match object_get(value, "coding") {
    Some(Array(codings)) =>
      for index, coding in codings {
        let code = field_string(coding, "code")
        match code {
          None =>
            output.push({
              path: "\{path}/coding/\{index}/code",
              system: None,
              code: "",
              message: "coding.code is required",
            })
          Some(code) =>
            match
              validate_code(
                "\{path}/coding/\{index}/code",
                field_string(coding, "system"),
                code,
                value_set,
              ) {
              Some(issue) => output.push(issue)
              None => ()
            }
        }
      }
    Some(_) =>
      output.push({
        path,
        system: None,
        code: "",
        message: "coding must be an array",
      })
    None =>
      match field_string(value, "text") {
        Some(_) => ()
        None =>
          output.push({
            path,
            system: None,
            code: "",
            message: "codeable concept needs coding or text",
          })
      }
  }
  output
}

///|
pub fn terminology_issue_summary(issues : Array[TerminologyIssue]) -> String {
  if issues.length() == 0 {
    "no terminology issues"
  } else {
    "\{issues.length()} terminology issue(s)"
  }
}

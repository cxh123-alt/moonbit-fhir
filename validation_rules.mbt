///|
fn number_value(value : Json) -> Double? {
  match value {
    Number(number, ..) => Some(number)
    _ => None
  }
}

///|
pub fn number_at(value : Json, path : String) -> Double? {
  match query_first(value, path) {
    Some(item) => number_value(item)
    None => None
  }
}

///|
pub fn quantity_is_reasonable(
  value : Json,
  path : String,
  minimum : Double,
  maximum : Double,
) -> Bool {
  match number_at(value, "\{path}.value") {
    Some(number) => number >= minimum && number <= maximum
    None => false
  }
}

///|
pub fn quantity_unit(value : Json, path : String) -> String? {
  query_first(value, "\{path}.unit").map(fn(item) {
    as_scalar_text(item).unwrap_or("")
  })
}

///|
pub fn quantity_system(value : Json, path : String) -> String? {
  field_string(
    query_first(value, path).unwrap_or(Json::empty_object()),
    "system",
  )
}

///|
pub fn reference_is_well_formed(reference : String) -> Bool {
  if reference == "" || reference.contains(" ") {
    false
  } else if reference.has_prefix("http://") ||
    reference.has_prefix("https://") ||
    reference.has_prefix("urn:") {
    true
  } else {
    match reference.find("/") {
      Some(index) => index > 0 && index < reference.length() - 1
      None => false
    }
  }
}

///|
pub fn reference_resource_type(reference : String) -> String? {
  if reference_is_well_formed(reference) {
    match reference.find("/") {
      Some(index) => Some(reference[0:index].to_owned())
      None => None
    }
  } else {
    None
  }
}

///|
pub fn reference_resource_id(reference : String) -> String? {
  if reference_is_well_formed(reference) {
    match reference.rev_find("/") {
      Some(index) => Some(reference[index + 1:].to_owned())
      None => None
    }
  } else {
    None
  }
}

///|
pub fn validate_reference(value : Json, path : String) -> Array[Issue] {
  let output : Array[Issue] = []
  for index, reference in query_strings(value, "\{path}[*].reference") {
    if !reference_is_well_formed(reference) {
      output.push(
        issue(
          "\{path}/\{index}/reference",
          "value",
          "reference is not well formed",
        ),
      )
    }
  }
  let direct = query_text(value, "\{path}.reference", fallback="")
  if direct != "" && !reference_is_well_formed(direct) {
    output.push(
      issue("/\{path}/reference", "value", "reference is not well formed"),
    )
  }
  output
}

///|
pub fn validate_date_field(
  value : Json,
  path : String,
  datetime? : Bool = true,
) -> Array[Issue] {
  let output : Array[Issue] = []
  let text = query_text(value, path, fallback="")
  if text != "" {
    let valid = if datetime {
      is_valid_fhir_datetime(text)
    } else {
      is_valid_fhir_date(text)
    }
    if !valid {
      output.push(
        issue("/\{path}", "value", "date value is not a valid FHIR date"),
      )
    }
  }
  output
}

///|
pub fn validate_period(value : Json, path : String) -> Array[Issue] {
  let output : Array[Issue] = []
  let start = query_text(value, "\{path}.start", fallback="")
  let end = query_text(value, "\{path}.end", fallback="")
  if !period_is_valid(start, end) {
    output.push(
      issue("/\{path}", "value", "period boundaries are invalid or reversed"),
    )
  }
  output
}

///|
pub fn validate_identifier_array(
  value : Json,
  path? : String = "identifier",
) -> Array[Issue] {
  let output : Array[Issue] = []
  match query_first(value, path) {
    None => ()
    Some(Array(items)) =>
      for index, item in items {
        match field_string(item, "value") {
          Some(text) =>
            if text == "" {
              output.push(
                issue(
                  "/\{path}/\{index}/value",
                  "empty",
                  "identifier.value must not be empty",
                ),
              )
            }
          None =>
            output.push(
              issue(
                "/\{path}/\{index}/value",
                "required",
                "identifier.value is required",
              ),
            )
        }
        match field_string(item, "system") {
          Some(system) =>
            if system.contains(" ") {
              output.push(
                issue(
                  "/\{path}/\{index}/system",
                  "value",
                  "identifier.system must not contain spaces",
                ),
              )
            }
          None => ()
        }
      }
    Some(_) =>
      output.push(issue("/\{path}", "type", "identifier must be an array"))
  }
  output
}

///|
pub fn validate_coding_array(value : Json, path : String) -> Array[Issue] {
  let output : Array[Issue] = []
  match query_first(value, path) {
    None => ()
    Some(Array(items)) =>
      for index, item in items {
        match field_string(item, "code") {
          Some(code) =>
            if code == "" {
              output.push(
                issue(
                  "/\{path}/\{index}/code",
                  "empty",
                  "coding.code must not be empty",
                ),
              )
            }
          None =>
            output.push(
              issue(
                "/\{path}/\{index}/code",
                "required",
                "coding.code is required",
              ),
            )
        }
      }
    Some(_) => output.push(issue("/\{path}", "type", "coding must be an array"))
  }
  output
}

///|
pub fn validate_reference_fields(
  value : Json,
  paths : Array[String],
) -> Array[Issue] {
  let output : Array[Issue] = []
  for path in paths {
    output.append(validate_reference(value, path)[:])
  }
  output
}

///|
pub fn validate_date_fields(
  value : Json,
  paths : Array[String],
) -> Array[Issue] {
  let output : Array[Issue] = []
  for path in paths {
    output.append(validate_date_field(value, path)[:])
  }
  output
}

///|
pub fn resource_quality_issues(value : Json) -> Array[Issue] {
  let output : Array[Issue] = []
  output.append(validate_identifier_array(value)[:])
  output.append(
    validate_reference_fields(value, ["subject", "patient", "encounter"])[:],
  )
  output.append(
    validate_date_fields(value, [
      "birthDate", "issued", "performedDateTime", "occurrenceDateTime",
    ])[:],
  )
  output
}

///|
pub fn resource_quality_report(value : Json) -> ValidationReport {
  let report = validate_resource(value)
  report.issues.append(resource_quality_issues(value)[:])
  report
}

///|
pub fn resource_quality_is_valid(value : Json) -> Bool {
  !resource_quality_report(value).issues.any(fn(item) {
    item.severity == "error"
  })
}

///|
pub fn resource_issue_codes(value : Json) -> Array[String] {
  resource_quality_report(value).issues.map(fn(item) { item.code })
}

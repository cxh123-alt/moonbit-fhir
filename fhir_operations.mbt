///|
pub(all) struct ResourcePatch {
  path : String
  value : Json?
  remove : Bool
} derive(Debug, Eq, ToJson)

///|
pub(all) struct OperationResult {
  success : Bool
  resource : Json
  issues : Array[Issue]
} derive(Debug, Eq, ToJson)

///|
pub fn ResourcePatch::set(path : String, value : Json) -> ResourcePatch {
  { path, value: Some(value), remove: false }
}

///|
pub fn ResourcePatch::remove(path : String) -> ResourcePatch {
  { path, value: None, remove: true }
}

///|
pub fn resource_set_field(
  value : Json,
  field : String,
  replacement : Json,
) -> Json {
  match value {
    Object(fields) => {
      fields[field] = replacement
      Json::object(fields)
    }
    _ => value
  }
}

///|
pub fn resource_remove_field(value : Json, field : String) -> Json {
  match value {
    Object(fields) => {
      fields.remove(field)
      Json::object(fields)
    }
    _ => value
  }
}

///|
pub fn apply_resource_patch(value : Json, patch : ResourcePatch) -> Json {
  if patch.remove {
    resource_remove_field(value, patch.path)
  } else {
    match patch.value {
      Some(replacement) => resource_set_field(value, patch.path, replacement)
      None => value
    }
  }
}

///|
pub fn apply_resource_patches(
  value : Json,
  patches : Array[ResourcePatch],
) -> Json {
  patches.fold(init=value, fn(current, patch) {
    apply_resource_patch(current, patch)
  })
}

///|
pub fn update_resource_status(value : Json, status : String) -> Json {
  resource_set_field(value, "status", Json::string(status))
}

///|
pub fn update_resource_id(value : Json, id : String) -> Json {
  resource_set_field(value, "id", Json::string(id))
}

///|
pub fn operation_validate(value : Json, profile? : Profile) -> OperationResult {
  let report = match profile {
    None => validate_resource(value)
    Some(profile) => validate_with_profile(value, profile)
  }
  {
    success: report_error_count(report) == 0,
    resource: value,
    issues: report.issues,
  }
}

///|
pub fn operation_normalize(value : Json) -> OperationResult {
  { success: true, resource: canonical_resource(value), issues: [] }
}

///|
pub fn operation_redact(
  value : Json,
  policy : PrivacyPolicy,
) -> OperationResult {
  { success: true, resource: redact_by_policy(value, policy), issues: [] }
}

///|
pub fn upsert_resource(values : Array[Json], value : Json) -> Array[Json] {
  let output : Array[Json] = []
  let target = bundle_reference_key(value)
  let mut replaced = false
  for existing in values {
    if target is Some(key) && bundle_reference_key(existing) == Some(key) {
      output.push(value)
      replaced = true
    } else {
      output.push(existing)
    }
  }
  if !replaced {
    output.push(value)
  }
  output
}

///|
pub fn delete_resource(
  values : Array[Json],
  kind : String,
  id : String,
) -> Array[Json] {
  values.filter(fn(value) {
    !(resource_type(value) == Some(kind) &&
    field_string(value, "id") == Some(id))
  })
}

///|
pub fn find_or_create_resource(
  values : Array[Json],
  kind : String,
  id : String,
) -> (Array[Json], Json) {
  match find_first_resource(values, kind, id) {
    Some(value) => (values, value)
    None => {
      let value = Json::object(
        Map([("resourceType", Json::string(kind)), ("id", Json::string(id))]),
      )
      (upsert_resource(values, value), value)
    }
  }
}

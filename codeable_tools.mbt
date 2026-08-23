///|
pub(all) struct CodingRecord {
  system : String?
  code : String?
  display : String?
  version : String?
  user_selected : Bool?
} derive(Debug, Eq, ToJson)

///|
pub fn coding_record(value : Json) -> CodingRecord {
  {
    system: field_string(value, "system"),
    code: field_string(value, "code"),
    display: field_string(value, "display"),
    version: field_string(value, "version"),
    user_selected: match object_get(value, "userSelected") {
      Some(True) => Some(true)
      Some(False) => Some(false)
      _ => None
    },
  }
}

///|
pub fn codeable_codings(value : Json) -> Array[CodingRecord] {
  field_array(value, "coding").unwrap_or([]).map(coding_record)
}

///|
pub fn codeable_codes(value : Json) -> Array[String] {
  codeable_codings(value).filter_map(fn(coding) { coding.code })
}

///|
pub fn codeable_systems(value : Json) -> Array[String] {
  codeable_codings(value).filter_map(fn(coding) { coding.system })
}

///|
pub fn codeable_displays(value : Json) -> Array[String] {
  codeable_codings(value).filter_map(fn(coding) { coding.display })
}

///|
pub fn codeable_has_code(value : Json, code : String) -> Bool {
  codeable_codes(value).contains(code)
}

///|
pub fn codeable_has_system_code(
  value : Json,
  system : String,
  code : String,
) -> Bool {
  codeable_codings(value).any(fn(coding) {
    coding.system == Some(system) && coding.code == Some(code)
  })
}

///|
pub fn codeable_find_code(value : Json, system : String) -> String? {
  codeable_codings(value)
  .filter(fn(coding) { coding.system == Some(system) })
  .filter_map(fn(coding) { coding.code })
  .get(0)
}

///|
pub fn codeable_primary_display(value : Json) -> String? {
  match field_string(value, "text") {
    Some(text) => Some(text)
    None => codeable_displays(value).get(0)
  }
}

///|
pub fn codeable_is_empty(value : Json) -> Bool {
  codeable_codes(value).length() == 0 && field_string(value, "text") is None
}

///|
pub fn codeable_merge(left : Json, right : Json) -> Json {
  let merged = json_merge(left, right)
  if codeable_is_empty(merged) {
    left
  } else {
    merged
  }
}

///|
pub fn codeable_summary(value : Json) -> String {
  let display = codeable_primary_display(value).unwrap_or("")
  let codes = codeable_codes(value).join(",")
  if display == "" {
    codes
  } else if codes == "" {
    display
  } else {
    "\{display} [\{codes}]"
  }
}

///|
pub fn resource_codings(value : Json, path : String) -> Array[CodingRecord] {
  query_values(value, path).map(codeable_codings).flatten()
}

///|
pub fn resource_codes(value : Json, path : String) -> Array[String] {
  resource_codings(value, path).filter_map(fn(coding) { coding.code })
}

///|
pub fn resource_has_code(value : Json, path : String, code : String) -> Bool {
  resource_codes(value, path).contains(code)
}

///|
pub fn resource_code_system(
  value : Json,
  path : String,
  system : String,
) -> Bool {
  resource_codings(value, path).any(fn(coding) { coding.system == Some(system) })
}

///|
pub fn resource_type_or(value : Json, fallback : String) -> String {
  resource_type(value).unwrap_or(fallback)
}

///|
pub fn resource_id_or(value : Json, fallback : String) -> String {
  field_string(value, "id").unwrap_or(fallback)
}

///|
pub fn resource_status_or(value : Json, fallback : String) -> String {
  resource_status(value).unwrap_or(fallback)
}

///|
pub fn resource_key(value : Json) -> String {
  match bundle_reference_key(value) {
    Some(key) => key
    None => resource_type_or(value, "Unknown") + "/"
  }
}

///|
pub fn resource_label(value : Json) -> String {
  let kind = resource_type_or(value, "FHIR")
  let id = resource_id_or(value, "")
  if id == "" {
    kind
  } else {
    "\{kind}/\{id}"
  }
}

///|
pub fn resource_kind_is_clinical(value : Json) -> Bool {
  resource_category(resource_type_or(value, "")) == Clinical
}

///|
pub fn resource_kind_is_workflow(value : Json) -> Bool {
  resource_category(resource_type_or(value, "")) == Workflow
}

///|
pub fn resource_kind_is_exchange(value : Json) -> Bool {
  resource_category(resource_type_or(value, "")) == Exchange
}

///|
pub fn resource_kind_names(values : Array[Json]) -> Array[String] {
  values.map(fn(value) { resource_type_or(value, "") })
}

///|
pub fn resource_labels(values : Array[Json]) -> Array[String] {
  values.map(resource_label)
}

///|
pub fn join_resource_labels(values : Array[Json], separator : String) -> String {
  resource_labels(values).join(separator)
}

///|
pub fn format_optional(value : String?) -> String {
  match value {
    Some(text) => text
    None => ""
  }
}

///|
pub fn issue_list_text(issues : Array[Issue]) -> String {
  issues
  .map(fn(item) { "\{item.severity} \{item.path}: \{item.message}" })
  .join("\n")
}

///|
pub fn report_issue_text(report : ValidationReport) -> String {
  issue_list_text(report.issues)
}

///|
pub fn pretty_json(value : Json) -> String {
  canonical_json(value, indent=2)
}

///|
pub fn safe_parse(text : String) -> Json? {
  parse_json(text)
}

///|
pub fn safe_parse_many(texts : Array[String]) -> Array[Json] {
  texts.filter_map(parse_json)
}

///|
pub fn valid_json_count(texts : Array[String]) -> Int {
  safe_parse_many(texts).length()
}

///|
pub fn resource_kind_category_text(value : Json) -> String {
  metadata_category_name(resource_category(resource_type_or(value, "")))
}

///|
pub fn resource_summary_line(value : Json) -> String {
  "\{resource_label(value)} \{resource_status_or(value, "unknown")} \{resource_kind_category_text(value)}"
}

///|
pub fn validate_json_text(text : String) -> ValidationReport? {
  parse_json(text).map(fn(value) { validate_resource(value) })
}

///|
pub fn validate_json_text_strict(text : String) -> OperationOutcome {
  operation_outcome_from_text(text)
}

///|
pub fn summarize_json_text(text : String) -> String {
  match parse_json(text) {
    None => "invalid JSON input"
    Some(value) => resource_summary_line(value)
  }
}

///|
pub fn canonicalize_json_text(text : String) -> String? {
  parse_json(text).map(fn(value) { canonical_json(value) })
}

///|
pub fn redact_json_text(text : String, policy : PrivacyPolicy) -> String? {
  parse_json(text).map(fn(value) {
    canonical_json(redact_by_policy(value, policy))
  })
}

///|
pub fn query_json_text(text : String, expression : String) -> QueryResult? {
  parse_json(text).map(fn(value) { query_result(value, expression) })
}

///|
pub fn resource_csv_text(text : String) -> String? {
  parse_json(text).map(resource_table_row)
}

///|
pub fn bundle_csv_text(text : String) -> String? {
  parse_json(text).map(bundle_entry_csv)
}

///|
pub fn bundle_graph_text(text : String) -> String? {
  parse_json(text).map(bundle_graph_summary)
}

///|
pub fn batch_quality_text(text : String) -> String {
  let report = validate_ndjson(text)
  ndjson_summary(report)
}

///|
pub fn benchmark_text(count : Int) -> String {
  let validation = benchmark_observation_validation(count)
  let ndjson = benchmark_ndjson_validation(count)
  "\{validation.name}=\{validation.valid_count}; \{ndjson.name}=\{ndjson.valid_count}"
}

///|
pub fn supported_resource_text() -> String {
  known_resource_types().join(", ")
}

///|
pub fn resource_kind_text(text : String) -> String {
  match parse_json(text) {
    None => "invalid"
    Some(value) => supported_kind_name(value)
  }
}

///|
pub fn resource_quality_text(text : String) -> String {
  match parse_json(text) {
    None => "invalid JSON"
    Some(value) => "\{quality_status(value)} (\{quality_score(value)}/100)"
  }
}

///|
pub fn schema_text(kind : String) -> String {
  schema_summary(schema_for(kind))
}

///|
pub fn terminology_text(kind : String, status : String) -> String {
  if terminology_status_is_valid(kind, status) {
    "valid"
  } else {
    "unknown"
  }
}

///|
pub fn reference_summary_text(value : Json) -> String {
  reference_resolution_summary([value])
}

///|
pub fn metrics_text(value : Json) -> String {
  metrics_summary([value])
}

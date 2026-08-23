///|
test "boundary regression protects empty collections and invalid indexes" {
  let empty = parse_json(
    "{\"resourceType\":\"Bundle\",\"type\":\"collection\",\"entry\":[]}",
  ).unwrap()
  inspect(bundle_page(empty, 0, 10).length(), content="0")
  inspect(bundle_empty(empty), content="true")
  inspect(query_count(empty, "entry[*].resource"), content="0")
  inspect(bulk_chunk_count([], 10), content="0")
  inspect(bulk_chunk_sizes([benchmark_patient(1)], 0).length(), content="0")
}

///|
test "boundary regression protects malformed dates references and quantities" {
  inspect(is_valid_fhir_date(""), content="false")
  inspect(is_valid_fhir_date("2024-02-29"), content="true")
  inspect(is_valid_fhir_date("2023-02-29"), content="false")
  debug_inspect(
    reference_resource_type("Patient/p1"),
    content="Some(\"Patient\")",
  )
  debug_inspect(reference_resource_id("Patient/p1"), content="Some(\"p1\")")
  inspect(
    quantity_is_reasonable(benchmark_observation(1), "valueQuantity", 1.0, 2.0),
    content="true",
  )
}

///|
test "boundary regression protects policy and report operations" {
  let value = benchmark_observation(1)
  let report = validate_resource(value)
  inspect(report_is_clean(report), content="true")
  inspect(operation_outcome_error_count(operation_outcome(report)), content="0")
  inspect(policy_allows(PrivacyPolicy::standard(), "status"), content="true")
  inspect(policy_allows(PrivacyPolicy::standard(), "telecom"), content="false")
}

///|
test "boundary regression protects deterministic exports and projections" {
  let values = [benchmark_patient(1), benchmark_observation(2)]
  let options = ExportOptions::ndjson()
  let rendered = export_resources(values, options)
  inspect(export_line_count(rendered), content="2")
  let first_line = rendered
    .split("\n")
    .map(fn(line) { line.to_owned() })
    .to_array()[0]
  inspect(valid_json_count([first_line]), content="1")
  inspect(
    json_equal_canonical(
      resource_projection(values[0], ["id"]),
      resource_projection(values[0], ["id"]),
    ),
    content="true",
  )
}

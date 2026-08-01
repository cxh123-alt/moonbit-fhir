///|
test "Patient validation and summary" {
  let value = parse_json(example_patient_json()).unwrap()
  let report = validate_resource(value)
  inspect(report.issues.length(), content="0")
  let summary = patient_summary(value)
  debug_inspect(summary.display_name, content="Some(\"Shanshan Cao\")")
  inspect(is_valid(value), content="true")
}

///|
test "Observation validation catches required fields" {
  let text = "{\"resourceType\":\"Observation\",\"status\":\"draft\"}"
  let value = parse_json(text).unwrap()
  let report = validate_resource(value)
  inspect(
    report.issues.length(),
    content=(
      #|2
    ),
  )
  inspect(report.issues[0].path, content="/code")
}

///|
test "Bundle entries expose nested resources" {
  let value = parse_json(example_bundle_json()).unwrap()
  inspect(bundle_resource_count(value), content="2")
  let entries = bundle_entries(value)
  inspect(entries[0].resource_type, content="Patient")
  inspect(entries[1].resource_type, content="Observation")
}

///|
test "JSON Pointer queries arrays and object fields" {
  let value = parse_json(example_bundle_json()).unwrap()
  match json_pointer(value, "/entry/1/resource/resourceType") {
    Some(String(kind)) => inspect(kind, content="Observation")
    _ => fail("missing pointer result")
  }
}

///|
test "Observation summary can flatten a CSV row" {
  let value = parse_json(example_observation_json()).unwrap()
  inspect(
    observation_csv_row(value),
    content="obs-001,final,Systolic blood pressure,Patient/patient-001,118,2026-08-01T09:30:00+08:00",
  )
}

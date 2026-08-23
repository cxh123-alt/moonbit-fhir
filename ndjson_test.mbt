///|
test "ndjson report counts valid invalid and blank lines" {
  let text = "{" +
    "\"resourceType\":\"Patient\",\"id\":\"p1\"}" +
    "\n" +
    "not-json\n\n" +
    "{\"resourceType\":\"Observation\",\"status\":\"final\",\"code\":{}}"
  let report = validate_ndjson(text)
  inspect(report.total_lines, content="4")
  inspect(report.valid_lines, content="2")
  inspect(report.invalid_lines, content="1")
  inspect(report.blank_lines, content="1")
  inspect(report.errors[0].line, content="2")
}

///|
test "ndjson statistics are deterministic" {
  let patient = parse_json(example_patient_json()).unwrap().stringify()
  let observation = parse_json(example_observation_json()).unwrap().stringify()
  let report = validate_ndjson(patient + "\n" + observation)
  let stats = ndjson_statistics(report)
  inspect(stats.resource_count, content="2")
  inspect(stats.type_counts["Patient"], content="1")
  inspect(stats.type_counts["Observation"], content="1")
}

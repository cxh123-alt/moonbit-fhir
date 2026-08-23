///|
test "FHIR date and period helpers cover lexical boundaries" {
  inspect(is_valid_fhir_date("2026-08-23"), content="true")
  inspect(is_valid_fhir_date("2026-02-30"), content="false")
  inspect(is_valid_fhir_datetime("2026-08-23T10:20:30Z"), content="true")
  inspect(is_valid_fhir_datetime("2026-08-23"), content="true")
  inspect(
    period_contains("2026-01-01", "2026-12-31", "2026-08-23"),
    content="true",
  )
  inspect(
    period_overlap("2026-01-01", "2026-04-01", "2026-03-01", "2026-06-01"),
    content="true",
  )
}

///|
test "identifiers and names are normalized for display" {
  let patient = parse_json(
    "{\"resourceType\":\"Patient\",\"id\":\"p1\",\"identifier\":[{\"system\":\"urn:mrn\",\"value\":\"001\"}],\"name\":[{\"prefix\":[\"Dr\"],\"given\":[\"Ada\"],\"family\":\"Lovelace\"}]}",
  ).unwrap()
  inspect(resource_display_name(patient), content="Dr Ada Lovelace")
  debug_inspect(identifier_value(patient, 0), content="Some(\"001\")")
  debug_inspect(identifier_system(patient, 0), content="Some(\"urn:mrn\")")
}

///|
test "batch quality reports duplicates and resource distribution" {
  let values = [
    benchmark_patient(1),
    benchmark_patient(1),
    benchmark_observation(2),
  ]
  let quality = batch_quality(values)
  inspect(quality.total, content="3")
  inspect(quality.valid, content="3")
  inspect(quality.duplicate_ids, content="1")
  inspect(quality.type_counts["Patient"], content="2")
}

///|
test "resource filters and stable table export are deterministic" {
  let values = [
    benchmark_observation(3),
    benchmark_patient(1),
    benchmark_observation(2),
  ]
  inspect(filter_resources_by_kind(values, Observation).length(), content="2")
  let sorted = sort_resources_by_id(values)
  inspect(query_text(sorted[0], "id"), content="bench-o-2")
  inspect(resource_csv_header(), content="resourceType,id,status,display")
  inspect(
    resource_table_row(values[0]),
    content="Observation,bench-o-3,final,heart rate",
  )
}

///|
test "reference and numeric rules expose actionable issues" {
  let value = parse_json(
    "{\"resourceType\":\"Observation\",\"id\":\"o1\",\"status\":\"final\",\"code\":{\"text\":\"x\"},\"valueQuantity\":{\"value\":-1}}",
  ).unwrap()
  inspect(reference_is_well_formed("Patient/p1"), content="true")
  inspect(reference_is_well_formed("bad"), content="false")
  inspect(
    quantity_is_reasonable(value, "valueQuantity", 0.0, 1000.0),
    content="false",
  )
  inspect(validate_reference(value, "subject").length(), content="0")
}

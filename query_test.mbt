///|
test "path query handles fields arrays and missing branches" {
  let value = parse_json(example_bundle_json()).unwrap()
  let kinds = query_strings(value, "entry[*].resource.resourceType")
  inspect(kinds.length(), content="2")
  inspect(kinds[0], content="Patient")
  inspect(kinds[1], content="Observation")
  let second = query_values(value, "entry[1].resource.id")
  inspect(second.length(), content="1")
  inspect(query_values(value, "entry[9].resource").length(), content="0")
  inspect(query_values(value, "").length(), content="1")
}

///|
test "path query preserves scalar text and rejects malformed expressions" {
  let value = parse_json(example_observation_json()).unwrap()
  inspect(query_text(value, "code.text"), content="Systolic blood pressure")
  inspect(query_text(value, "valueQuantity.value"), content="118")
  inspect(query_values(value, "entry[bad].resource").length(), content="0")
}

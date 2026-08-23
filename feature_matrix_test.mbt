///|
test "json projection and leaf paths support interoperability adapters" {
  let value = parse_json(
    "{\"resourceType\":\"Patient\",\"id\":\"p1\",\"name\":{\"text\":\"Ada\"},\"meta\":{\"tag\":[{\"code\":\"demo\"}]}}",
  ).unwrap()
  inspect(json_key_count(value), content="4")
  inspect(json_contains_text(value, "Ada"), content="true")
  inspect(
    resource_projection(value, ["resourceType", "id"]).stringify(),
    content="{\"resourceType\":\"Patient\",\"id\":\"p1\"}",
  )
  inspect(json_leaf_paths(value).length(), content="4")
}

///|
test "resource search combines type status and free text filters" {
  let values = [
    benchmark_observation(1),
    benchmark_patient(2),
    benchmark_observation(3),
  ]
  inspect(search_resources(values, "heart").length(), content="2")
  inspect(
    search_by_type_and_status(values, "Observation", "final").length(),
    content="2",
  )
  inspect(search_by_id(values, "bench-p-2").length(), content="1")
}

///|
test "measurement aggregation is stable for quantity observations" {
  let values = benchmark_observations(4)
  let stats = observation_measurement_stats(values)
  inspect(stats.count, content="4")
  inspect(stats.minimum, content="0")
  inspect(stats.maximum, content="3")
  inspect(stats.sum, content="6")
}

///|
test "privacy policy removes configured fields and reports sensitivity" {
  let value = parse_json(
    "{\"resourceType\":\"Patient\",\"id\":\"p1\",\"telecom\":[{\"value\":\"secret\"}],\"address\":[{\"city\":\"X\"}]}",
  ).unwrap()
  let policy = PrivacyPolicy::standard()
  inspect(resource_contains_sensitive_data(value, policy), content="true")
  inspect(
    query_strings(redact_by_policy(value, policy), "telecom").length(),
    content="0",
  )
}

///|
test "schema metadata and validation are inspectable" {
  let schema = schema_for("Observation")
  inspect(schema_field_count(schema), content="5")
  let value = parse_json(
    "{\"resourceType\":\"Observation\",\"status\":\"final\",\"code\":[]}",
  ).unwrap()
  inspect(schema_validate(value, schema).length(), content="1")
}

///|
test "bundle graph exposes outgoing edges and dangling references" {
  let bundle = parse_json(
    "{\"resourceType\":\"Bundle\",\"entry\":[{\"resource\":{\"resourceType\":\"Patient\",\"id\":\"p1\"}},{\"resource\":{\"resourceType\":\"Observation\",\"id\":\"o1\",\"status\":\"final\",\"code\":{},\"subject\":{\"reference\":\"Patient/p1\"}}}]}",
  ).unwrap()
  let graph = bundle_graph(bundle)
  inspect(graph.nodes, content="2")
  inspect(graph.edges, content="1")
  inspect(graph.dangling, content="0")
}

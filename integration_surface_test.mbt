///|
test "text APIs preserve validation and export semantics" {
  let patient = example_patient_json()
  inspect(validate_json_text(patient) is Some(_), content="true")
  inspect(summarize_json_text(patient).has_prefix("Patient/"), content="true")
  inspect(canonicalize_json_text(patient) is Some(_), content="true")
  inspect(
    redact_json_text(patient, PrivacyPolicy::standard()) is Some(_),
    content="true",
  )
  let query = query_json_text(patient, "id").unwrap()
  inspect(query.count, content="1")
  inspect(resource_csv_text(patient) is Some(_), content="true")
  inspect(resource_kind_text(patient), content="Patient")
  inspect(resource_quality_text(patient).contains("/100"), content="true")
  inspect(schema_text("Patient").contains("Patient"), content="true")
  inspect(terminology_text("Observation", "final"), content="valid")
  inspect(
    metrics_text(parse_json(patient).unwrap()).contains("records=1"),
    content="true",
  )
  let outcome = validate_json_text_strict(patient)
  inspect(operation_outcome_is_success(outcome), content="true")
}

///|
test "benchmark scenarios expose reproducible workloads" {
  inspect(benchmark_case_matrix().length(), content="4")
  inspect(benchmark_matrix_is_nonempty(), content="true")
  inspect(benchmark_scenarios().length(), content="4")
  inspect(benchmark_expected_validation_count(3), content="3")
  inspect(benchmark_expected_ndjson_count(3), content="3")
  inspect(benchmark_expected_search_count(3), content="3")
  inspect(benchmark_expected_bundle_count(3), content="3")
  inspect(benchmark_scenario_csv().split("\n").to_array().length(), content="5")
  inspect(
    benchmark_scenario_summary(),
    content="4 reproducible benchmark scenario(s)",
  )
}

///|
test "bundle validation reports missing duplicate and unsupported entries" {
  let bundle = parse_json(
    "{" +
    "\"resourceType\":\"Bundle\",\"type\":\"collection\",\"entry\":[" +
    "{\"resource\":{\"resourceType\":\"Patient\",\"id\":\"p1\"}}," +
    "{\"resource\":{\"resourceType\":\"Patient\",\"id\":\"p1\"}}," +
    "{}," +
    "{\"resource\":{\"resourceType\":\"Unknown\",\"id\":\"u1\"}}]}",
  ).unwrap()
  let report = validate_bundle_structure(bundle)
  inspect(report.entry_count, content="4")
  inspect(report.resource_count, content="3")
  inspect(report.missing_resource_entries, content="1")
  inspect(report.duplicate_ids, content="1")
  inspect(report.unsupported_resources, content="1")
  inspect(bundle_structure_is_valid(bundle), content="false")
  inspect(bundle_quality_score(bundle), content="75")
  inspect(bundle_issue_codes(bundle).length(), content="2")
  inspect(bundle_has_duplicate_ids(bundle), content="true")
  inspect(bundle_status_summary(bundle).contains("entries=4"), content="true")
}

///|
test "codeable concepts and path operations expose typed results" {
  let concept = parse_json(
    "{\"text\":\"Heart rate\",\"coding\":[{\"system\":\"loinc\",\"code\":\"8867-4\",\"display\":\"Heart rate\"}]}",
  ).unwrap()
  inspect(codeable_codes(concept).length(), content="1")
  inspect(codeable_systems(concept)[0], content="loinc")
  inspect(codeable_has_code(concept, "8867-4"), content="true")
  inspect(codeable_has_system_code(concept, "loinc", "8867-4"), content="true")
  inspect(codeable_find_code(concept, "loinc").unwrap(), content="8867-4")
  inspect(codeable_primary_display(concept).unwrap(), content="Heart rate")
  inspect(codeable_summary(concept), content="Heart rate [8867-4]")
  let observation = benchmark_observation(2)
  inspect(path_equals(observation, "status", "final"), content="true")
  inspect(path_contains(observation, "code.text", "heart"), content="true")
  inspect(
    path_count_at_least(observation, "valueQuantity.value", 1),
    content="true",
  )
  inspect(path_numeric_sum(observation, "valueQuantity.value"), content="2")
  inspect(
    path_numeric_min(observation, "valueQuantity.value").unwrap(),
    content="2",
  )
  inspect(
    path_numeric_max(observation, "valueQuantity.value").unwrap(),
    content="2",
  )
  inspect(path_is_singleton(observation, "id"), content="true")
  inspect(path_is_empty(observation, "missing"), content="true")
}

///|
test "constraints and version modes reject out-of-contract values" {
  let good = benchmark_observation(1)
  let bad = parse_json(
    "{\"resourceType\":\"Observation\",\"status\":\"\",\"code\":1}",
  ).unwrap()
  let constraints = common_observation_constraints()
  inspect(constraint_count(constraints), content="5")
  inspect(constraints_are_valid(good, constraints), content="true")
  inspect(constraints_are_valid(bad, constraints), content="false")
  inspect(validation_mode_name(Strict), content="strict")
  inspect(validation_mode_rejects_warnings(Strict), content="true")
  inspect(validation_mode_rejects_warnings(Lenient), content="false")
  inspect(version_name(R4), content="R4")
  inspect(version_supports(R4, "Patient"), content="true")
  inspect(version_supports(R4, "Condition"), content="false")
  inspect(version_supports(R5, "Condition"), content="true")
  inspect(severity_rank("error"), content="3")
  inspect(severity_rank("unknown"), content="0")
}

///|
test "resource operations are composable and preserve identities" {
  let patient = benchmark_patient(1)
  let updated = update_resource_status(patient, "inactive")
  inspect(query_text(updated, "status", fallback="none"), content="inactive")
  let renamed = update_resource_id(updated, "p2")
  inspect(query_text(renamed, "id", fallback="none"), content="p2")
  let patched = apply_resource_patches(patient, [
    ResourcePatch::set("gender", Json::string("female")),
    ResourcePatch::remove("name"),
  ])
  inspect(query_text(patched, "gender", fallback="none"), content="female")
  inspect(query_exists(patched, "name"), content="false")
  inspect(operation_validate(patient).success, content="true")
  inspect(operation_normalize(patient).success, content="true")
  inspect(
    operation_redact(patient, PrivacyPolicy::standard()).success,
    content="true",
  )
  let values = upsert_resource([patient], renamed)
  inspect(values.length(), content="1")
  inspect(delete_resource(values, "Patient", "p2").length(), content="0")
  let created = find_or_create_resource([], "Patient", "new").0
  inspect(created.length(), content="1")
}

///|
test "narrative processing and observation series are deterministic" {
  let narrative = "  <div>Heart\n  rate</div>  today "
  inspect(normalize_narrative(narrative), content="<div>Heart rate</div> today")
  inspect(strip_html_tags(narrative), content="  Heart\n  rate  today ")
  inspect(narrative_plain_text(narrative), content="Heart rate today")
  inspect(narrative_word_count(narrative), content="3")
  inspect(narrative_character_count("a b"), content="3")
  inspect(narrative_preview("abcdef", 3), content="abc...")
  inspect(narrative_contains(narrative, "HEART"), content="true")
  let with_text = parse_json(
    "{\"resourceType\":\"Patient\",\"text\":{\"div\":\"<div>Ada</div>\"}}",
  ).unwrap()
  inspect(resource_has_narrative(with_text), content="true")
  inspect(narrative_coverage([with_text, benchmark_patient(1)]), content="50")
  let points = observation_series(benchmark_observations(3), "heart rate")
  inspect(points.length(), content="3")
  inspect(observation_series_values(points).length(), content="3")
  inspect(observation_series_mean(points).unwrap(), content="1")
  inspect(observation_series_median(points).unwrap(), content="1")
  inspect(observation_series_min(points).unwrap(), content="0")
  inspect(observation_series_max(points).unwrap(), content="2")
  inspect(observation_series_unit(points).unwrap(), content="/min")
}

///|
test "provenance and reference resolution distinguish resolved targets" {
  let patient = benchmark_patient(1)
  let observation = benchmark_observation(1)
  let provenance = parse_json(
    "{\"resourceType\":\"Provenance\",\"recorded\":\"2026-08-24\",\"target\":[{\"reference\":\"Observation/missing\"}],\"agent\":[{\"role\":{\"text\":\"author\"},\"who\":{\"reference\":\"Practitioner/p1\"}}]}",
  ).unwrap()
  inspect(provenance_actor_count(provenance), content="1")
  inspect(provenance_target_count(provenance), content="1")
  inspect(provenance_has_actor(provenance, "Practitioner/p1"), content="true")
  inspect(provenance_is_complete(provenance), content="true")
  inspect(
    provenance_summary_text(provenance).contains("actors=1"),
    content="true",
  )
  let unresolved = parse_json(
    "{\"resourceType\":\"Observation\",\"id\":\"unresolved-o-1\",\"status\":\"final\",\"subject\":{\"reference\":\"Patient/missing\"}}",
  ).unwrap()
  let values = [patient, observation, provenance, unresolved]
  inspect(
    resolve_reference("Patient/bench-p-1", values).resolved,
    content="true",
  )
  inspect(unresolved_references(observation, values).length(), content="0")
  inspect(all_references_resolve(values), content="false")
  inspect(reference_graph_edges(values).length(), content="2")
  inspect(
    reference_resolution_summary(values).contains("unresolved=1"),
    content="true",
  )
}

///|
test "service facade and query rendering compose application workflows" {
  let service = FhirService::default()
  let values = [benchmark_patient(1), benchmark_observation(1)]
  inspect(service.validate(values[0]).resource_type, content="Patient")
  inspect(service.validate_many(values).accepted.length(), content="2")
  inspect(service.search(values, "heart").length(), content="1")
  inspect(service.query(values[1], "status").length(), content="1")
  inspect(
    service.terminology_contains("observation-status", "final"),
    content="true",
  )
  inspect(service.schema("Observation").resource_type, content="Observation")
  inspect(service.metadata("Patient").supported, content="true")
  inspect(service.quality(values).valid, content="2")
  inspect(service.summarize(values).contains("accepted=2"), content="true")
  inspect(query_result_text(query_result(values[1], "status")), content="final")
  inspect(query_result_csv(query_result(values[1], "status")), content="final")
  inspect(
    query_result_has_value(query_result(values[1], "status"), "final"),
    content="true",
  )
  inspect(
    query_result_is_scalar(query_result(values[1], "status")),
    content="true",
  )
  inspect(
    query_many_csv(values[1], ["id", "status"]).contains(
      "expression,count,values",
    ),
    content="true",
  )
}

///|
test "terminology and metadata catalogs expose reusable contracts" {
  let observation_status = common_observation_status()
  inspect(ValueSet::size(observation_status), content="8")
  inspect(terminology_contains(observation_status, "final"), content="true")
  inspect(
    terminology_all_codes_valid(observation_status, ["final", "preliminary"]),
    content="true",
  )
  inspect(
    terminology_missing_codes(observation_status, ["final", "invalid"]).length(),
    content="1",
  )
  let catalog = default_terminology_catalog()
  inspect(catalog.size(), content="4")
  inspect(catalog.contains("observation-status", "final"), content="true")
  inspect(
    catalog.validate("observation-status", "/status", None, "final") is None,
    content="true",
  )
  inspect(
    catalog.validate("observation-status", "/status", None, "invalid")
    is Some(_),
    content="true",
  )
  inspect(
    metadata_category_name(resource_category("Observation")),
    content="clinical",
  )
  inspect(resource_required_fields("Observation").length(), content="3")
  inspect(resource_reference_fields("Observation").length(), content="2")
  inspect(resource_date_fields("Observation").length(), content="2")
  inspect(
    metadata_summary("Observation").contains("required=3"),
    content="true",
  )
}

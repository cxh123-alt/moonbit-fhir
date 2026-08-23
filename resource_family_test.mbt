///|
test "additional resource families are detected and validated" {
  let condition = parse_json(
    "{\"resourceType\":\"Condition\",\"clinicalStatus\":{\"coding\":[{\"code\":\"active\"}]},\"code\":{\"text\":\"fever\"}}",
  ).unwrap()
  inspect(resource_kind(condition).to_string(), content="Condition")
  inspect(validate_resource(condition).issues.length(), content="0")
  let procedure = parse_json(
    "{\"resourceType\":\"Procedure\",\"status\":\"completed\",\"code\":{\"text\":\"test\"}}",
  ).unwrap()
  inspect(validate_resource(procedure).issues.length(), content="0")
}

///|
test "resource family summaries expose references" {
  let value = parse_json(
    "{\"resourceType\":\"Condition\",\"id\":\"c1\",\"subject\":{\"reference\":\"Patient/p1\"},\"code\":{\"text\":\"fever\"}}",
  ).unwrap()
  let summary = condition_summary(value)
  debug_inspect(summary.id, content="Some(\"c1\")")
  debug_inspect(summary.subject, content="Some(\"Patient/p1\")")
  debug_inspect(summary.code_text, content="Some(\"fever\")")
}

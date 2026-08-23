///|
test "profile validates required type allowed and cardinality rules" {
  let profile = Profile::new("observation-minimal", [
    ProfileRule::Required("status"),
    ProfileRule::Type("code", "object"),
    ProfileRule::Allowed("status", ["registered"]),
    ProfileRule::MinItems("category", 1),
  ])
  let value = parse_json(
    "{\"resourceType\":\"Observation\",\"status\":\"final\",\"code\":{}}",
  ).unwrap()
  let report = validate_with_profile(value, profile)
  inspect(report.issues.length(), content="2")
  inspect(report.issues[0].code, content="value")
  inspect(report.issues[1].code, content="required")
}

///|
test "profile accepts a complete resource" {
  let profile = Profile::new("patient", [ProfileRule::Required("id")])
  let value = parse_json("{\"resourceType\":\"Patient\",\"id\":\"p1\"}").unwrap()
  inspect(validate_with_profile(value, profile).issues.length(), content="0")
}

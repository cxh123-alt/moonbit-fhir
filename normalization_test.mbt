///|
test "normalization is stable and csv escaping is RFC4180 friendly" {
  let value = parse_json("{\"b\":2,\"a\":1}").unwrap()
  inspect(canonical_json(value), content="{\"a\":1,\"b\":2}")
  inspect(csv_escape("a,b\"c"), content="\"a,b\"\"c\"")
  inspect(csv_escape("plain"), content="plain")
}

///|
test "redaction replaces selected sensitive fields without mutating input" {
  let value = parse_json(
    "{\"resourceType\":\"Patient\",\"id\":\"p1\",\"telecom\":[{\"value\":\"secret\"}]}",
  ).unwrap()
  let redacted = redact_fields(value, ["telecom"])
  inspect(query_strings(redacted, "telecom").length(), content="0")
  inspect(query_text(value, "telecom[0].value"), content="secret")
}

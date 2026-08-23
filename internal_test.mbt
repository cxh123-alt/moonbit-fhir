///|
test "unsupported resources are warnings rather than hard failures" {
  let value = @json.parse(
    "{\"resourceType\":\"UnknownResource\",\"id\":\"q1\"}",
  )
  let report = validate_resource(value)
  inspect(report.issues.length(), content="1")
  inspect(report.issues[0].severity, content="warning")
}

///|
test "missing resourceType is an error" {
  let value = @json.parse("{\"id\":\"x\"}")
  inspect(is_valid(value), content="false")
}

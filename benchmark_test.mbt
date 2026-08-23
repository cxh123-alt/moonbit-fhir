///|
test "benchmark fixture scales without invalid records" {
  let records = benchmark_observations(100)
  inspect(records.length(), content="100")
  inspect(records.all(fn(value) { is_valid(value) }), content="true")
  let bundle = benchmark_bundle(100)
  inspect(bundle_resource_count(bundle), content="100")
}

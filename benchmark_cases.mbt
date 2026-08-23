///|
pub(all) struct BenchmarkCase {
  name : String
  records : Int
  payload_bytes : Int
  operation : String
} derive(Debug, Eq, ToJson)

///|
pub fn benchmark_case_single() -> BenchmarkCase {
  let value = benchmark_observation(1)
  {
    name: "single-observation-validation",
    records: 1,
    payload_bytes: value.stringify().length(),
    operation: "validate_resource",
  }
}

///|
pub fn benchmark_case_bundle(count : Int) -> BenchmarkCase {
  let bundle = benchmark_bundle(count)
  {
    name: "bundle-entry-validation",
    records: count,
    payload_bytes: bundle.stringify().length(),
    operation: "analyze_bundle",
  }
}

///|
pub fn benchmark_case_ndjson(count : Int) -> BenchmarkCase {
  let text = benchmark_ndjson(count)
  {
    name: "ndjson-bulk-validation",
    records: count,
    payload_bytes: text.length(),
    operation: "validate_ndjson",
  }
}

///|
pub fn benchmark_case_search(count : Int) -> BenchmarkCase {
  let values = benchmark_observations(count)
  {
    name: "resource-search",
    records: count,
    payload_bytes: bulk_to_ndjson(values).length(),
    operation: "search_resources",
  }
}

///|
pub fn benchmark_case_matrix() -> Array[BenchmarkCase] {
  [
    benchmark_case_single(),
    benchmark_case_bundle(100),
    benchmark_case_ndjson(100),
    benchmark_case_search(1000),
  ]
}

///|
pub fn run_benchmark_validation(count : Int) -> Int {
  benchmark_observations(count).count_if(fn(value) { is_valid(value) })
}

///|
pub fn run_benchmark_bundle(count : Int) -> Int {
  let bundle = benchmark_bundle(count)
  analyze_bundle(bundle).resource_count
}

///|
pub fn run_benchmark_ndjson(count : Int) -> Int {
  validate_ndjson(benchmark_ndjson(count)).valid_lines
}

///|
pub fn run_benchmark_search(count : Int) -> Int {
  search_resources(benchmark_observations(count), "heart").length()
}

///|
pub fn benchmark_case_summary(case_ : BenchmarkCase) -> String {
  "\{case_.name}: records=\{case_.records} bytes=\{case_.payload_bytes} operation=\{case_.operation}"
}

///|
pub fn benchmark_matrix_summary() -> Array[String] {
  benchmark_case_matrix().map(benchmark_case_summary)
}

///|
pub fn benchmark_matrix_is_nonempty() -> Bool {
  benchmark_case_matrix().length() > 0
}

///|
pub fn benchmark_expected_validation_count(count : Int) -> Int {
  run_benchmark_validation(count)
}

///|
pub fn benchmark_expected_bundle_count(count : Int) -> Int {
  run_benchmark_bundle(count)
}

///|
pub fn benchmark_expected_ndjson_count(count : Int) -> Int {
  run_benchmark_ndjson(count)
}

///|
pub fn benchmark_expected_search_count(count : Int) -> Int {
  run_benchmark_search(count)
}

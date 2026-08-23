///|
pub(all) struct BenchmarkObservation {
  name : String
  input_size : Int
  output_size : Int
  valid_count : Int
  elapsed_units : Int
} derive(Debug, Eq, ToJson)

///|
pub fn benchmark_observation_validation(count : Int) -> BenchmarkObservation {
  let input = benchmark_observations(count)
  let output = run_benchmark_validation(count)
  {
    name: "validation",
    input_size: bulk_to_ndjson(input).length(),
    output_size: output,
    valid_count: output,
    elapsed_units: input.length(),
  }
}

///|
pub fn benchmark_bundle_analysis(count : Int) -> BenchmarkObservation {
  let input = benchmark_bundle(count)
  let output = run_benchmark_bundle(count)
  {
    name: "bundle-analysis",
    input_size: input.stringify().length(),
    output_size: output,
    valid_count: output,
    elapsed_units: count,
  }
}

///|
pub fn benchmark_ndjson_validation(count : Int) -> BenchmarkObservation {
  let input = benchmark_ndjson(count)
  let output = run_benchmark_ndjson(count)
  {
    name: "ndjson-validation",
    input_size: input.length(),
    output_size: output,
    valid_count: output,
    elapsed_units: count,
  }
}

///|
pub fn benchmark_search_scan(count : Int) -> BenchmarkObservation {
  let input = benchmark_observations(count)
  let output = run_benchmark_search(count)
  {
    name: "search-scan",
    input_size: bulk_to_ndjson(input).length(),
    output_size: output,
    valid_count: output,
    elapsed_units: count,
  }
}

///|
pub fn benchmark_scenarios() -> Array[BenchmarkObservation] {
  [
    benchmark_observation_validation(100),
    benchmark_bundle_analysis(100),
    benchmark_ndjson_validation(100),
    benchmark_search_scan(1000),
  ]
}

///|
pub fn benchmark_scenario_rows() -> Array[String] {
  benchmark_scenarios().map(fn(item) {
    csv_row([
      "\{item.name}",
      "\{item.input_size}",
      "\{item.output_size}",
      "\{item.valid_count}",
      "\{item.elapsed_units}",
    ])
  })
}

///|
pub fn benchmark_scenario_csv() -> String {
  ["name,input_bytes,output_count,valid_count,work_units"]
  .add(benchmark_scenario_rows())
  .join("\n")
}

///|
pub fn benchmark_scenario_summary() -> String {
  "\{benchmark_scenarios().length()} reproducible benchmark scenario(s)"
}

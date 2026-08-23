///|
pub fn benchmark_patient(index : Int) -> Json {
  parse_json(
    "{\"resourceType\":\"Patient\",\"id\":\"bench-p-\{index}\",\"name\":[{\"text\":\"Benchmark \{index}\"}],\"gender\":\"unknown\"}",
  ).unwrap()
}

///|
pub fn benchmark_observation(index : Int) -> Json {
  parse_json(
    "{\"resourceType\":\"Observation\",\"id\":\"bench-o-\{index}\",\"status\":\"final\",\"code\":{\"text\":\"heart rate\"},\"subject\":{\"reference\":\"Patient/bench-p-\{index}\"},\"valueQuantity\":{\"value\":\{index},\"unit\":\"/min\"}}",
  ).unwrap()
}

///|
pub fn benchmark_observations(count : Int) -> Array[Json] {
  let output : Array[Json] = []
  for index in 0..<count {
    output.push(benchmark_observation(index))
  }
  output
}

///|
pub fn benchmark_bundle(count : Int) -> Json {
  let entries : Array[Json] = []
  for index in 0..<count {
    let resource = if index % 2 == 0 {
      benchmark_patient(index)
    } else {
      benchmark_observation(index)
    }
    let entry : Map[String, Json] = Map([
      ("fullUrl", Json::string("urn:uuid:bench-\{index}")),
      ("resource", resource),
    ])
    entries.push(Json::object(entry))
  }
  Json::object(
    Map([
      ("resourceType", Json::string("Bundle")),
      ("type", Json::string("collection")),
      ("entry", Json::array(entries)),
    ]),
  )
}

///|
pub fn benchmark_ndjson(count : Int) -> String {
  let lines : Array[String] = []
  for index in 0..<count {
    lines.push(benchmark_observation(index).stringify())
  }
  lines.join("\n")
}

///|
pub fn benchmark_mixed_ndjson(count : Int) -> String {
  let lines : Array[String] = []
  for index in 0..<count {
    if index % 5 == 0 {
      lines.push("not-json-\{index}")
    } else {
      lines.push(benchmark_observation(index).stringify())
    }
  }
  lines.join("\n")
}

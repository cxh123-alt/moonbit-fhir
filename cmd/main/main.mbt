///|
fn print_usage() -> Unit {
  println("fhir-validate --example patient|observation|bundle")
  println("fhir-validate --json '<FHIR resource JSON>'")
  println("fhir-validate --summary '<FHIR resource JSON>'")
  println("fhir-validate --query '<FHIR JSON>' '<path expression>'")
  println("fhir-validate --ndjson '<newline-delimited FHIR JSON>'")
  println("fhir-validate --benchmark <count>")
}

///|
fn choose_example(name : String) -> String? {
  match name {
    "patient" => Some(@fhir.example_patient_json())
    "observation" => Some(@fhir.example_observation_json())
    "bundle" => Some(@fhir.example_bundle_json())
    _ => None
  }
}

///|
fn render_report(text : String) -> String {
  match @fhir.parse_json(text) {
    Some(value) => {
      let report = @fhir.validate_resource(value)
      let status = if @fhir.is_valid(value) { "valid" } else { "invalid" }
      "FHIR \{report.resource_type} \{status}: \{report.issues.length()} issue(s)"
    }
    None => "invalid JSON input"
  }
}

///|
fn render_query(text : String, expression : String) -> String {
  match @fhir.parse_json(text) {
    Some(value) =>
      @fhir.query_result_summary(@fhir.query_result(value, expression))
    None => "invalid JSON input"
  }
}

///|
fn parse_count(value : String) -> Int? {
  if value.length() == 0 {
    return None
  }
  let mut result = 0
  for index in 0..<value.length() {
    match value.get(index) {
      Some(ch) if ch >= ('0' : UInt16) && ch <= ('9' : UInt16) =>
        result = result * 10 + ch.to_int() - ('0' : UInt16).to_int()
      _ => return None
    }
  }
  Some(result)
}

///|
fn main {
  let args = @env.args()
  if args.length() == 3 && args[1] == "--example" {
    match choose_example(args[2]) {
      Some(text) => println(render_report(text))
      None => print_usage()
    }
  } else if args.length() == 3 && args[1] == "--json" {
    println(render_report(args[2]))
  } else if args.length() == 3 && args[1] == "--summary" {
    println(@fhir.summarize_json_text(args[2]))
  } else if args.length() == 4 && args[1] == "--query" {
    println(render_query(args[2], args[3]))
  } else if args.length() == 3 && args[1] == "--ndjson" {
    println(@fhir.batch_quality_text(args[2]))
  } else if args.length() == 3 && args[1] == "--benchmark" {
    match parse_count(args[2]) {
      Some(count) => println(@fhir.benchmark_text(count))
      None => print_usage()
    }
  } else {
    print_usage()
  }
}

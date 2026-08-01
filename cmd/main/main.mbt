///|
fn print_usage() -> Unit {
  println("fhir-validate --example patient|observation|bundle")
  println("fhir-validate --json '<FHIR resource JSON>'")
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
fn main {
  let args = @env.args()
  if args.length() == 3 && args[1] == "--example" {
    match choose_example(args[2]) {
      Some(text) => println(render_report(text))
      None => print_usage()
    }
  } else if args.length() == 3 && args[1] == "--json" {
    println(render_report(args[2]))
  } else {
    print_usage()
  }
}

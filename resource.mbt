///|
pub fn parse_json(text : String) -> Json? {
  try @json.parse(text) catch {
    _ => None
  } noraise {
    value => Some(value)
  }
}

///|
pub fn resource_type(value : Json) -> String? {
  field_string(value, "resourceType")
}

///|
pub fn resource_kind(value : Json) -> ResourceKind {
  match resource_type(value) {
    Some("Patient") => Patient
    Some("Observation") => Observation
    Some("Medication") => Medication
    Some("DiagnosticReport") => DiagnosticReport
    Some("Encounter") => Encounter
    Some("Bundle") => Bundle
    Some(other) => Other(other)
    None => Other("")
  }
}

///|
pub fn is_supported_resource(value : Json) -> Bool {
  match resource_kind(value) {
    Patient
    | Observation
    | Medication
    | DiagnosticReport
    | Encounter
    | Bundle => true
    Other(_) => false
  }
}

///|
pub fn bundle_entries(bundle : Json) -> Array[BundleEntry] {
  match field_array(bundle, "entry") {
    Some(entries) => {
      let out : Array[BundleEntry] = []
      for item in entries {
        match object_get(item, "resource") {
          Some(resource) =>
            out.push({
              full_url: field_string(item, "fullUrl"),
              resource_type: resource_type(resource).unwrap_or(""),
              id: field_string(resource, "id"),
            })
          None => ()
        }
      }
      out
    }
    None => []
  }
}

///|
pub fn bundle_resource_count(bundle : Json) -> Int {
  bundle_entries(bundle).length()
}

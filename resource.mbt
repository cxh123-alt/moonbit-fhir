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
    Some("MedicationRequest") => MedicationRequest
    Some("DiagnosticReport") => DiagnosticReport
    Some("Encounter") => Encounter
    Some("Condition") => Condition
    Some("Procedure") => Procedure
    Some("Immunization") => Immunization
    Some("AllergyIntolerance") => AllergyIntolerance
    Some("CarePlan") => CarePlan
    Some("Practitioner") => Practitioner
    Some("Organization") => Organization
    Some("Location") => Location
    Some("ServiceRequest") => ServiceRequest
    Some("Goal") => Goal
    Some("CareTeam") => CareTeam
    Some("Device") => Device
    Some("Specimen") => Specimen
    Some("Questionnaire") => Questionnaire
    Some("List") => List
    Some("Composition") => Composition
    Some("DocumentReference") => DocumentReference
    Some("Provenance") => Provenance
    Some("AuditEvent") => AuditEvent
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
    | MedicationRequest
    | DiagnosticReport
    | Encounter
    | Condition
    | Procedure
    | Immunization
    | AllergyIntolerance
    | CarePlan
    | Practitioner
    | Organization
    | Location
    | ServiceRequest
    | Goal
    | CareTeam
    | Device
    | Specimen
    | Questionnaire
    | List
    | Composition
    | DocumentReference
    | Provenance
    | AuditEvent
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

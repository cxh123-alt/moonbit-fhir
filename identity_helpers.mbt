///|
fn join_present(values : Array[String], separator : String) -> String {
  values.filter(fn(value) { value != "" }).join(separator)
}

///|
fn human_name_text(value : Json) -> String {
  match field_string(value, "text") {
    Some(text) => text
    None => {
      let prefix = field_array(value, "prefix")
        .unwrap_or([])
        .filter_map(as_string)
      let given = field_array(value, "given")
        .unwrap_or([])
        .filter_map(as_string)
      let family = field_string(value, "family").unwrap_or("")
      let suffix = field_array(value, "suffix")
        .unwrap_or([])
        .filter_map(as_string)
      join_present(prefix.add(given).add([family]).add(suffix), " ")
    }
  }
}

///|
pub fn resource_display_name(value : Json) -> String {
  match resource_kind(value) {
    Patient =>
      match field_array(value, "name") {
        Some(names) =>
          match names.get(0) {
            Some(name) => human_name_text(name)
            None => field_string(value, "id").unwrap_or("Patient")
          }
        None => field_string(value, "id").unwrap_or("Patient")
      }
    Practitioner =>
      query_text(
        value,
        "name[0].text",
        fallback=field_string(value, "id").unwrap_or("Practitioner"),
      )
    Organization =>
      field_string(value, "name").unwrap_or(
        field_string(value, "id").unwrap_or("Organization"),
      )
    Location =>
      field_string(value, "name").unwrap_or(
        field_string(value, "id").unwrap_or("Location"),
      )
    Observation =>
      query_text(
        value,
        "code.text",
        fallback=field_string(value, "id").unwrap_or("Observation"),
      )
    Condition =>
      query_text(
        value,
        "code.text",
        fallback=field_string(value, "id").unwrap_or("Condition"),
      )
    Procedure =>
      query_text(
        value,
        "code.text",
        fallback=field_string(value, "id").unwrap_or("Procedure"),
      )
    Medication =>
      query_text(
        value,
        "code.text",
        fallback=field_string(value, "id").unwrap_or("Medication"),
      )
    MedicationRequest =>
      query_text(
        value,
        "medicationCodeableConcept.text",
        fallback=field_string(value, "id").unwrap_or("MedicationRequest"),
      )
    DiagnosticReport =>
      query_text(
        value,
        "code.text",
        fallback=field_string(value, "id").unwrap_or("DiagnosticReport"),
      )
    Immunization =>
      query_text(
        value,
        "vaccineCode.text",
        fallback=field_string(value, "id").unwrap_or("Immunization"),
      )
    AllergyIntolerance =>
      query_text(
        value,
        "code.text",
        fallback=field_string(value, "id").unwrap_or("AllergyIntolerance"),
      )
    CarePlan =>
      field_string(value, "title").unwrap_or(
        field_string(value, "id").unwrap_or("CarePlan"),
      )
    ServiceRequest =>
      query_text(
        value,
        "code.text",
        fallback=field_string(value, "id").unwrap_or("ServiceRequest"),
      )
    Goal =>
      query_text(
        value,
        "description.text",
        fallback=field_string(value, "id").unwrap_or("Goal"),
      )
    CareTeam =>
      field_string(value, "name").unwrap_or(
        field_string(value, "id").unwrap_or("CareTeam"),
      )
    Device =>
      query_text(
        value,
        "type.text",
        fallback=field_string(value, "id").unwrap_or("Device"),
      )
    Specimen =>
      query_text(
        value,
        "type.text",
        fallback=field_string(value, "id").unwrap_or("Specimen"),
      )
    Questionnaire =>
      field_string(value, "title").unwrap_or(
        field_string(value, "id").unwrap_or("Questionnaire"),
      )
    List =>
      field_string(value, "title").unwrap_or(
        field_string(value, "id").unwrap_or("List"),
      )
    Composition =>
      query_text(
        value,
        "type.text",
        fallback=field_string(value, "id").unwrap_or("Composition"),
      )
    DocumentReference =>
      query_text(
        value,
        "type.text",
        fallback=field_string(value, "id").unwrap_or("DocumentReference"),
      )
    Provenance =>
      field_string(value, "recorded").unwrap_or(
        field_string(value, "id").unwrap_or("Provenance"),
      )
    AuditEvent =>
      query_text(
        value,
        "type.text",
        fallback=field_string(value, "id").unwrap_or("AuditEvent"),
      )
    Encounter => field_string(value, "id").unwrap_or("Encounter")
    Bundle => field_string(value, "id").unwrap_or("Bundle")
    Other(name) => if name == "" { "FHIR resource" } else { name }
  }
}

///|
pub fn identifier_value(value : Json, index : Int) -> String? {
  match field_array(value, "identifier") {
    None => None
    Some(items) =>
      match items.get(index) {
        Some(item) => field_string(item, "value")
        None => None
      }
  }
}

///|
pub fn identifier_system(value : Json, index : Int) -> String? {
  match field_array(value, "identifier") {
    None => None
    Some(items) =>
      match items.get(index) {
        Some(item) => field_string(item, "system")
        None => None
      }
  }
}

///|
pub fn identifier_type_text(value : Json, index : Int) -> String? {
  match field_array(value, "identifier") {
    None => None
    Some(items) =>
      match items.get(index) {
        Some(item) =>
          match object_get(item, "type") {
            Some(type_) => codeable_text(type_)
            None => None
          }
        None => None
      }
  }
}

///|
pub fn resource_identifiers(value : Json) -> Array[(String, String)] {
  let output : Array[(String, String)] = []
  for item in field_array(value, "identifier").unwrap_or([]) {
    match field_string(item, "value") {
      None => ()
      Some(identifier) =>
        output.push((field_string(item, "system").unwrap_or(""), identifier))
    }
  }
  output
}

///|
pub fn identifier_count(value : Json) -> Int {
  field_array(value, "identifier").unwrap_or([]).length()
}

///|
pub fn has_identifier(
  value : Json,
  system : String,
  identifier : String,
) -> Bool {
  resource_identifiers(value).any(fn(pair) {
    pair.0 == system && pair.1 == identifier
  })
}

///|
pub fn contact_point_values(value : Json) -> Array[String] {
  query_strings(value, "telecom[*].value")
}

///|
pub fn address_lines(value : Json) -> Array[String] {
  query_strings(value, "address[*].line[*]")
}

///|
pub fn address_display(value : Json, index : Int) -> String {
  match field_array(value, "address") {
    None => ""
    Some(addresses) =>
      match addresses.get(index) {
        None => ""
        Some(address) => {
          let lines = field_array(address, "line")
            .unwrap_or([])
            .filter_map(as_string)
          join_present(
            lines
            .add([field_string(address, "city").unwrap_or("")])
            .add([field_string(address, "country").unwrap_or("")]),
            ", ",
          )
        }
      }
  }
}

///|
pub fn resource_csv_header() -> String {
  "resourceType,id,status,display"
}

///|
pub fn resource_table_row(value : Json) -> String {
  csv_row([
    resource_type(value).unwrap_or(""),
    field_string(value, "id").unwrap_or(""),
    field_string(value, "status").unwrap_or(""),
    resource_display_name(value),
  ])
}

///|
pub fn resource_table_rows(values : Array[Json]) -> Array[String] {
  values.map(resource_table_row)
}

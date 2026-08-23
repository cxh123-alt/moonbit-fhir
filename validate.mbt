///|
fn issue(
  path : String,
  code : String,
  message : String,
  severity? : String = "error",
) -> Issue {
  { path, code, message, severity }
}

///|
fn require_string(
  issues : Array[Issue],
  value : Json,
  key : String,
  path : String,
) -> Unit {
  match object_get(value, key) {
    Some(String(s)) =>
      if s.length() == 0 {
        issues.push(issue(path, "empty", "\{key} must not be empty"))
      }
    Some(_) => issues.push(issue(path, "type", "\{key} must be a JSON string"))
    None => issues.push(issue(path, "required", "\{key} is required"))
  }
}

///|
fn require_array(
  issues : Array[Issue],
  value : Json,
  key : String,
  path : String,
) -> Unit {
  match object_get(value, key) {
    Some(Array(items)) =>
      if items.length() == 0 {
        issues.push(
          issue(path, "empty", "\{key} must contain at least one item"),
        )
      }
    Some(_) => issues.push(issue(path, "type", "\{key} must be a JSON array"))
    None => issues.push(issue(path, "required", "\{key} is required"))
  }
}

///|
fn validate_patient(issues : Array[Issue], value : Json) -> Unit {
  match object_get(value, "name") {
    Some(Array(_)) | None => ()
    Some(_) =>
      issues.push(
        issue("/name", "type", "Patient.name must be an array when present"),
      )
  }
  match field_string(value, "gender") {
    Some("male" | "female" | "other" | "unknown") | None => ()
    Some(_) =>
      issues.push(
        issue(
          "/gender",
          "value",
          "Patient.gender should be male, female, other, or unknown",
          severity="warning",
        ),
      )
  }
}

///|
fn validate_observation(issues : Array[Issue], value : Json) -> Unit {
  require_string(issues, value, "status", "/status")
  match object_get(value, "code") {
    Some(Object(_)) => ()
    Some(_) =>
      issues.push(issue("/code", "type", "Observation.code must be an object"))
    None =>
      issues.push(issue("/code", "required", "Observation.code is required"))
  }
  match field_string(value, "status") {
    Some(
      "registered"
      | "preliminary"
      | "final"
      | "amended"
      | "corrected"
      | "cancelled"
      | "entered-in-error"
      | "unknown"
    )
    | None => ()
    Some(_) =>
      issues.push(
        issue(
          "/status",
          "value",
          "Observation.status is outside the common FHIR value set",
          severity="warning",
        ),
      )
  }
}

///|
fn validate_medication(issues : Array[Issue], value : Json) -> Unit {
  match object_get(value, "code") {
    Some(Object(_)) | None => ()
    Some(_) =>
      issues.push(issue("/code", "type", "Medication.code must be an object"))
  }
  match field_string(value, "status") {
    Some("active" | "inactive" | "entered-in-error") | None => ()
    Some(_) =>
      issues.push(
        issue(
          "/status",
          "value",
          "Medication.status is outside the common FHIR value set",
          severity="warning",
        ),
      )
  }
}

///|
fn validate_medication_request(issues : Array[Issue], value : Json) -> Unit {
  require_string(issues, value, "status", "/status")
  match object_get(value, "medicationCodeableConcept") {
    Some(Object(_)) | None => ()
    Some(_) =>
      issues.push(
        issue(
          "/medicationCodeableConcept", "type", "MedicationRequest.medicationCodeableConcept must be an object",
        ),
      )
  }
  match field_string(value, "status") {
    Some(
      "active"
      | "on-hold"
      | "cancelled"
      | "completed"
      | "entered-in-error"
      | "stopped"
      | "draft"
      | "unknown"
    )
    | None => ()
    Some(_) =>
      issues.push(
        issue(
          "/status",
          "value",
          "MedicationRequest.status is outside the common FHIR value set",
          severity="warning",
        ),
      )
  }
}

///|
fn validate_condition(issues : Array[Issue], value : Json) -> Unit {
  match object_get(value, "clinicalStatus") {
    Some(Object(_)) | None => ()
    Some(_) =>
      issues.push(
        issue(
          "/clinicalStatus", "type", "Condition.clinicalStatus must be an object",
        ),
      )
  }
  match object_get(value, "code") {
    Some(Object(_)) => ()
    Some(_) =>
      issues.push(issue("/code", "type", "Condition.code must be an object"))
    None =>
      issues.push(issue("/code", "required", "Condition.code is required"))
  }
}

///|
fn validate_procedure(issues : Array[Issue], value : Json) -> Unit {
  require_string(issues, value, "status", "/status")
  match object_get(value, "code") {
    Some(Object(_)) => ()
    Some(_) =>
      issues.push(issue("/code", "type", "Procedure.code must be an object"))
    None =>
      issues.push(issue("/code", "required", "Procedure.code is required"))
  }
}

///|
fn validate_immunization(issues : Array[Issue], value : Json) -> Unit {
  require_string(issues, value, "status", "/status")
  match object_get(value, "vaccineCode") {
    Some(Object(_)) => ()
    Some(_) =>
      issues.push(
        issue(
          "/vaccineCode", "type", "Immunization.vaccineCode must be an object",
        ),
      )
    None =>
      issues.push(
        issue(
          "/vaccineCode", "required", "Immunization.vaccineCode is required",
        ),
      )
  }
}

///|
fn validate_allergy_intolerance(issues : Array[Issue], value : Json) -> Unit {
  match field_string(value, "clinicalStatus") {
    Some(_) | None => ()
  }
  match object_get(value, "code") {
    Some(Object(_)) => ()
    Some(_) =>
      issues.push(
        issue("/code", "type", "AllergyIntolerance.code must be an object"),
      )
    None =>
      issues.push(
        issue("/code", "required", "AllergyIntolerance.code is required"),
      )
  }
}

///|
fn validate_care_plan(issues : Array[Issue], value : Json) -> Unit {
  require_string(issues, value, "status", "/status")
  require_string(issues, value, "intent", "/intent")
}

///|
fn validate_identity_resource(issues : Array[Issue], value : Json) -> Unit {
  match resource_kind(value) {
    Organization | Location | Practitioner =>
      match field_string(value, "name") {
        Some(name) =>
          if name == "" {
            issues.push(issue("/name", "empty", "name must not be empty"))
          }
        None => ()
      }
    _ => ()
  }
}

///|
fn validate_workflow_resource(issues : Array[Issue], value : Json) -> Unit {
  match resource_kind(value) {
    ServiceRequest => {
      require_string(issues, value, "status", "/status")
      require_string(issues, value, "intent", "/intent")
      match object_get(value, "code") {
        Some(Object(_)) | None => ()
        Some(_) =>
          issues.push(
            issue("/code", "type", "ServiceRequest.code must be an object"),
          )
      }
    }
    Goal => {
      require_string(issues, value, "lifecycleStatus", "/lifecycleStatus")
      match object_get(value, "description") {
        Some(Object(_)) | None => ()
        Some(_) =>
          issues.push(
            issue("/description", "type", "Goal.description must be an object"),
          )
      }
    }
    CareTeam => {
      require_string(issues, value, "status", "/status")
      require_array(issues, value, "participant", "/participant")
    }
    Device =>
      match object_get(value, "type") {
        Some(Object(_)) | None => ()
        Some(_) =>
          issues.push(issue("/type", "type", "Device.type must be an object"))
      }
    Specimen =>
      match object_get(value, "type") {
        Some(Object(_)) | None => ()
        Some(_) =>
          issues.push(issue("/type", "type", "Specimen.type must be an object"))
      }
    Questionnaire => require_string(issues, value, "status", "/status")
    List => {
      require_string(issues, value, "status", "/status")
      require_string(issues, value, "mode", "/mode")
    }
    Composition => {
      require_string(issues, value, "status", "/status")
      match object_get(value, "type") {
        Some(Object(_)) => ()
        Some(_) =>
          issues.push(
            issue(
              "/type", "required", "Composition.type is required and must be an object",
            ),
          )
        None =>
          issues.push(
            issue("/type", "required", "Composition.type is required"),
          )
      }
    }
    DocumentReference => require_string(issues, value, "status", "/status")
    Provenance => require_array(issues, value, "agent", "/agent")
    AuditEvent =>
      match object_get(value, "type") {
        Some(Object(_)) => ()
        Some(_) =>
          issues.push(issue("/type", "required", "AuditEvent.type is required"))
        None =>
          issues.push(issue("/type", "required", "AuditEvent.type is required"))
      }
    _ => ()
  }
}

///|
fn validate_diagnostic_report(issues : Array[Issue], value : Json) -> Unit {
  require_string(issues, value, "status", "/status")
  match object_get(value, "code") {
    Some(Object(_)) => ()
    Some(_) =>
      issues.push(
        issue("/code", "type", "DiagnosticReport.code must be an object"),
      )
    None =>
      issues.push(
        issue("/code", "required", "DiagnosticReport.code is required"),
      )
  }
}

///|
fn validate_encounter(issues : Array[Issue], value : Json) -> Unit {
  require_string(issues, value, "status", "/status")
  match object_get(value, "class") {
    Some(Object(_)) | None => ()
    Some(_) =>
      issues.push(issue("/class", "type", "Encounter.class must be an object"))
  }
}

///|
fn validate_bundle(issues : Array[Issue], value : Json) -> Unit {
  require_string(issues, value, "type", "/type")
  require_array(issues, value, "entry", "/entry")
  for index, entry in field_array(value, "entry").unwrap_or([]) {
    match object_get(entry, "resource") {
      Some(resource) =>
        if !is_supported_resource(resource) {
          issues.push(
            issue(
              "/entry/\{index}/resource/resourceType",
              "unsupported",
              "Bundle entry contains an unsupported resource type",
              severity="warning",
            ),
          )
        }
      None =>
        issues.push(
          issue(
            "/entry/\{index}/resource",
            "required",
            "Bundle.entry.resource is required",
          ),
        )
    }
  }
}

///|
pub fn validate_resource(
  value : Json,
  version? : FhirVersion = R4,
) -> ValidationReport {
  let issues : Array[Issue] = []
  match value {
    Object(_) => ()
    _ => issues.push(issue("", "type", "FHIR resource must be a JSON object"))
  }
  match resource_type(value) {
    Some("") =>
      issues.push(
        issue("/resourceType", "empty", "resourceType must not be empty"),
      )
    Some(_) => ()
    None =>
      issues.push(
        issue("/resourceType", "required", "resourceType is required"),
      )
  }
  match resource_kind(value) {
    Patient => validate_patient(issues, value)
    Observation => validate_observation(issues, value)
    Medication => validate_medication(issues, value)
    MedicationRequest => validate_medication_request(issues, value)
    DiagnosticReport => validate_diagnostic_report(issues, value)
    Encounter => validate_encounter(issues, value)
    Condition => validate_condition(issues, value)
    Procedure => validate_procedure(issues, value)
    Immunization => validate_immunization(issues, value)
    AllergyIntolerance => validate_allergy_intolerance(issues, value)
    CarePlan => validate_care_plan(issues, value)
    Practitioner | Organization | Location =>
      validate_identity_resource(issues, value)
    ServiceRequest
    | Goal
    | CareTeam
    | Device
    | Specimen
    | Questionnaire
    | List
    | Composition
    | DocumentReference
    | Provenance
    | AuditEvent => validate_workflow_resource(issues, value)
    Bundle => validate_bundle(issues, value)
    Other(name) =>
      if name.length() > 0 {
        issues.push(
          issue(
            "/resourceType",
            "unsupported",
            "resource type \{name} is not in the first supported set",
            severity="warning",
          ),
        )
      }
  }
  { resource_type: resource_type(value).unwrap_or(""), version, issues }
}

///|
pub fn is_valid(value : Json, version? : FhirVersion = R4) -> Bool {
  let report = validate_resource(value, version~)
  for has_error = false, i = 0; i < report.issues.length(); {
    if report.issues[i].severity == "error" {
      continue true, report.issues.length()
    } else {
      continue has_error, i + 1
    }
  } nobreak {
    !has_error
  }
}

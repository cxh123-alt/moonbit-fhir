///|
pub(all) enum FhirVersion {
  R4
  R5
} derive(Debug, Eq, ToJson)

///|
pub(all) enum ResourceKind {
  Patient
  Observation
  Medication
  MedicationRequest
  DiagnosticReport
  Encounter
  Condition
  Procedure
  Immunization
  AllergyIntolerance
  CarePlan
  Practitioner
  Organization
  Location
  ServiceRequest
  Goal
  CareTeam
  Device
  Specimen
  Questionnaire
  List
  Composition
  DocumentReference
  Provenance
  AuditEvent
  Bundle
  Other(String)
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Issue {
  path : String
  code : String
  message : String
  severity : String
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ValidationReport {
  resource_type : String
  version : FhirVersion
  issues : Array[Issue]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct BundleEntry {
  full_url : String?
  resource_type : String
  id : String?
} derive(Debug, Eq, ToJson)

///|
pub(all) struct PatientSummary {
  id : String?
  display_name : String?
  gender : String?
  birth_date : String?
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ObservationSummary {
  id : String?
  status : String?
  code_text : String?
  subject : String?
  value : String?
  issued : String?
} derive(Debug, Eq, ToJson)

///|
pub(all) struct MedicationSummary {
  id : String?
  code_text : String?
  status : String?
  form_text : String?
} derive(Debug, Eq, ToJson)

///|
pub(all) struct DiagnosticReportSummary {
  id : String?
  status : String?
  code_text : String?
  subject : String?
  result_count : Int
} derive(Debug, Eq, ToJson)

///|
pub(all) struct EncounterSummary {
  id : String?
  status : String?
  class_code : String?
  subject : String?
} derive(Debug, Eq, ToJson)

///|
pub fn FhirVersion::to_string(self : FhirVersion) -> String {
  match self {
    R4 => "R4"
    R5 => "R5"
  }
}

///|
pub fn ResourceKind::to_string(self : ResourceKind) -> String {
  match self {
    Patient => "Patient"
    Observation => "Observation"
    Medication => "Medication"
    MedicationRequest => "MedicationRequest"
    DiagnosticReport => "DiagnosticReport"
    Encounter => "Encounter"
    Condition => "Condition"
    Procedure => "Procedure"
    Immunization => "Immunization"
    AllergyIntolerance => "AllergyIntolerance"
    CarePlan => "CarePlan"
    Practitioner => "Practitioner"
    Organization => "Organization"
    Location => "Location"
    ServiceRequest => "ServiceRequest"
    Goal => "Goal"
    CareTeam => "CareTeam"
    Device => "Device"
    Specimen => "Specimen"
    Questionnaire => "Questionnaire"
    List => "List"
    Composition => "Composition"
    DocumentReference => "DocumentReference"
    Provenance => "Provenance"
    AuditEvent => "AuditEvent"
    Bundle => "Bundle"
    Other(name) => name
  }
}

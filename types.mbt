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
  DiagnosticReport
  Encounter
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

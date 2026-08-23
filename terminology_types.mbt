///|
pub(all) struct CodeRule {
  system : String?
  code : String
  display : String?
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ValueSet {
  name : String
  system : String?
  codes : Array[String]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct TerminologyIssue {
  path : String
  system : String?
  code : String
  message : String
} derive(Debug, Eq, ToJson)

///|
pub fn ValueSet::new(
  name : String,
  system : String?,
  codes : Array[String],
) -> ValueSet {
  { name, system, codes }
}

///|
pub fn ValueSet::contains(self : ValueSet, code : String) -> Bool {
  self.codes.contains(code)
}

///|
pub fn ValueSet::size(self : ValueSet) -> Int {
  self.codes.length()
}

///|
pub fn common_observation_status() -> ValueSet {
  ValueSet::new("Observation.status", None, [
    "registered", "preliminary", "final", "amended", "corrected", "cancelled", "entered-in-error",
    "unknown",
  ])
}

///|
pub fn common_medication_status() -> ValueSet {
  ValueSet::new("Medication.status", None, [
    "active", "inactive", "entered-in-error",
  ])
}

///|
pub fn common_encounter_status() -> ValueSet {
  ValueSet::new("Encounter.status", None, [
    "planned", "arrived", "triaged", "in-progress", "onleave", "finished", "cancelled",
    "entered-in-error", "unknown",
  ])
}

///|
pub fn common_condition_status() -> ValueSet {
  ValueSet::new(
    "Condition.clinicalStatus",
    Some("http://terminology.hl7.org/CodeSystem/condition-clinical"),
    ["active", "recurrence", "relapse", "inactive", "remission", "resolved"],
  )
}

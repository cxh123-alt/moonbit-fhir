///|
pub(all) struct ConditionSummary {
  id : String?
  code_text : String?
  clinical_status : String?
  subject : String?
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ProcedureSummary {
  id : String?
  status : String?
  code_text : String?
  subject : String?
  performed : String?
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ImmunizationSummary {
  id : String?
  status : String?
  vaccine_text : String?
  patient : String?
  occurrence : String?
} derive(Debug, Eq, ToJson)

///|
pub(all) struct AllergyIntoleranceSummary {
  id : String?
  clinical_status : String?
  verification_status : String?
  code_text : String?
  patient : String?
} derive(Debug, Eq, ToJson)

///|
pub(all) struct CarePlanSummary {
  id : String?
  status : String?
  intent : String?
  title : String?
  subject : String?
} derive(Debug, Eq, ToJson)

///|
pub(all) struct MedicationRequestSummary {
  id : String?
  status : String?
  intent : String?
  medication_text : String?
  subject : String?
} derive(Debug, Eq, ToJson)

///|
pub fn supported_kind_name(value : Json) -> String {
  resource_kind(value).to_string()
}

///|
pub fn resource_has_id(value : Json) -> Bool {
  match field_string(value, "id") {
    Some(id) => id.length() > 0
    None => false
  }
}

///|
pub fn condition_summary(value : Json) -> ConditionSummary {
  {
    id: field_string(value, "id"),
    code_text: match object_get(value, "code") {
      Some(code) => codeable_text(code)
      None => None
    },
    clinical_status: match object_get(value, "clinicalStatus") {
      Some(status) => codeable_text(status)
      None => None
    },
    subject: match object_get(value, "subject") {
      Some(subject) => reference_text(subject)
      None => None
    },
  }
}

///|
pub fn procedure_summary(value : Json) -> ProcedureSummary {
  {
    id: field_string(value, "id"),
    status: field_string(value, "status"),
    code_text: match object_get(value, "code") {
      Some(code) => codeable_text(code)
      None => None
    },
    subject: match object_get(value, "subject") {
      Some(subject) => reference_text(subject)
      None => None
    },
    performed: field_string(value, "performedDateTime"),
  }
}

///|
pub fn immunization_summary(value : Json) -> ImmunizationSummary {
  {
    id: field_string(value, "id"),
    status: field_string(value, "status"),
    vaccine_text: match object_get(value, "vaccineCode") {
      Some(code) => codeable_text(code)
      None => None
    },
    patient: match object_get(value, "patient") {
      Some(patient) => reference_text(patient)
      None => None
    },
    occurrence: field_string(value, "occurrenceDateTime"),
  }
}

///|
pub fn allergy_intolerance_summary(value : Json) -> AllergyIntoleranceSummary {
  {
    id: field_string(value, "id"),
    clinical_status: match object_get(value, "clinicalStatus") {
      Some(status) => codeable_text(status)
      None => None
    },
    verification_status: match object_get(value, "verificationStatus") {
      Some(status) => codeable_text(status)
      None => None
    },
    code_text: match object_get(value, "code") {
      Some(code) => codeable_text(code)
      None => None
    },
    patient: match object_get(value, "patient") {
      Some(patient) => reference_text(patient)
      None => None
    },
  }
}

///|
pub fn care_plan_summary(value : Json) -> CarePlanSummary {
  {
    id: field_string(value, "id"),
    status: field_string(value, "status"),
    intent: field_string(value, "intent"),
    title: field_string(value, "title"),
    subject: match object_get(value, "subject") {
      Some(subject) => reference_text(subject)
      None => None
    },
  }
}

///|
pub fn medication_request_summary(value : Json) -> MedicationRequestSummary {
  {
    id: field_string(value, "id"),
    status: field_string(value, "status"),
    intent: field_string(value, "intent"),
    medication_text: match object_get(value, "medicationCodeableConcept") {
      Some(medication) => codeable_text(medication)
      None => None
    },
    subject: match object_get(value, "subject") {
      Some(subject) => reference_text(subject)
      None => None
    },
  }
}

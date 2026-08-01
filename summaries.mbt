///|
pub fn patient_summary(value : Json) -> PatientSummary {
  let display_name = match field_array(value, "name") {
    Some(names) =>
      if names.length() == 0 {
        None
      } else {
        let first = names[0]
        match field_string(first, "text") {
          Some(text) => Some(text)
          None =>
            match field_array(first, "given") {
              Some(given) =>
                match first_string(given) {
                  Some(first_given) =>
                    match field_string(first, "family") {
                      Some(family) => Some("\{first_given} \{family}")
                      None => Some(first_given)
                    }
                  None => field_string(first, "family")
                }
              None => field_string(first, "family")
            }
        }
      }
    None => None
  }
  {
    id: field_string(value, "id"),
    display_name,
    gender: field_string(value, "gender"),
    birth_date: field_string(value, "birthDate"),
  }
}

///|
pub fn observation_summary(value : Json) -> ObservationSummary {
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
    value: match object_get(value, "valueString") {
      Some(v) => as_scalar_text(v)
      None =>
        match object_get(value, "valueQuantity") {
          Some(q) =>
            match object_get(q, "value") {
              Some(v) => as_scalar_text(v)
              None => None
            }
          None => None
        }
    },
    issued: field_string(value, "issued"),
  }
}

///|
pub fn medication_summary(value : Json) -> MedicationSummary {
  {
    id: field_string(value, "id"),
    code_text: match object_get(value, "code") {
      Some(code) => codeable_text(code)
      None => None
    },
    status: field_string(value, "status"),
    form_text: match object_get(value, "form") {
      Some(form) => codeable_text(form)
      None => None
    },
  }
}

///|
pub fn diagnostic_report_summary(value : Json) -> DiagnosticReportSummary {
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
    result_count: field_array(value, "result").unwrap_or([]).length(),
  }
}

///|
pub fn encounter_summary(value : Json) -> EncounterSummary {
  {
    id: field_string(value, "id"),
    status: field_string(value, "status"),
    class_code: match object_get(value, "class") {
      Some(class_) => first_coding_code(class_)
      None => None
    },
    subject: match object_get(value, "subject") {
      Some(subject) => reference_text(subject)
      None => None
    },
  }
}

///|
pub fn observation_csv_row(value : Json) -> String {
  let summary = observation_summary(value)
  [
    summary.id.unwrap_or(""),
    summary.status.unwrap_or(""),
    summary.code_text.unwrap_or(""),
    summary.subject.unwrap_or(""),
    summary.value.unwrap_or(""),
    summary.issued.unwrap_or(""),
  ].join(",")
}

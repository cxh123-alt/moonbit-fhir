///|
pub(all) struct CommonResourceSummary {
  resource_type : String
  id : String?
  status : String?
  display : String?
  subject : String?
  date : String?
} derive(Debug, Eq, ToJson)

///|
fn first_nonempty_path(value : Json, paths : Array[String]) -> String? {
  for path in paths {
    let text = query_text(value, path, fallback="")
    if text != "" {
      return Some(text)
    }
  }
  None
}

///|
pub fn resource_subject(value : Json) -> String? {
  first_nonempty_path(value, [
    "subject.reference", "patient.reference", "individual.reference", "for.reference",
    "focus.reference",
  ])
}

///|
pub fn resource_status(value : Json) -> String? {
  first_nonempty_path(value, [
    "status", "clinicalStatus.coding[0].code", "lifecycleStatus", "verificationStatus.coding[0].code",
  ])
}

///|
pub fn resource_date(value : Json) -> String? {
  first_nonempty_path(value, [
    "issued", "effectiveDateTime", "performedDateTime", "occurrenceDateTime", "authoredOn",
    "recorded", "date", "created",
  ])
}

///|
pub fn resource_code_text(value : Json) -> String? {
  for path in ["code", "vaccineCode", "type", "category", "class"] {
    match query_first(value, path) {
      None => ()
      Some(item) =>
        match codeable_text(item) {
          Some(text) => return Some(text)
          None => ()
        }
    }
  }
  None
}

///|
pub fn common_resource_summary(value : Json) -> CommonResourceSummary {
  {
    resource_type: resource_type(value).unwrap_or(""),
    id: field_string(value, "id"),
    status: resource_status(value),
    display: Some(resource_display_name(value)),
    subject: resource_subject(value),
    date: resource_date(value),
  }
}

///|
pub fn service_request_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn goal_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn care_team_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn device_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn specimen_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn questionnaire_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn list_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn composition_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn document_reference_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn provenance_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn audit_event_summary(value : Json) -> CommonResourceSummary {
  common_resource_summary(value)
}

///|
pub fn summaries_for_resources(
  values : Array[Json],
) -> Array[CommonResourceSummary] {
  values.map(common_resource_summary)
}

///|
pub fn summary_display_lines(values : Array[Json]) -> Array[String] {
  values.map(fn(value) {
    let summary = common_resource_summary(value)
    csv_row([
      summary.resource_type,
      summary.id.unwrap_or(""),
      summary.status.unwrap_or(""),
      summary.display.unwrap_or(""),
      summary.subject.unwrap_or(""),
      summary.date.unwrap_or(""),
    ])
  })
}

///|
pub fn summary_csv_header() -> String {
  "resourceType,id,status,display,subject,date"
}

///|
pub fn summary_csv(values : Array[Json]) -> String {
  [summary_csv_header()].add(summary_display_lines(values)).join("\n")
}

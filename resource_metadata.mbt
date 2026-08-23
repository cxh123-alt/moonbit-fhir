///|
pub(all) enum ResourceCategory {
  Clinical
  Administrative
  Workflow
  Infrastructure
  Exchange
  Unknown
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ResourceMetadata {
  resource_type : String
  category : ResourceCategory
  supported : Bool
  required_fields : Array[String]
  reference_fields : Array[String]
  date_fields : Array[String]
  description : String
} derive(Debug, Eq, ToJson)

///|
fn metadata(
  kind : String,
  category : ResourceCategory,
  required : Array[String],
  references : Array[String],
  dates : Array[String],
  description : String,
) -> ResourceMetadata {
  {
    resource_type: kind,
    category,
    supported: true,
    required_fields: required,
    reference_fields: references,
    date_fields: dates,
    description,
  }
}

///|
pub fn resource_metadata(kind : String) -> ResourceMetadata {
  match kind {
    "Patient" =>
      metadata(
        kind,
        Clinical,
        ["resourceType"],
        ["generalPractitioner"],
        ["birthDate"],
        "individual demographic record",
      )
    "Observation" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "status", "code"],
        ["subject", "encounter"],
        ["issued", "effectiveDateTime"],
        "measurement or assertion",
      )
    "Condition" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "code"],
        ["subject", "encounter"],
        ["onsetDateTime", "recordedDate"],
        "clinical condition",
      )
    "Procedure" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "status", "code"],
        ["subject", "encounter", "performer"],
        ["performedDateTime"],
        "clinical procedure",
      )
    "Medication" =>
      metadata(
        kind,
        Clinical,
        ["resourceType"],
        [],
        [],
        "medication definition",
      )
    "MedicationRequest" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "status", "intent"],
        ["subject", "encounter", "requester"],
        ["authoredOn"],
        "medication order",
      )
    "DiagnosticReport" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "status", "code"],
        ["subject", "encounter", "result"],
        ["issued"],
        "diagnostic report",
      )
    "Encounter" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "status", "class"],
        ["subject", "participant"],
        ["period.start", "period.end"],
        "care encounter",
      )
    "Immunization" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "status", "vaccineCode"],
        ["patient", "encounter", "performer"],
        ["occurrenceDateTime"],
        "immunization record",
      )
    "AllergyIntolerance" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "code"],
        ["patient", "encounter", "recorder"],
        ["recordedDate"],
        "allergy or intolerance",
      )
    "CarePlan" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "status", "intent"],
        ["subject", "encounter", "author"],
        ["period.start", "period.end"],
        "care coordination plan",
      )
    "Practitioner" =>
      metadata(
        kind,
        Administrative,
        ["resourceType"],
        ["organization"],
        [],
        "care practitioner",
      )
    "Organization" =>
      metadata(
        kind,
        Administrative,
        ["resourceType"],
        ["partOf"],
        [],
        "care organization",
      )
    "Location" =>
      metadata(
        kind,
        Administrative,
        ["resourceType"],
        ["managingOrganization"],
        [],
        "physical location",
      )
    "ServiceRequest" =>
      metadata(
        kind,
        Workflow,
        ["resourceType", "status", "intent"],
        ["subject", "encounter", "requester"],
        ["authoredOn"],
        "service request",
      )
    "Goal" =>
      metadata(
        kind,
        Workflow,
        ["resourceType", "lifecycleStatus", "description"],
        ["subject", "expressedBy"],
        ["startDate"],
        "care goal",
      )
    "CareTeam" =>
      metadata(
        kind,
        Workflow,
        ["resourceType", "status"],
        ["subject", "participant"],
        [],
        "care team",
      )
    "Device" =>
      metadata(
        kind,
        Infrastructure,
        ["resourceType", "type"],
        ["patient", "owner", "location"],
        ["manufactureDate", "expirationDate"],
        "medical device",
      )
    "Specimen" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "type"],
        ["subject", "parent", "request"],
        ["receivedTime", "collection.collectedDateTime"],
        "sample specimen",
      )
    "Questionnaire" =>
      metadata(
        kind,
        Workflow,
        ["resourceType", "status"],
        [],
        ["date"],
        "questionnaire definition",
      )
    "List" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "status", "mode"],
        ["subject", "encounter", "source"],
        ["date"],
        "curated list",
      )
    "Composition" =>
      metadata(
        kind,
        Clinical,
        ["resourceType", "status", "type"],
        ["subject", "encounter", "author"],
        ["date"],
        "clinical composition",
      )
    "DocumentReference" =>
      metadata(
        kind,
        Exchange,
        ["resourceType", "status"],
        ["subject", "author", "custodian"],
        ["date"],
        "document reference",
      )
    "Provenance" =>
      metadata(
        kind,
        Exchange,
        ["resourceType", "agent"],
        ["target", "agent.who", "onBehalfOf"],
        ["recorded"],
        "provenance record",
      )
    "AuditEvent" =>
      metadata(
        kind,
        Administrative,
        ["resourceType", "type"],
        ["agent", "entity.what", "source.observer"],
        ["recorded"],
        "security audit event",
      )
    "Bundle" =>
      metadata(
        kind,
        Exchange,
        ["resourceType", "type", "entry"],
        ["entry.resource"],
        ["timestamp"],
        "FHIR exchange envelope",
      )
    _ =>
      {
        resource_type: kind,
        category: Unknown,
        supported: false,
        required_fields: [],
        reference_fields: [],
        date_fields: [],
        description: "unknown resource type",
      }
  }
}

///|
pub fn metadata_category_name(category : ResourceCategory) -> String {
  match category {
    Clinical => "clinical"
    Administrative => "administrative"
    Workflow => "workflow"
    Infrastructure => "infrastructure"
    Exchange => "exchange"
    Unknown => "unknown"
  }
}

///|
pub fn known_resource_types() -> Array[String] {
  [
    "Patient", "Observation", "Medication", "MedicationRequest", "DiagnosticReport",
    "Encounter", "Condition", "Procedure", "Immunization", "AllergyIntolerance",
    "CarePlan", "Practitioner", "Organization", "Location", "ServiceRequest", "Goal",
    "CareTeam", "Device", "Specimen", "Questionnaire", "List", "Composition", "DocumentReference",
    "Provenance", "AuditEvent", "Bundle",
  ]
}

///|
pub fn is_known_resource_type(kind : String) -> Bool {
  known_resource_types().contains(kind)
}

///|
pub fn resource_category(kind : String) -> ResourceCategory {
  resource_metadata(kind).category
}

///|
pub fn resource_required_fields(kind : String) -> Array[String] {
  resource_metadata(kind).required_fields
}

///|
pub fn resource_reference_fields(kind : String) -> Array[String] {
  resource_metadata(kind).reference_fields
}

///|
pub fn resource_date_fields(kind : String) -> Array[String] {
  resource_metadata(kind).date_fields
}

///|
pub fn metadata_summary(kind : String) -> String {
  let data = resource_metadata(kind)
  "\{kind}: \{metadata_category_name(data.category)} required=\{data.required_fields.length()} references=\{data.reference_fields.length()}"
}

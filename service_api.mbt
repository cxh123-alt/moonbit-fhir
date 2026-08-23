///|
pub(all) struct FhirService {
  options : ProcessingOptions
  catalog : TerminologyCatalog
} derive(Debug, Eq, ToJson)

///|
pub fn FhirService::new(options : ProcessingOptions) -> FhirService {
  { options, catalog: default_terminology_catalog() }
}

///|
pub fn FhirService::default() -> FhirService {
  FhirService::new(ProcessingOptions::default())
}

///|
pub fn FhirService::strict() -> FhirService {
  FhirService::new(ProcessingOptions::strict())
}

///|
pub fn FhirService::validate(
  self : FhirService,
  value : Json,
) -> ValidationReport {
  process_resources([value], self.options).reports[0]
}

///|
pub fn FhirService::validate_many(
  self : FhirService,
  values : Array[Json],
) -> ProcessingResult {
  process_resources(values, self.options)
}

///|
pub fn FhirService::validate_ndjson(
  self : FhirService,
  text : String,
) -> ProcessingResult {
  process_ndjson(text, self.options)
}

///|
pub fn FhirService::search(
  _self : FhirService,
  values : Array[Json],
  query : String,
) -> Array[Json] {
  search_resources(values, query)
}

///|
pub fn FhirService::summarize(
  self : FhirService,
  values : Array[Json],
) -> String {
  processing_summary(self.validate_many(values))
}

///|
pub fn FhirService::export_data(
  _self : FhirService,
  values : Array[Json],
  options : ExportOptions,
) -> String {
  export_resources(values, options)
}

///|
pub fn FhirService::quality(
  _self : FhirService,
  values : Array[Json],
) -> BatchQuality {
  batch_quality(values)
}

///|
pub fn FhirService::schema(self : FhirService, kind : String) -> ResourceSchema {
  schema_for(kind, version=self.options.version)
}

///|
pub fn FhirService::terminology_contains(
  self : FhirService,
  set_name : String,
  code : String,
) -> Bool {
  self.catalog.contains(set_name, code)
}

///|
pub fn FhirService::query(
  _self : FhirService,
  value : Json,
  expression : String,
) -> Array[Json] {
  query_values(value, expression)
}

///|
pub fn FhirService::redact(
  _self : FhirService,
  value : Json,
  policy : PrivacyPolicy,
) -> Json {
  redact_by_policy(value, policy)
}

///|
pub fn FhirService::bundle_report(
  _self : FhirService,
  bundle : Json,
) -> BundleValidation {
  validate_bundle_structure(bundle)
}

///|
pub fn FhirService::graph(_self : FhirService, bundle : Json) -> BundleGraph {
  bundle_graph(bundle)
}

///|
pub fn FhirService::metadata(
  _self : FhirService,
  kind : String,
) -> ResourceMetadata {
  resource_metadata(kind)
}

///|
pub fn service_validate_json(
  service : FhirService,
  text : String,
) -> OperationResult {
  match parse_json(text) {
    Some(value) =>
      match service.options.profile {
        None => operation_validate(value)
        Some(profile) => operation_validate(value, profile~)
      }
    None => {
      let issue_item = issue("", "json", "input is not valid JSON")
      { success: false, resource: Json::null(), issues: [issue_item] }
    }
  }
}

///|
pub fn service_validate_text(service : FhirService, text : String) -> String {
  report_text(
    service_validate_json(service, text).issues.fold(
      init={ resource_type: "", version: R4, issues: [] },
      fn(report, item) {
        report.issues.push(item)
        report
      },
    ),
  )
}

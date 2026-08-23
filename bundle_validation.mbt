///|
pub(all) struct BundleValidation {
  bundle_type : String
  entry_count : Int
  resource_count : Int
  missing_resource_entries : Int
  duplicate_ids : Int
  unsupported_resources : Int
  issues : Array[Issue]
} derive(Debug, Eq, ToJson)

///|
pub fn validate_bundle_structure(bundle : Json) -> BundleValidation {
  let issues : Array[Issue] = []
  let entries = field_array(bundle, "entry").unwrap_or([])
  let mut missing = 0
  let mut unsupported = 0
  for index, entry in entries {
    match object_get(entry, "resource") {
      None => {
        missing += 1
        issues.push(
          issue(
            "/entry/\{index}/resource",
            "required",
            "bundle entry must contain resource",
          ),
        )
      }
      Some(resource) =>
        if !is_supported_resource(resource) {
          unsupported += 1
          issues.push(
            issue(
              "/entry/\{index}/resource/resourceType",
              "unsupported",
              "bundle resource type is not supported",
              severity="warning",
            ),
          )
        }
    }
  }
  let analytics = analyze_bundle(bundle)
  {
    bundle_type: field_string(bundle, "type").unwrap_or(""),
    entry_count: entries.length(),
    resource_count: bundle_resources(bundle).length(),
    missing_resource_entries: missing,
    duplicate_ids: analytics.duplicate_ids.length(),
    unsupported_resources: unsupported,
    issues,
  }
}

///|
pub fn bundle_structure_is_valid(bundle : Json) -> Bool {
  let result = validate_bundle_structure(bundle)
  result.missing_resource_entries == 0 && result.duplicate_ids == 0
}

///|
pub fn bundle_quality_score(bundle : Json) -> Int {
  let result = validate_bundle_structure(bundle)
  if result.entry_count == 0 {
    100
  } else {
    result.resource_count * 100 / result.entry_count
  }
}

///|
pub fn bundle_issue_codes(bundle : Json) -> Array[String] {
  validate_bundle_structure(bundle).issues.map(fn(item) { item.code })
}

///|
pub fn bundle_has_duplicate_ids(bundle : Json) -> Bool {
  validate_bundle_structure(bundle).duplicate_ids > 0
}

///|
pub fn bundle_validate_and_filter(bundle : Json) -> (BundleValidation, Json) {
  let result = validate_bundle_structure(bundle)
  (result, bundle_without_invalid(bundle))
}

///|
pub fn bundle_entry_references(bundle : Json) -> Array[String] {
  bundle_resources(bundle).fold(init=[], fn(output, value) {
    output.append(query_resource_references(value)[:])
    output
  })
}

///|
pub fn bundle_reference_histogram(bundle : Json) -> Map[String, Int] {
  let histogram : Map[String, Int] = Map([])
  for reference in bundle_entry_references(bundle) {
    histogram[reference] = histogram.get(reference).unwrap_or(0) + 1
  }
  histogram
}

///|
pub fn bundle_status_summary(bundle : Json) -> String {
  let result = validate_bundle_structure(bundle)
  "type=\{result.bundle_type} entries=\{result.entry_count} resources=\{result.resource_count} missing=\{result.missing_resource_entries} duplicates=\{result.duplicate_ids} unsupported=\{result.unsupported_resources}"
}

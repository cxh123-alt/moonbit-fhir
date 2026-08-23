///|
pub(all) struct BatchQuality {
  total : Int
  valid : Int
  invalid : Int
  warning_resources : Int
  duplicate_ids : Int
  empty_resources : Int
  type_counts : Map[String, Int]
  issue_counts : Map[String, Int]
} derive(Debug, Eq, ToJson)

///|
fn batch_count(map : Map[String, Int], key : String) -> Unit {
  map[key] = map.get(key).unwrap_or(0) + 1
}

///|
pub fn batch_quality(values : Array[Json]) -> BatchQuality {
  let type_counts : Map[String, Int] = Map([])
  let issue_counts : Map[String, Int] = Map([])
  let identities : Map[String, Int] = Map([])
  let mut valid = 0
  let mut invalid = 0
  let mut warnings = 0
  let mut empty = 0
  for value in values {
    let kind = resource_type(value).unwrap_or("")
    if kind == "" {
      empty += 1
    }
    batch_count(type_counts, kind)
    let report = validate_resource(value)
    if report.issues.any(fn(item) { item.severity == "error" }) {
      invalid += 1
    } else {
      valid += 1
    }
    if report.issues.any(fn(item) { item.severity == "warning" }) {
      warnings += 1
    }
    for issue_item in report.issues {
      batch_count(issue_counts, issue_item.code)
    }
    match bundle_reference_key(value) {
      Some(key) => identities[key] = identities.get(key).unwrap_or(0) + 1
      None => ()
    }
  }
  let duplicates = identities
    .values()
    .fold(init=0, fn(total, count) {
      if count > 1 {
        total + count - 1
      } else {
        total
      }
    })
  {
    total: values.length(),
    valid,
    invalid,
    warning_resources: warnings,
    duplicate_ids: duplicates,
    empty_resources: empty,
    type_counts,
    issue_counts,
  }
}

///|
pub fn batch_issue_histogram(values : Array[Json]) -> Map[String, Int] {
  batch_quality(values).issue_counts
}

///|
pub fn batch_type_histogram(values : Array[Json]) -> Map[String, Int] {
  batch_quality(values).type_counts
}

///|
pub fn batch_is_acceptable(values : Array[Json]) -> Bool {
  let quality = batch_quality(values)
  quality.invalid == 0 && quality.empty_resources == 0
}

///|
pub fn batch_quality_score(values : Array[Json]) -> Int {
  let quality = batch_quality(values)
  if quality.total == 0 {
    100
  } else {
    quality.valid * 100 / quality.total
  }
}

///|
pub fn validate_batch(values : Array[Json]) -> Array[ValidationReport] {
  values.map(fn(value) { validate_resource(value) })
}

///|
pub fn filter_resources_by_kind(
  values : Array[Json],
  kind : ResourceKind,
) -> Array[Json] {
  values.filter(fn(value) { resource_kind(value) == kind })
}

///|
pub fn filter_valid_resources(values : Array[Json]) -> Array[Json] {
  values.filter(fn(value) { is_valid(value) })
}

///|
pub fn filter_invalid_resources(values : Array[Json]) -> Array[Json] {
  values.filter(fn(value) { !is_valid(value) })
}

///|
pub fn sort_resources_by_id(values : Array[Json]) -> Array[Json] {
  let output = values.map(fn(value) { value })
  output.sort_by(fn(left, right) {
    String::compare(
      field_string(left, "id").unwrap_or(""),
      field_string(right, "id").unwrap_or(""),
    )
  })
  output
}

///|
pub fn sort_resources_by_type(values : Array[Json]) -> Array[Json] {
  let output = values.map(fn(value) { value })
  output.sort_by(fn(left, right) {
    let type_compare = String::compare(
      resource_type(left).unwrap_or(""),
      resource_type(right).unwrap_or(""),
    )
    if type_compare == 0 {
      String::compare(
        field_string(left, "id").unwrap_or(""),
        field_string(right, "id").unwrap_or(""),
      )
    } else {
      type_compare
    }
  })
  output
}

///|
pub fn group_resources_by_type(
  values : Array[Json],
) -> Map[String, Array[Json]] {
  let grouped : Map[String, Array[Json]] = Map([])
  for value in values {
    let kind = resource_type(value).unwrap_or("")
    match grouped.get(kind) {
      None => grouped[kind] = [value]
      Some(items) => items.push(value)
    }
  }
  grouped
}

///|
pub fn resource_type_count(values : Array[Json], kind : String) -> Int {
  group_resources_by_type(values)
  .get(kind)
  .map(fn(items) { items.length() })
  .unwrap_or(0)
}

///|
pub fn unique_resource_ids(values : Array[Json]) -> Array[String] {
  let seen : Map[String, Bool] = Map([])
  let output : Array[String] = []
  for value in values {
    match field_string(value, "id") {
      None => ()
      Some(id) =>
        if !seen.contains(id) {
          seen[id] = true
          output.push(id)
        }
    }
  }
  output
}

///|
pub fn resource_index(values : Array[Json]) -> Map[String, Json] {
  let index : Map[String, Json] = Map([])
  for value in values {
    match bundle_reference_key(value) {
      Some(key) => index[key] = value
      None => ()
    }
  }
  index
}

///|
pub(all) struct BundleAnalytics {
  total_entries : Int
  resource_count : Int
  unique_ids : Int
  duplicate_ids : Array[String]
  type_counts : Map[String, Int]
  references : Array[String]
  broken_references : Array[String]
} derive(Debug, Eq, ToJson)

///|
fn bundle_increment(map : Map[String, Int], key : String) -> Unit {
  map[key] = map.get(key).unwrap_or(0) + 1
}

///|
fn bundle_reference_key(value : Json) -> String? {
  match resource_type(value) {
    None => None
    Some(kind) =>
      match field_string(value, "id") {
        Some(id) => Some("\{kind}/\{id}")
        None => None
      }
  }
}

///|
pub fn analyze_bundle(bundle : Json) -> BundleAnalytics {
  let entries = field_array(bundle, "entry").unwrap_or([])
  let type_counts : Map[String, Int] = Map([])
  let ids : Map[String, Int] = Map([])
  let duplicate_ids : Array[String] = []
  let references : Array[String] = []
  let resources : Array[Json] = []
  for entry in entries {
    match object_get(entry, "resource") {
      None => ()
      Some(resource) => {
        resources.push(resource)
        bundle_increment(type_counts, resource_type(resource).unwrap_or(""))
        match bundle_reference_key(resource) {
          Some(key) => {
            ids[key] = ids.get(key).unwrap_or(0) + 1
            if ids[key] == 2 {
              duplicate_ids.push(key)
            }
          }
          None => ()
        }
        references.append(query_resource_references(resource)[:])
      }
    }
  }
  let broken_references : Array[String] = []
  for reference in references {
    if !ids.contains(reference) && !broken_references.contains(reference) {
      broken_references.push(reference)
    }
  }
  {
    total_entries: entries.length(),
    resource_count: resources.length(),
    unique_ids: ids.length(),
    duplicate_ids,
    type_counts,
    references,
    broken_references,
  }
}

///|
pub fn bundle_type_count(bundle : Json, kind : String) -> Int {
  analyze_bundle(bundle).type_counts.get(kind).unwrap_or(0)
}

///|
pub fn bundle_duplicate_count(bundle : Json) -> Int {
  analyze_bundle(bundle).duplicate_ids.length()
}

///|
pub fn bundle_reference_count(bundle : Json) -> Int {
  analyze_bundle(bundle).references.length()
}

///|
pub fn bundle_is_consistent(bundle : Json) -> Bool {
  analyze_bundle(bundle).broken_references.length() == 0 &&
  bundle_duplicate_count(bundle) == 0
}

///|
pub fn bundle_analytics_summary(bundle : Json) -> String {
  let stats = analyze_bundle(bundle)
  "entries=\{stats.total_entries} resources=\{stats.resource_count} unique_ids=\{stats.unique_ids} duplicates=\{stats.duplicate_ids.length()} references=\{stats.references.length()} broken=\{stats.broken_references.length()}"
}

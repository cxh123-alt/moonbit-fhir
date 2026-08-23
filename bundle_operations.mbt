///|
pub fn bundle_resources(bundle : Json) -> Array[Json] {
  field_array(bundle, "entry")
  .unwrap_or([])
  .filter_map(fn(entry) { object_get(entry, "resource") })
}

///|
pub fn bundle_resource_at(bundle : Json, index : Int) -> Json? {
  bundle_resources(bundle).get(index)
}

///|
pub fn bundle_has_resource_type(bundle : Json, kind : String) -> Bool {
  bundle_resources(bundle).any(fn(resource) {
    resource_type(resource) == Some(kind)
  })
}

///|
pub fn bundle_resource_ids(bundle : Json) -> Array[String] {
  bundle_resources(bundle).filter_map(fn(value) { field_string(value, "id") })
}

///|
pub fn bundle_page(bundle : Json, offset : Int, limit : Int) -> Array[Json] {
  let resources = bundle_resources(bundle)
  let output : Array[Json] = []
  if offset < 0 || limit <= 0 {
    output
  } else {
    for index, resource in resources {
      if index >= offset && index < offset + limit {
        output.push(resource)
      }
    }
    output
  }
}

///|
pub fn bundle_filter_valid(bundle : Json) -> Array[Json] {
  bundle_resources(bundle).filter(fn(value) { is_valid(value) })
}

///|
pub fn bundle_filter_kind(bundle : Json, kind : ResourceKind) -> Array[Json] {
  bundle_resources(bundle).filter(fn(value) { resource_kind(value) == kind })
}

///|
pub fn bundle_rebuild(bundle : Json, resources : Array[Json]) -> Json {
  let entries = resources.map(fn(resource) {
    Json::object(Map([("resource", resource)]))
  })
  match bundle {
    Object(fields) => {
      fields["entry"] = Json::array(entries)
      Json::object(fields)
    }
    _ => bundle
  }
}

///|
pub fn bundle_without_invalid(bundle : Json) -> Json {
  bundle_rebuild(bundle, bundle_filter_valid(bundle))
}

///|
pub fn bundle_entry_count_by_type(bundle : Json) -> Map[String, Int] {
  batch_type_histogram(bundle_resources(bundle))
}

///|
pub fn bundle_entry_csv(bundle : Json) -> String {
  summary_csv(bundle_resources(bundle))
}

///|
pub fn bundle_entry_ndjson(bundle : Json) -> String {
  bundle_resources(bundle).map(fn(value) { canonical_json(value) }).join("\n")
}

///|
pub fn bundle_payload_size(bundle : Json) -> Int {
  bundle_entry_ndjson(bundle).length()
}

///|
pub fn bundle_empty(bundle : Json) -> Bool {
  bundle_resources(bundle).length() == 0
}

///|
pub fn bundle_resource_type_list(bundle : Json) -> Array[String] {
  bundle_resources(bundle).map(fn(value) { resource_type(value).unwrap_or("") })
}

///|
pub fn bundle_type_summary(bundle : Json) -> String {
  let counts = bundle_entry_count_by_type(bundle)
  let parts : Array[String] = []
  for kind, count in counts {
    parts.push("\{kind}=\{count}")
  }
  parts.join(", ")
}

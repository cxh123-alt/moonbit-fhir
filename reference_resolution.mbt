///|
pub(all) struct ReferenceResolution {
  reference : String
  target_type : String?
  target_id : String?
  resolved : Bool
  target : Json?
} derive(Debug, Eq, ToJson)

///|
pub fn resolve_reference(
  reference : String,
  values : Array[Json],
) -> ReferenceResolution {
  let target_type = reference_resource_type(reference)
  let target_id = reference_resource_id(reference)
  let target = match target_type {
    None => None
    Some(kind) =>
      match target_id {
        Some(id) => find_first_resource(values, kind, id)
        None => None
      }
  }
  { reference, target_type, target_id, resolved: target is Some(_), target }
}

///|
pub fn resolve_references(
  value : Json,
  values : Array[Json],
) -> Array[ReferenceResolution] {
  query_resource_references(value).map(fn(reference) {
    resolve_reference(reference, values)
  })
}

///|
pub fn unresolved_references(
  value : Json,
  values : Array[Json],
) -> Array[String] {
  resolve_references(value, values).filter_map(fn(result) {
    if result.resolved {
      None
    } else {
      Some(result.reference)
    }
  })
}

///|
pub fn resolved_references(value : Json, values : Array[Json]) -> Array[Json] {
  resolve_references(value, values).filter_map(fn(result) { result.target })
}

///|
pub fn all_references_resolve(values : Array[Json]) -> Bool {
  values.all(fn(value) { unresolved_references(value, values).length() == 0 })
}

///|
pub fn reference_target_counts(values : Array[Json]) -> Map[String, Int] {
  let counts : Map[String, Int] = Map([])
  for value in values {
    for reference in query_resource_references(value) {
      counts[reference] = counts.get(reference).unwrap_or(0) + 1
    }
  }
  counts
}

///|
pub fn resources_referencing(
  values : Array[Json],
  reference : String,
) -> Array[Json] {
  values.filter(fn(value) {
    query_resource_references(value).contains(reference)
  })
}

///|
pub fn reference_graph_edges(values : Array[Json]) -> Array[GraphEdge] {
  let edges : Array[GraphEdge] = []
  for value in values {
    match bundle_reference_key(value) {
      None => ()
      Some(from) =>
        for reference in query_resource_references(value) {
          edges.push({ from, to: reference, reference })
        }
    }
  }
  edges
}

///|
pub fn reference_resolution_summary(values : Array[Json]) -> String {
  let mut total = 0
  let mut unresolved = 0
  for value in values {
    let results = resolve_references(value, values)
    total += results.length()
    unresolved += results.count_if(fn(item) { !item.resolved })
  }
  "references=\{total} unresolved=\{unresolved}"
}

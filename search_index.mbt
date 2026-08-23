///|
pub(all) struct SearchHit {
  index : Int
  resource : Json
  score : Int
  matched_fields : Array[String]
} derive(Debug, Eq, ToJson)

///|
fn search_text_fields(value : Json) -> Array[(String, String)] {
  let output : Array[(String, String)] = []
  for
    path in [
      "resourceType", "id", "status", "name[0].text", "code.text", "title", "description.text",
      "subject.reference", "patient.reference",
    ] {
    let text = query_text(value, path, fallback="")
    if text != "" {
      output.push((path, text))
    }
  }
  output
}

///|
fn search_hit(value : Json, index : Int, query : String) -> SearchHit {
  let fields : Array[String] = []
  let lower_query = query.to_lower()
  for _, pair in search_text_fields(value) {
    let path = pair.0
    let text = pair.1
    if text.to_lower().contains(lower_query) {
      fields.push(path)
    }
  }
  { index, resource: value, score: fields.length(), matched_fields: fields }
}

///|
pub fn search_resource(value : Json, query : String) -> Bool {
  json_contains_text(value, query)
}

///|
pub fn search_resources(values : Array[Json], query : String) -> Array[Json] {
  if query == "" {
    values
  } else {
    values.filter(fn(value) { search_resource(value, query) })
  }
}

///|
pub fn search_hits(values : Array[Json], query : String) -> Array[SearchHit] {
  let hits = values.mapi(fn(index, value) { search_hit(value, index, query) })
  hits.filter(fn(hit) { hit.score > 0 })
}

///|
pub fn search_by_id(values : Array[Json], id : String) -> Array[Json] {
  values.filter(fn(value) { field_string(value, "id") == Some(id) })
}

///|
pub fn search_by_type(values : Array[Json], kind : String) -> Array[Json] {
  values.filter(fn(value) { resource_type(value) == Some(kind) })
}

///|
pub fn search_by_status(values : Array[Json], status : String) -> Array[Json] {
  values.filter(fn(value) { resource_status(value) == Some(status) })
}

///|
pub fn search_by_type_and_status(
  values : Array[Json],
  kind : String,
  status : String,
) -> Array[Json] {
  values.filter(fn(value) {
    resource_type(value) == Some(kind) && resource_status(value) == Some(status)
  })
}

///|
pub fn search_by_field(
  values : Array[Json],
  path : String,
  query : String,
) -> Array[Json] {
  values.filter(fn(value) {
    query_strings(value, path).any(fn(text) { text.contains(query) })
  })
}

///|
pub fn search_by_reference(
  values : Array[Json],
  reference : String,
) -> Array[Json] {
  values.filter(fn(value) {
    query_resource_references(value).contains(reference)
  })
}

///|
pub fn resource_matches_all(value : Json, expressions : Array[String]) -> Bool {
  expressions.all(fn(expression) { query_exists(value, expression) })
}

///|
pub fn resource_match_count(value : Json, expressions : Array[String]) -> Int {
  expressions.count_if(fn(expression) { query_exists(value, expression) })
}

///|
pub fn select_resources(
  values : Array[Json],
  expressions : Array[String],
) -> Array[Json] {
  values.filter(fn(value) { resource_matches_all(value, expressions) })
}

///|
pub fn find_first_resource(
  values : Array[Json],
  kind : String,
  id : String,
) -> Json? {
  search_by_id(search_by_type(values, kind), id).get(0)
}

///|
pub fn search_summary(values : Array[Json], query : String) -> String {
  let hits = search_hits(values, query)
  let counts = group_resources_by_type(hits.map(fn(hit) { hit.resource }))
  "\{hits.length()} hit(s) across \{counts.length()} resource type(s)"
}

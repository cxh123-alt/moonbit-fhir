///|
priv struct QueryToken {
  field : String
  selector : QuerySelector
}

///|
priv enum QuerySelector {
  NoSelector
  Wildcard
  Index(Int)
  Invalid
}

///|
fn query_token(text : String) -> QueryToken {
  match text.find("[") {
    None => { field: text, selector: NoSelector }
    Some(open) =>
      if !text.has_suffix("]") || open == 0 {
        { field: "", selector: Invalid }
      } else {
        let field = text.unsafe_substring(start=0, end=open)
        let selector_text = text.unsafe_substring(
          start=open + 1,
          end=text.length() - 1,
        )
        let selector = if selector_text == "*" {
          Wildcard
        } else {
          match parse_index(selector_text) {
            Some(index) => Index(index)
            None => Invalid
          }
        }
        { field, selector }
      }
  }
}

///|
fn query_children(value : Json, token : QueryToken) -> Array[Json] {
  let selected : Array[Json] = []
  let base = if token.field == "" {
    Some(value)
  } else {
    object_get(value, token.field)
  }
  match base {
    None => ()
    Some(value) =>
      match token.selector {
        NoSelector => selected.push(value)
        Wildcard =>
          match value {
            Array(items) => selected.append(items[:])
            _ => ()
          }
        Index(index) =>
          match value {
            Array(items) =>
              match items.get(index) {
                Some(item) => selected.push(item)
                None => ()
              }
            _ => ()
          }
        Invalid => ()
      }
  }
  selected
}

///|
fn query_walk(
  values : Array[Json],
  parts : Array[String],
  index : Int,
) -> Array[Json] {
  if index >= parts.length() {
    values
  } else {
    let next : Array[Json] = []
    let token = query_token(parts[index])
    if token.selector is Invalid {
      []
    } else {
      for value in values {
        next.append(query_children(value, token)[:])
      }
      query_walk(next, parts, index + 1)
    }
  }
}

///|
pub fn query_values(value : Json, expression : String) -> Array[Json] {
  if expression == "" {
    [value]
  } else if expression.has_prefix(".") || expression.has_suffix(".") {
    []
  } else {
    let parts = expression
      .split(".")
      .map(fn(part) { part.to_owned() })
      .to_array()
    query_walk([value], parts, 0)
  }
}

///|
pub fn query_strings(value : Json, expression : String) -> Array[String] {
  query_values(value, expression).filter_map(fn(value) { as_scalar_text(value) })
}

///|
pub fn query_first(value : Json, expression : String) -> Json? {
  match query_values(value, expression).get(0) {
    Some(item) => Some(item)
    None => None
  }
}

///|
pub fn query_exists(value : Json, expression : String) -> Bool {
  query_values(value, expression).length() > 0
}

///|
pub fn query_count(value : Json, expression : String) -> Int {
  query_values(value, expression).length()
}

///|
pub fn query_text(
  value : Json,
  expression : String,
  fallback? : String = "",
) -> String {
  match query_strings(value, expression).get(0) {
    Some(text) => text
    None => fallback
  }
}

///|
pub fn query_paths(value : Json, expression : String) -> Array[(String, Json)] {
  let output : Array[(String, Json)] = []
  let values = query_values(value, expression)
  for index, item in values {
    let _ = index
    output.push(("\{expression}[\{index}]", item))
  }
  output
}

///|
pub fn query_all_strings(
  value : Json,
  expressions : Array[String],
) -> Map[String, Array[String]] {
  let output : Map[String, Array[String]] = Map([])
  for expression in expressions {
    output[expression] = query_strings(value, expression)
  }
  output
}

///|
pub fn query_resource_references(value : Json) -> Array[String] {
  query_strings(value, "subject.reference")
  .add(query_strings(value, "patient.reference"))
  .add(query_strings(value, "performer[*].reference"))
  .add(query_strings(value, "basedOn[*].reference"))
  .add(query_strings(value, "partOf.reference"))
}

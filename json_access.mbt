///|
fn object_get(value : Json, key : String) -> Json? {
  match value {
    Object(fields) => fields.get(key)
    _ => None
  }
}

///|
fn array_items(value : Json) -> Array[Json]? {
  match value {
    Array(items) => Some(items)
    _ => None
  }
}

///|
fn as_string(value : Json) -> String? {
  match value {
    String(s) => Some(s)
    _ => None
  }
}

///|
fn as_scalar_text(value : Json) -> String? {
  match value {
    String(s) => Some(s)
    Number(_, repr=Some(s)) => Some(s)
    Number(n, repr=None) => Some("\{n}")
    True => Some("true")
    False => Some("false")
    Null => Some("null")
    _ => None
  }
}

///|
fn field_string(value : Json, key : String) -> String? {
  match object_get(value, key) {
    Some(v) => as_string(v)
    None => None
  }
}

///|
fn field_array(value : Json, key : String) -> Array[Json]? {
  match object_get(value, key) {
    Some(v) => array_items(v)
    None => None
  }
}

///|
fn first_string(values : Array[Json]) -> String? {
  for found = None, i = 0; i < values.length(); {
    match found {
      Some(_) => continue found, values.length()
      None =>
        match as_string(values[i]) {
          Some(s) => continue Some(s), values.length()
          None => continue None, i + 1
        }
    }
  } nobreak {
    found
  }
}

///|
fn first_coding_code(concept : Json) -> String? {
  match field_array(concept, "coding") {
    Some(codings) =>
      for found = None, i = 0; i < codings.length(); {
        match found {
          Some(_) => continue found, codings.length()
          None =>
            match field_string(codings[i], "code") {
              Some(code) => continue Some(code), codings.length()
              None => continue None, i + 1
            }
        }
      } nobreak {
        found
      }
    None => None
  }
}

///|
fn codeable_text(value : Json) -> String? {
  match field_string(value, "text") {
    Some(text) => Some(text)
    None => first_coding_code(value)
  }
}

///|
fn reference_text(value : Json) -> String? {
  match field_string(value, "reference") {
    Some(reference) => Some(reference)
    None => field_string(value, "display")
  }
}

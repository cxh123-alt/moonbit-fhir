///|
pub fn json_key_count(value : Json) -> Int {
  match value {
    Object(fields) => fields.length()
    _ => 0
  }
}

///|
pub fn json_object_keys(value : Json) -> Array[String] {
  match value {
    Object(fields) => fields.keys().to_array()
    _ => []
  }
}

///|
pub fn json_array_length(value : Json) -> Int {
  match value {
    Array(items) => items.length()
    _ => 0
  }
}

///|
pub fn json_has_key(value : Json, key : String) -> Bool {
  match value {
    Object(fields) => fields.contains(key)
    _ => false
  }
}

///|
pub fn json_contains_text(value : Json, text : String) -> Bool {
  match value {
    String(value) => value.contains(text)
    Object(fields) => {
      let mut found = false
      for key, child in fields {
        if key.contains(text) || json_contains_text(child, text) {
          found = true
        }
      }
      found
    }
    Array(items) => items.any(fn(child) { json_contains_text(child, text) })
    _ => false
  }
}

///|
fn json_projection_value(value : Json, fields : Array[String]) -> Json {
  match value {
    Object(values) => {
      let output : Map[String, Json] = Map([])
      for field in fields {
        match values.get(field) {
          Some(child) => output[field] = child
          None => ()
        }
      }
      Json::object(output)
    }
    _ => value
  }
}

///|
pub fn resource_projection(value : Json, fields : Array[String]) -> Json {
  json_projection_value(value, fields)
}

///|
pub fn json_without(value : Json, fields : Array[String]) -> Json {
  match value {
    Object(values) => {
      let output : Map[String, Json] = Map([])
      for key, child in values {
        if !fields.contains(key) {
          output[key] = json_without(child, fields)
        }
      }
      Json::object(output)
    }
    Array(items) =>
      Json::array(items.map(fn(child) { json_without(child, fields) }))
    _ => value
  }
}

///|
pub fn json_merge(left : Json, right : Json) -> Json {
  match left {
    Object(left_fields) =>
      match right {
        Object(right_fields) => {
          let output : Map[String, Json] = Map([])
          for key, child in left_fields {
            output[key] = child
          }
          for key, child in right_fields {
            match output.get(key) {
              Some(existing) => output[key] = json_merge(existing, child)
              None => output[key] = child
            }
          }
          Json::object(output)
        }
        right_value => right_value
      }
    _ => right
  }
}

///|
fn json_leaf_paths_at(
  value : Json,
  prefix : String,
  output : Array[String],
) -> Unit {
  match value {
    Object(fields) =>
      if fields.length() == 0 {
        output.push(prefix)
      } else {
        for key, child in fields {
          let next = if prefix == "" { key } else { "\{prefix}.\{key}" }
          json_leaf_paths_at(child, next, output)
        }
      }
    Array(items) =>
      if items.length() == 0 {
        output.push(prefix)
      } else {
        for index, child in items {
          json_leaf_paths_at(child, "\{prefix}[\{index}]", output)
        }
      }
    _ => output.push(prefix)
  }
}

///|
pub fn json_leaf_paths(value : Json) -> Array[String] {
  let output : Array[String] = []
  json_leaf_paths_at(value, "", output)
  output
}

///|
pub fn json_flatten_scalars(value : Json) -> Array[String] {
  match value {
    Object(fields) => {
      let output : Array[String] = []
      for _, child in fields {
        output.append(json_flatten_scalars(child)[:])
      }
      output
    }
    Array(items) => {
      let output : Array[String] = []
      for child in items {
        output.append(json_flatten_scalars(child)[:])
      }
      output
    }
    _ =>
      match as_scalar_text(value) {
        Some(text) => [text]
        None => []
      }
  }
}

///|
pub fn json_equal_canonical(left : Json, right : Json) -> Bool {
  Json::equal(canonical_resource(left), canonical_resource(right))
}

///|
pub fn json_depth_at_least(value : Json, minimum : Int) -> Bool {
  json_depth(value) >= minimum
}

///|
pub fn resource_field_names(value : Json) -> Array[String] {
  json_object_keys(value)
}

///|
pub fn resource_has_field(value : Json, field : String) -> Bool {
  json_has_key(value, field)
}

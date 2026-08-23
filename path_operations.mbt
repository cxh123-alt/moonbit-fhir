///|
pub fn path_exists_all(value : Json, paths : Array[String]) -> Bool {
  paths.all(fn(path) { query_exists(value, path) })
}

///|
pub fn path_exists_any(value : Json, paths : Array[String]) -> Bool {
  paths.any(fn(path) { query_exists(value, path) })
}

///|
pub fn path_equals(value : Json, path : String, expected : String) -> Bool {
  query_strings(value, path).any(fn(actual) { actual == expected })
}

///|
pub fn path_contains(value : Json, path : String, expected : String) -> Bool {
  query_strings(value, path).any(fn(actual) { actual.contains(expected) })
}

///|
pub fn distinct_path_strings(value : Json, path : String) -> Array[String] {
  let seen : Map[String, Bool] = Map([])
  let output : Array[String] = []
  for item in query_strings(value, path) {
    if !seen.contains(item) {
      seen[item] = true
      output.push(item)
    }
  }
  output
}

///|
pub fn path_numeric_values(value : Json, path : String) -> Array[Double] {
  query_values(value, path).filter_map(number_value)
}

///|
pub fn path_numeric_sum(value : Json, path : String) -> Double {
  path_numeric_values(value, path).fold(init=0.0, fn(total, item) {
    total + item
  })
}

///|
pub fn path_numeric_min(value : Json, path : String) -> Double? {
  let values = path_numeric_values(value, path)
  if values.length() == 0 {
    None
  } else {
    let mut minimum = values[0]
    for item in values {
      if item < minimum {
        minimum = item
      }
    }
    Some(minimum)
  }
}

///|
pub fn path_numeric_max(value : Json, path : String) -> Double? {
  let values = path_numeric_values(value, path)
  if values.length() == 0 {
    None
  } else {
    let mut maximum = values[0]
    for item in values {
      if item > maximum {
        maximum = item
      }
    }
    Some(maximum)
  }
}

///|
pub fn path_count_at_least(value : Json, path : String, minimum : Int) -> Bool {
  query_count(value, path) >= minimum
}

///|
pub fn path_string_join(
  value : Json,
  path : String,
  separator : String,
) -> String {
  query_strings(value, path).join(separator)
}

///|
pub fn path_select_objects(value : Json, path : String) -> Array[Json] {
  query_values(value, path).filter(fn(item) { item is Object(_) })
}

///|
pub fn path_select_arrays(value : Json, path : String) -> Array[Json] {
  query_values(value, path).filter(fn(item) { item is Array(_) })
}

///|
pub fn path_resource_types(value : Json, path : String) -> Array[String] {
  query_values(value, path).filter_map(resource_type)
}

///|
pub fn path_reference_targets(value : Json, path : String) -> Array[String] {
  query_strings(value, "\{path}[*].reference").filter_map(fn(reference) {
    reference_resource_type(reference)
  })
}

///|
pub fn path_is_singleton(value : Json, path : String) -> Bool {
  query_count(value, path) == 1
}

///|
pub fn path_is_empty(value : Json, path : String) -> Bool {
  query_count(value, path) == 0
}

///|
pub fn path_summary(value : Json, path : String) -> String {
  let values = query_strings(value, path)
  let joined = values.join(", ")
  if values.length() == 0 {
    "\{path}: empty"
  } else {
    "\{path}: \{joined}"
  }
}

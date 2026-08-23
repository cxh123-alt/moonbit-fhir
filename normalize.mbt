///|
fn canonical_value(value : Json) -> Json {
  match value {
    Object(fields) => {
      let pairs = fields.to_array()
      pairs.sort_by(fn(left, right) { String::compare(left.0, right.0) })
      let ordered : Map[String, Json] = Map([])
      for _, pair in pairs {
        let key = pair.0
        let child = pair.1
        ordered[key] = canonical_value(child)
      }
      Json::object(ordered)
    }
    Array(items) => Json::array(items.map(canonical_value))
    _ => value
  }
}

///|
pub fn canonical_json(value : Json, indent? : Int = 0) -> String {
  canonical_value(value).stringify(indent~)
}

///|
pub fn canonical_resource(value : Json) -> Json {
  canonical_value(value)
}

///|
fn redact_value(value : Json, fields : Array[String]) -> Json {
  match value {
    Object(values) => {
      let output : Map[String, Json] = Map([])
      for key, child in values {
        if !fields.contains(key) {
          output[key] = redact_value(child, fields)
        }
      }
      Json::object(output)
    }
    Array(items) =>
      Json::array(items.map(fn(item) { redact_value(item, fields) }))
    _ => value
  }
}

///|
pub fn redact_fields(value : Json, fields : Array[String]) -> Json {
  redact_value(value, fields)
}

///|
pub fn redact_standard_sensitive_fields(value : Json) -> Json {
  redact_fields(value, ["telecom", "address", "photo", "identifier"])
}

///|
pub fn csv_escape(text : String) -> String {
  if text.contains(",") ||
    text.contains("\"") ||
    text.contains("\n") ||
    text.contains("\r") {
    let escaped = text.replace_all(old="\"", new="\"\"")
    "\"\{escaped}\""
  } else {
    text
  }
}

///|
pub fn csv_row(values : Array[String]) -> String {
  values.map(csv_escape).join(",")
}

///|
pub fn observation_csv_row_safe(value : Json) -> String {
  let summary = observation_summary(value)
  csv_row([
    summary.id.unwrap_or(""),
    summary.status.unwrap_or(""),
    summary.code_text.unwrap_or(""),
    summary.subject.unwrap_or(""),
    summary.value.unwrap_or(""),
    summary.issued.unwrap_or(""),
  ])
}

///|
pub fn json_size(value : Json) -> Int {
  canonical_json(value).length()
}

///|
pub fn json_depth(value : Json) -> Int {
  match value {
    Object(fields) => {
      let mut max_depth = 0
      for _, child in fields {
        let depth = json_depth(child)
        if depth > max_depth {
          max_depth = depth
        }
      }
      max_depth + 1
    }
    Array(items) => {
      let mut max_depth = 0
      for child in items {
        let depth = json_depth(child)
        if depth > max_depth {
          max_depth = depth
        }
      }
      max_depth + 1
    }
    _ => 1
  }
}

///|
pub fn json_scalar_count(value : Json) -> Int {
  match value {
    Object(fields) => {
      let mut count = 0
      for _, child in fields {
        count += json_scalar_count(child)
      }
      count
    }
    Array(items) => {
      let mut count = 0
      for child in items {
        count += json_scalar_count(child)
      }
      count
    }
    _ => 1
  }
}

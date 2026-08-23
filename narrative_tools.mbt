///|
fn collapse_spaces(value : String) -> String {
  let output = StringBuilder()
  let mut previous_space = false
  for char in value {
    if char == ' ' || char == '\n' || char == '\r' || char == '\t' {
      if !previous_space {
        output.write_char(' ')
      }
      previous_space = true
    } else {
      output.write_char(char)
      previous_space = false
    }
  }
  output.to_string().trim().to_owned()
}

///|
pub fn normalize_narrative(value : String) -> String {
  collapse_spaces(value)
}

///|
pub fn narrative_text(value : Json) -> String? {
  match query_text(value, "text.div", fallback="") {
    "" =>
      match query_text(value, "text.status", fallback="") {
        "" => None
        status => Some(status)
      }
    div => Some(div)
  }
}

///|
pub fn resource_narrative(value : Json) -> String? {
  narrative_text(value).map(normalize_narrative)
}

///|
pub fn resource_has_narrative(value : Json) -> Bool {
  resource_narrative(value) is Some(_)
}

///|
pub fn narrative_word_count(value : String) -> Int {
  normalize_narrative(value)
  .split(" ")
  .map(fn(part) { part.to_owned() })
  .filter(fn(part) { part != "" })
  .to_array()
  .length()
}

///|
pub fn narrative_character_count(value : String) -> Int {
  normalize_narrative(value).length()
}

///|
pub fn narrative_preview(value : String, limit : Int) -> String {
  let normalized = normalize_narrative(value)
  if limit <= 0 || normalized.length() <= limit {
    normalized
  } else {
    normalized[0:limit].to_owned() + "..."
  }
}

///|
pub fn strip_html_tags(value : String) -> String {
  let output = StringBuilder()
  let mut inside = false
  for char in value {
    if char == '<' {
      inside = true
    } else if char == '>' {
      inside = false
    } else if !inside {
      output.write_char(char)
    }
  }
  output.to_string()
}

///|
pub fn narrative_plain_text(value : String) -> String {
  normalize_narrative(strip_html_tags(value))
}

///|
pub fn narrative_contains(value : String, query : String) -> Bool {
  narrative_plain_text(value).to_lower().contains(query.to_lower())
}

///|
pub fn resources_with_narrative(values : Array[Json]) -> Array[Json] {
  values.filter(fn(value) { resource_has_narrative(value) })
}

///|
pub fn narrative_coverage(values : Array[Json]) -> Int {
  if values.length() == 0 {
    100
  } else {
    resources_with_narrative(values).length() * 100 / values.length()
  }
}

///|
fn decode_pointer_token(token : String) -> String {
  let builder = StringBuilder()
  for i = 0; i < token.length(); {
    if token[i] == '~' && i + 1 < token.length() {
      if token[i + 1] == '0' {
        builder.write_string("~")
        continue i + 2
      } else if token[i + 1] == '1' {
        builder.write_string("/")
        continue i + 2
      }
    }
    builder.write_string(token.unsafe_substring(start=i, end=i + 1))
    continue i + 1
  } nobreak {
    builder.to_string()
  }
}

///|
fn parse_index(token : String) -> Int? {
  if token.length() == 0 {
    None
  } else {
    for value = 0, i = 0; i < token.length(); {
      let ch = token[i]
      if ch < '0' || ch > '9' {
        continue -1, token.length()
      } else {
        continue value * 10 + (ch.to_int() - ('0' : UInt16).to_int()), i + 1
      }
    } nobreak {
      if value < 0 {
        None
      } else {
        Some(value)
      }
    }
  }
}

///|
pub fn json_pointer(value : Json, pointer : String) -> Json? {
  if pointer == "" {
    Some(value)
  } else if !pointer.has_prefix("/") {
    None
  } else {
    let parts = pointer[1:]
      .split("/")
      .map(fn(part) { part.to_owned() })
      .to_array()
    for current = Some(value), i = 0; i < parts.length(); {
      match current {
        None => continue None, parts.length()
        Some(node) => {
          let token = decode_pointer_token(parts[i])
          match node {
            Object(fields) => continue fields.get(token), i + 1
            Array(items) =>
              match parse_index(token) {
                Some(index) =>
                  if index >= 0 && index < items.length() {
                    continue Some(items[index]), i + 1
                  } else {
                    continue None, parts.length()
                  }
                None => continue None, parts.length()
              }
            _ => continue None, parts.length()
          }
        }
      }
    } nobreak {
      current
    }
  }
}

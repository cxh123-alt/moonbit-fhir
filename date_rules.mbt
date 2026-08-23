///|
pub(all) enum DatePrecision {
  Year
  Month
  Day
  DateTime
  Unknown
} derive(Debug, Eq, ToJson)

///|
fn date_digit(value : String, index : Int) -> Int? {
  match value.get(index) {
    None => None
    Some(ch) =>
      if ch >= ('0' : UInt16) && ch <= ('9' : UInt16) {
        Some(ch.to_int() - ('0' : UInt16).to_int())
      } else {
        None
      }
  }
}

///|
fn date_number(value : String, start : Int, end : Int) -> Int? {
  if start >= end || start < 0 || end > value.length() {
    None
  } else {
    for total = 0, index = start; index < end; {
      match date_digit(value, index) {
        None => continue -1, end
        Some(digit) => continue total * 10 + digit, index + 1
      }
    } nobreak {
      if total < 0 {
        None
      } else {
        Some(total)
      }
    }
  }
}

///|
fn date_leap_year(year : Int) -> Bool {
  year % 400 == 0 || (year % 4 == 0 && year % 100 != 0)
}

///|
fn date_days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 => if date_leap_year(year) { 29 } else { 28 }
    _ => 0
  }
}

///|
pub fn is_valid_fhir_date(value : String) -> Bool {
  if value.length() == 4 {
    date_number(value, 0, 4) is Some(_)
  } else if value.length() == 7 {
    value[4] == '-' &&
    date_number(value, 0, 4) is Some(_) &&
    date_number(value, 5, 7) is Some(month) &&
    month >= 1 &&
    month <= 12
  } else if value.length() == 10 {
    value[4] == '-' &&
    value[7] == '-' &&
    date_number(value, 0, 4) is Some(year) &&
    date_number(value, 5, 7) is Some(month) &&
    date_number(value, 8, 10) is Some(day) &&
    month >= 1 &&
    month <= 12 &&
    day >= 1 &&
    day <= date_days_in_month(year, month)
  } else {
    false
  }
}

///|
fn is_valid_timezone(value : String) -> Bool {
  if value == "Z" {
    true
  } else if value.length() == 6 &&
    (value[0] == '+' || value[0] == '-') &&
    value[3] == ':' {
    date_number(value, 1, 3) is Some(hour) &&
    date_number(value, 4, 6) is Some(minute) &&
    hour <= 23 &&
    minute <= 59
  } else {
    false
  }
}

///|
fn is_valid_time(value : String) -> Bool {
  if value.length() < 8 {
    false
  } else {
    let basic = match date_number(value, 0, 2) {
      None => false
      Some(hour) =>
        match date_number(value, 3, 5) {
          None => false
          Some(minute) =>
            match date_number(value, 6, 8) {
              None => false
              Some(second) =>
                value[2] == ':' &&
                value[5] == ':' &&
                hour <= 23 &&
                minute <= 59 &&
                second <= 59
            }
        }
    }
    let suffix = if value.length() > 8 { value[8:].to_owned() } else { "" }
    basic &&
    (if suffix == "" || suffix == "Z" {
      true
    } else if suffix.length() == 6 && (suffix[0] == '+' || suffix[0] == '-') {
      is_valid_timezone(suffix)
    } else if suffix[0] == '.' {
      match suffix.find("Z") {
        Some(index) => index > 1 && is_valid_timezone(suffix[index:].to_owned())
        None =>
          match suffix.find("+") {
            Some(index) =>
              index > 1 && is_valid_timezone(suffix[index:].to_owned())
            None =>
              match suffix.find("-") {
                Some(index) =>
                  index > 1 && is_valid_timezone(suffix[index:].to_owned())
                None => false
              }
          }
      }
    } else {
      false
    })
  }
}

///|
pub fn is_valid_fhir_datetime(value : String) -> Bool {
  if is_valid_fhir_date(value) {
    true
  } else {
    match value.find("T") {
      None => false
      Some(index) =>
        is_valid_fhir_date(value[0:index].to_owned()) &&
        is_valid_time(value[index + 1:].to_owned())
    }
  }
}

///|
pub fn date_precision(value : String) -> DatePrecision {
  if value.contains("T") {
    DateTime
  } else {
    match value.length() {
      4 => Year
      7 => Month
      10 => Day
      _ => Unknown
    }
  }
}

///|
pub fn date_precision_name(value : String) -> String {
  match date_precision(value) {
    Year => "year"
    Month => "month"
    Day => "day"
    DateTime => "datetime"
    Unknown => "unknown"
  }
}

///|
fn date_order_key(value : String) -> String {
  match date_precision(value) {
    Year => value + "-01-01"
    Month => value + "-01"
    Day | DateTime => value
    Unknown => ""
  }
}

///|
pub fn compare_fhir_dates(left : String, right : String) -> Int? {
  if !is_valid_fhir_datetime(left) || !is_valid_fhir_datetime(right) {
    None
  } else {
    Some(String::compare(date_order_key(left), date_order_key(right)))
  }
}

///|
pub fn period_contains(start : String, end : String, point : String) -> Bool {
  let lower = start == "" || compare_fhir_dates(start, point).unwrap_or(1) <= 0
  let upper = end == "" || compare_fhir_dates(point, end).unwrap_or(1) <= 0
  lower && upper
}

///|
pub fn period_overlap(
  left_start : String,
  left_end : String,
  right_start : String,
  right_end : String,
) -> Bool {
  let left_before_right = left_end == "" ||
    right_start == "" ||
    period_contains(left_start, left_end, right_start)
  let right_before_left = right_end == "" ||
    left_start == "" ||
    period_contains(right_start, right_end, left_start)
  left_before_right || right_before_left
}

///|
pub fn period_is_valid(start : String, end : String) -> Bool {
  (start == "" || is_valid_fhir_datetime(start)) &&
  (end == "" || is_valid_fhir_datetime(end)) &&
  (start == "" || end == "" || compare_fhir_dates(start, end).unwrap_or(1) <= 0)
}

///|
pub fn date_year(value : String) -> Int? {
  if is_valid_fhir_datetime(value) {
    date_number(value, 0, 4)
  } else {
    None
  }
}

///|
pub fn date_month(value : String) -> Int? {
  if is_valid_fhir_datetime(value) && value.length() >= 7 {
    date_number(value, 5, 7)
  } else {
    None
  }
}

///|
pub fn date_day(value : String) -> Int? {
  if is_valid_fhir_datetime(value) && value.length() >= 10 {
    date_number(value, 8, 10)
  } else {
    None
  }
}

///|
pub fn date_is_before(left : String, right : String) -> Bool {
  compare_fhir_dates(left, right).unwrap_or(1) < 0
}

///|
pub fn date_is_after(left : String, right : String) -> Bool {
  compare_fhir_dates(left, right).unwrap_or(-1) > 0
}

///|
pub fn date_is_equal(left : String, right : String) -> Bool {
  compare_fhir_dates(left, right).unwrap_or(1) == 0
}

///|
pub fn date_range_label(start : String, end : String) -> String {
  if start == "" && end == "" {
    "unspecified"
  } else if start == "" {
    "until \{end}"
  } else if end == "" {
    "from \{start}"
  } else if start == end {
    start
  } else {
    "\{start} to \{end}"
  }
}

///|
pub fn date_inputs_are_valid(values : Array[String]) -> Bool {
  values.all(is_valid_fhir_datetime)
}

///|
pub fn invalid_date_inputs(values : Array[String]) -> Array[String] {
  values.filter(fn(value) { !is_valid_fhir_datetime(value) })
}

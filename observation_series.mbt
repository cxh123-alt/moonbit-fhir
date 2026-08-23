///|
pub(all) struct ObservationPoint {
  id : String?
  code : String?
  subject : String?
  issued : String?
  value : Double?
  unit : String?
} derive(Debug, Eq, ToJson)

///|
pub fn observation_point(value : Json) -> ObservationPoint {
  {
    id: field_string(value, "id"),
    code: resource_code_text(value),
    subject: resource_subject(value),
    issued: field_string(value, "issued"),
    value: observation_measurement(value),
    unit: Some(observation_measurement_unit(value)),
  }
}

///|
pub fn observation_points(values : Array[Json]) -> Array[ObservationPoint] {
  values.filter_map(fn(value) {
    if resource_type(value) == Some("Observation") {
      Some(observation_point(value))
    } else {
      None
    }
  })
}

///|
pub fn observation_series(
  values : Array[Json],
  code : String,
) -> Array[ObservationPoint] {
  observation_points(values).filter(fn(point) { point.code == Some(code) })
}

///|
pub fn observation_series_values(
  values : Array[ObservationPoint],
) -> Array[Double] {
  values.filter_map(fn(point) { point.value })
}

///|
pub fn observation_series_mean(values : Array[ObservationPoint]) -> Double? {
  let numbers = observation_series_values(values)
  if numbers.length() == 0 {
    None
  } else {
    Some(
      numbers.fold(init=0.0, fn(total, number) { total + number }) /
      numbers.length().to_double(),
    )
  }
}

///|
pub fn observation_series_median(values : Array[ObservationPoint]) -> Double? {
  let numbers = observation_series_values(values)
  if numbers.length() == 0 {
    None
  } else {
    numbers.sort()
    let middle = numbers.length() / 2
    if numbers.length() % 2 == 1 {
      Some(numbers[middle])
    } else {
      Some((numbers[middle - 1] + numbers[middle]) / 2.0)
    }
  }
}

///|
pub fn observation_series_min(values : Array[ObservationPoint]) -> Double? {
  let numbers = observation_series_values(values)
  numbers.sort()
  numbers.get(0)
}

///|
pub fn observation_series_max(values : Array[ObservationPoint]) -> Double? {
  let values = observation_series_values(values)
  values.sort()
  values.last()
}

///|
pub fn observation_series_unit(values : Array[ObservationPoint]) -> String? {
  values.filter_map(fn(point) { point.unit }).get(0)
}

///|
pub fn observation_series_summary(values : Array[ObservationPoint]) -> String {
  let mean = observation_series_mean(values)
    .map(fn(value) { "\{value}" })
    .unwrap_or("none")
  let median = observation_series_median(values)
    .map(fn(value) { "\{value}" })
    .unwrap_or("none")
  "points=\{values.length()} mean=\{mean} median=\{median}"
}

///|
pub fn observation_points_csv(values : Array[ObservationPoint]) -> String {
  let lines = values.map(fn(point) {
    csv_row([
      point.id.unwrap_or(""),
      point.code.unwrap_or(""),
      point.subject.unwrap_or(""),
      point.issued.unwrap_or(""),
      point.value.map(fn(value) { "\{value}" }).unwrap_or(""),
      point.unit.unwrap_or(""),
    ])
  })
  ["id,code,subject,issued,value,unit"].add(lines).join("\n")
}

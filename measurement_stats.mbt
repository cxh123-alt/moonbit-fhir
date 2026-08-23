///|
pub(all) struct MeasurementStats {
  count : Int
  missing : Int
  minimum : Double
  maximum : Double
  sum : Double
  mean : Double
  units : Map[String, Int]
} derive(Debug, Eq, ToJson)

///|
pub fn observation_measurement(value : Json) -> Double? {
  number_at(value, "valueQuantity.value")
}

///|
pub fn observation_measurement_unit(value : Json) -> String {
  quantity_unit(value, "valueQuantity").unwrap_or("")
}

///|
pub fn observation_measurement_stats(values : Array[Json]) -> MeasurementStats {
  let units : Map[String, Int] = Map([])
  let mut count = 0
  let mut missing = 0
  let mut minimum = 0.0
  let mut maximum = 0.0
  let mut sum = 0.0
  for value in values {
    match observation_measurement(value) {
      None => missing += 1
      Some(number) => {
        if count == 0 {
          minimum = number
          maximum = number
        } else {
          if number < minimum {
            minimum = number
          }
          if number > maximum {
            maximum = number
          }
        }
        count += 1
        sum += number
        let unit = observation_measurement_unit(value)
        units[unit] = units.get(unit).unwrap_or(0) + 1
      }
    }
  }
  let mean = if count == 0 { 0.0 } else { sum / count.to_double() }
  { count, missing, minimum, maximum, sum, mean, units }
}

///|
pub fn observation_values(values : Array[Json]) -> Array[Double] {
  values.filter_map(observation_measurement)
}

///|
pub fn observation_measurement_range(values : Array[Json]) -> (Double, Double)? {
  let stats = observation_measurement_stats(values)
  if stats.count == 0 {
    None
  } else {
    Some((stats.minimum, stats.maximum))
  }
}

///|
pub fn observation_units(values : Array[Json]) -> Map[String, Int] {
  observation_measurement_stats(values).units
}

///|
pub fn group_observations_by_code(
  values : Array[Json],
) -> Map[String, Array[Json]] {
  let grouped : Map[String, Array[Json]] = Map([])
  for value in values {
    let code = query_text(
      value,
      "code.coding[0].code",
      fallback=query_text(value, "code.text", fallback=""),
    )
    match grouped.get(code) {
      None => grouped[code] = [value]
      Some(items) => items.push(value)
    }
  }
  grouped
}

///|
pub fn observation_code_count(values : Array[Json], code : String) -> Int {
  group_observations_by_code(values)
  .get(code)
  .map(fn(items) { items.length() })
  .unwrap_or(0)
}

///|
pub fn normalise_quantity(value : Json) -> Json {
  match query_first(value, "valueQuantity") {
    Some(Object(fields)) => {
      let output : Map[String, Json] = Map([])
      match fields.get("value") {
        Some(number) => output["value"] = number
        None => ()
      }
      match fields.get("unit") {
        Some(unit) => output["unit"] = unit
        None => ()
      }
      match fields.get("system") {
        Some(system) => output["system"] = system
        None => ()
      }
      Json::object(output)
    }
    _ => Json::empty_object()
  }
}

///|
pub fn measurement_summary(values : Array[Json]) -> String {
  let stats = observation_measurement_stats(values)
  "count=\{stats.count} missing=\{stats.missing} min=\{stats.minimum} max=\{stats.maximum} mean=\{stats.mean}"
}

///|
pub fn measurement_values_in_range(
  values : Array[Json],
  minimum : Double,
  maximum : Double,
) -> Array[Json] {
  values.filter(fn(value) {
    match observation_measurement(value) {
      Some(number) => number >= minimum && number <= maximum
      None => false
    }
  })
}

///|
pub fn measurement_values_with_unit(
  values : Array[Json],
  unit : String,
) -> Array[Json] {
  values.filter(fn(value) { observation_measurement_unit(value) == unit })
}

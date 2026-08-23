///|
pub(all) struct QueryResult {
  expression : String
  values : Array[Json]
  strings : Array[String]
  count : Int
  empty : Bool
} derive(Debug, Eq, ToJson)

///|
pub fn query_result(value : Json, expression : String) -> QueryResult {
  let values = query_values(value, expression)
  let strings = values.filter_map(as_scalar_text)
  {
    expression,
    values,
    strings,
    count: values.length(),
    empty: values.length() == 0,
  }
}

///|
pub fn query_result_json(result : QueryResult) -> Json {
  Json::array(result.values)
}

///|
pub fn query_result_text(result : QueryResult) -> String {
  result.strings.join("\n")
}

///|
pub fn query_result_csv(result : QueryResult) -> String {
  result.strings.map(csv_escape).join(",")
}

///|
pub fn query_result_summary(result : QueryResult) -> String {
  if result.empty {
    "\{result.expression}: 0 result(s)"
  } else {
    "\{result.expression}: \{result.count} result(s)"
  }
}

///|
pub fn query_many(
  value : Json,
  expressions : Array[String],
) -> Array[QueryResult] {
  expressions.map(fn(expression) { query_result(value, expression) })
}

///|
pub fn query_many_table(
  value : Json,
  expressions : Array[String],
) -> Array[String] {
  query_many(value, expressions).map(fn(result) {
    csv_row([result.expression, "\{result.count}", query_result_text(result)])
  })
}

///|
pub fn query_many_csv(value : Json, expressions : Array[String]) -> String {
  ["expression,count,values"]
  .add(query_many_table(value, expressions))
  .join("\n")
}

///|
pub fn query_result_has_value(result : QueryResult, expected : String) -> Bool {
  result.strings.contains(expected)
}

///|
pub fn query_result_first_text(result : QueryResult) -> String {
  result.strings.get(0).unwrap_or("")
}

///|
pub fn query_result_is_scalar(result : QueryResult) -> Bool {
  result.count == 1 && result.strings.length() == 1
}

///|
pub fn query_resource_summary(
  value : Json,
  expressions : Array[String],
) -> String {
  query_many(value, expressions).map(query_result_summary).join("; ")
}

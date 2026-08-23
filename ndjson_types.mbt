///|
pub(all) struct NdjsonLineError {
  line : Int
  message : String
  raw : String
} derive(Debug, Eq, ToJson)

///|
pub(all) struct NdjsonReport {
  total_lines : Int
  blank_lines : Int
  valid_lines : Int
  invalid_lines : Int
  resources : Array[Json]
  errors : Array[NdjsonLineError]
} derive(Debug, Eq, ToJson)

///|
pub(all) struct NdjsonStatistics {
  resource_count : Int
  valid_count : Int
  invalid_count : Int
  blank_count : Int
  type_counts : Map[String, Int]
  issue_counts : Map[String, Int]
} derive(Debug, Eq, ToJson)

///|
pub fn NdjsonReport::is_clean(self : NdjsonReport) -> Bool {
  self.invalid_lines == 0
}

///|
pub fn NdjsonReport::success_rate(self : NdjsonReport) -> Int {
  if self.total_lines == 0 {
    100
  } else {
    self.valid_lines * 100 / self.total_lines
  }
}

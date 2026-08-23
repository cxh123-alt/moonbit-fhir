///|
pub(all) enum ExportFormat {
  Json
  Ndjson
  Csv
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ExportOptions {
  format : ExportFormat
  include_header : Bool
  canonical : Bool
  redact : Bool
} derive(Debug, Eq, ToJson)

///|
pub fn ExportOptions::json() -> ExportOptions {
  { format: Json, include_header: false, canonical: true, redact: false }
}

///|
pub fn ExportOptions::ndjson() -> ExportOptions {
  { format: Ndjson, include_header: false, canonical: true, redact: false }
}

///|
pub fn ExportOptions::csv() -> ExportOptions {
  { format: Csv, include_header: true, canonical: false, redact: false }
}

///|
pub fn export_options_redacted(options : ExportOptions) -> ExportOptions {
  { ..options, redact: true }
}

///|
fn export_value(value : Json, options : ExportOptions) -> Json {
  let prepared = if options.redact {
    redact_standard_sensitive_fields(value)
  } else {
    value
  }
  if options.canonical {
    canonical_resource(prepared)
  } else {
    prepared
  }
}

///|
pub fn export_resources(
  values : Array[Json],
  options : ExportOptions,
) -> String {
  match options.format {
    Json =>
      Json::array(values.map(fn(value) { export_value(value, options) })).stringify(
        indent=2,
      )
    Ndjson =>
      values
      .map(fn(value) { export_value(value, options).stringify() })
      .join("\n")
    Csv => {
      let lines = summary_display_lines(values)
      if options.include_header {
        [summary_csv_header()].add(lines).join("\n")
      } else {
        lines.join("\n")
      }
    }
  }
}

///|
pub fn export_bundle(bundle : Json, options : ExportOptions) -> String {
  export_resources(bundle_resources(bundle), options)
}

///|
pub fn export_format_name(format : ExportFormat) -> String {
  match format {
    Json => "json"
    Ndjson => "ndjson"
    Csv => "csv"
  }
}

///|
pub fn export_line_count(value : String) -> Int {
  if value == "" {
    0
  } else {
    value.split("\n").to_array().length()
  }
}

///|
pub fn export_round_trip_ndjson(value : String) -> NdjsonReport {
  validate_ndjson(value)
}

///|
pub fn export_is_reproducible(
  values : Array[Json],
  options : ExportOptions,
) -> Bool {
  export_resources(values, options) == export_resources(values, options)
}

///|
pub fn export_summary(values : Array[Json], options : ExportOptions) -> String {
  let rendered = export_resources(values, options)
  "\{export_format_name(options.format)} lines=\{export_line_count(rendered)} bytes=\{rendered.length()}"
}

///|
pub(all) struct ResourceMetrics {
  resource_type : String
  id_present : Bool
  field_count : Int
  scalar_count : Int
  depth : Int
  payload_bytes : Int
  valid : Bool
  quality_score : Int
} derive(Debug, Eq, ToJson)

///|
pub fn resource_metrics(value : Json) -> ResourceMetrics {
  {
    resource_type: resource_type_or(value, ""),
    id_present: resource_has_id(value),
    field_count: json_key_count(value),
    scalar_count: json_scalar_count(value),
    depth: json_depth(value),
    payload_bytes: json_size(value),
    valid: is_valid(value),
    quality_score: quality_score(value),
  }
}

///|
pub fn batch_metrics(values : Array[Json]) -> Array[ResourceMetrics] {
  values.map(resource_metrics)
}

///|
pub fn metrics_payload_bytes(values : Array[Json]) -> Int {
  batch_metrics(values).fold(init=0, fn(total, metrics) {
    total + metrics.payload_bytes
  })
}

///|
pub fn metrics_average_depth(values : Array[Json]) -> Int {
  if values.length() == 0 {
    0
  } else {
    batch_metrics(values).fold(init=0, fn(total, metrics) {
      total + metrics.depth
    }) /
    values.length()
  }
}

///|
pub fn metrics_valid_percent(values : Array[Json]) -> Int {
  batch_quality_score(values)
}

///|
pub fn metrics_max_payload(values : Array[Json]) -> Int {
  batch_metrics(values)
  .map(fn(metrics) { metrics.payload_bytes })
  .fold(init=0, fn(current, size) {
    if size > current {
      size
    } else {
      current
    }
  })
}

///|
pub fn metrics_summary(values : Array[Json]) -> String {
  "records=\{values.length()} bytes=\{metrics_payload_bytes(values)} average_depth=\{metrics_average_depth(values)} valid=\{metrics_valid_percent(values)}% max_payload=\{metrics_max_payload(values)}"
}

///|
pub fn metrics_csv(values : Array[Json]) -> String {
  let rows = batch_metrics(values).map(fn(metrics) {
    csv_row([
      metrics.resource_type,
      if metrics.id_present {
        "true"
      } else {
        "false"
      },
      "\{metrics.field_count}",
      "\{metrics.scalar_count}",
      "\{metrics.depth}",
      "\{metrics.payload_bytes}",
      if metrics.valid {
        "true"
      } else {
        "false"
      },
      "\{metrics.quality_score}",
    ])
  })
  [
    "resourceType,idPresent,fieldCount,scalarCount,depth,payloadBytes,valid,qualityScore",
  ]
  .add(rows)
  .join("\n")
}

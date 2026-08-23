///|
pub(all) struct BulkChunk {
  index : Int
  resources : Array[Json]
  first_id : String?
  last_id : String?
} derive(Debug, Eq, ToJson)

///|
pub fn chunk_resources(
  values : Array[Json],
  chunk_size : Int,
) -> Array[BulkChunk] {
  let output : Array[BulkChunk] = []
  if chunk_size <= 0 {
    output
  } else {
    let mut index = 0
    let mut chunk_index = 0
    while index < values.length() {
      let end = if index + chunk_size > values.length() {
        values.length()
      } else {
        index + chunk_size
      }
      let resources : Array[Json] = []
      for cursor in index..<end {
        resources.push(values[cursor])
      }
      output.push({
        index: chunk_index,
        resources,
        first_id: resources
        .get(0)
        .map(fn(value) { field_string(value, "id").unwrap_or("") }),
        last_id: resources
        .last()
        .map(fn(value) { field_string(value, "id").unwrap_or("") }),
      })
      index = end
      chunk_index += 1
    }
    output
  }
}

///|
pub fn bulk_chunk_count(values : Array[Json], chunk_size : Int) -> Int {
  chunk_resources(values, chunk_size).length()
}

///|
pub fn bulk_chunk_sizes(values : Array[Json], chunk_size : Int) -> Array[Int] {
  chunk_resources(values, chunk_size).map(fn(chunk) { chunk.resources.length() })
}

///|
pub fn bulk_to_json(values : Array[Json]) -> String {
  Json::array(values).stringify()
}

///|
pub fn bulk_to_ndjson(values : Array[Json]) -> String {
  values.map(fn(value) { canonical_json(value) }).join("\n")
}

///|
pub fn bulk_from_ndjson(text : String) -> Array[Json] {
  validate_ndjson(text).resources
}

///|
pub fn bulk_merge_ndjson(parts : Array[String]) -> String {
  parts.filter(fn(part) { part != "" }).join("\n")
}

///|
pub fn bulk_validate_chunks(
  values : Array[Json],
  chunk_size : Int,
) -> Array[BatchQuality] {
  chunk_resources(values, chunk_size).map(fn(chunk) {
    batch_quality(chunk.resources)
  })
}

///|
pub fn bulk_all_chunks_valid(values : Array[Json], chunk_size : Int) -> Bool {
  bulk_validate_chunks(values, chunk_size).all(fn(quality) {
    quality.invalid == 0
  })
}

///|
pub fn bulk_unique_ids(values : Array[Json]) -> Array[String] {
  unique_resource_ids(values)
}

///|
pub fn bulk_partition_by_type(values : Array[Json]) -> Map[String, Array[Json]] {
  group_resources_by_type(values)
}

///|
pub fn bulk_summary(values : Array[Json], chunk_size : Int) -> String {
  let quality = batch_quality(values)
  "records=\{quality.total} valid=\{quality.valid} invalid=\{quality.invalid} chunks=\{bulk_chunk_count(values, chunk_size)}"
}

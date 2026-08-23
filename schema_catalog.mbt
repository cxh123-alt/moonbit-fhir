///|
pub(all) struct SchemaField {
  path : String
  type_name : String
  required : Bool
  minimum_items : Int
  description : String
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ResourceSchema {
  resource_type : String
  version : FhirVersion
  fields : Array[SchemaField]
  summary : String
} derive(Debug, Eq, ToJson)

///|
fn schema_field(
  path : String,
  type_name : String,
  required : Bool,
  minimum_items : Int,
  description : String,
) -> SchemaField {
  { path, type_name, required, minimum_items, description }
}

///|
pub fn schema_for(kind : String, version? : FhirVersion = R4) -> ResourceSchema {
  let fields = match kind {
    "Observation" =>
      [
        schema_field(
          "resourceType", "string", true, 0, "FHIR resource discriminator",
        ),
        schema_field("id", "string", false, 0, "logical resource id"),
        schema_field(
          "status", "string", true, 0, "observation lifecycle status",
        ),
        schema_field("code", "object", true, 0, "observation code"),
        schema_field("subject", "object", false, 0, "subject reference"),
      ]
    "Patient" =>
      [
        schema_field(
          "resourceType", "string", true, 0, "FHIR resource discriminator",
        ),
        schema_field("id", "string", false, 0, "logical resource id"),
        schema_field("name", "array", false, 0, "human names"),
        schema_field("gender", "string", false, 0, "administrative gender"),
        schema_field("birthDate", "string", false, 0, "birth date"),
      ]
    "Bundle" =>
      [
        schema_field(
          "resourceType", "string", true, 0, "FHIR resource discriminator",
        ),
        schema_field("type", "string", true, 0, "bundle type"),
        schema_field("entry", "array", true, 1, "bundle entries"),
        schema_field("id", "string", false, 0, "logical resource id"),
        schema_field("timestamp", "string", false, 0, "bundle timestamp"),
      ]
    "Condition" =>
      [
        schema_field(
          "resourceType", "string", true, 0, "FHIR resource discriminator",
        ),
        schema_field("id", "string", false, 0, "logical resource id"),
        schema_field("clinicalStatus", "object", false, 0, "clinical status"),
        schema_field(
          "verificationStatus", "object", false, 0, "verification status",
        ),
        schema_field("code", "object", true, 0, "condition code"),
      ]
    _ =>
      [
        schema_field(
          "resourceType", "string", true, 0, "FHIR resource discriminator",
        ),
        schema_field("id", "string", false, 0, "logical resource id"),
        schema_field("status", "string", false, 0, "resource status"),
        schema_field("subject", "object", false, 0, "subject reference"),
        schema_field("text", "object", false, 0, "human narrative"),
      ]
  }
  {
    resource_type: kind,
    version,
    fields,
    summary: "lightweight \{kind} schema for integration validation",
  }
}

///|
pub fn schema_field_count(schema : ResourceSchema) -> Int {
  schema.fields.length()
}

///|
pub fn schema_field_names(schema : ResourceSchema) -> Array[String] {
  schema.fields.map(fn(field) { field.path })
}

///|
fn schema_type_matches(value : Json, type_name : String) -> Bool {
  match type_name {
    "object" => value is Object(_)
    "array" => value is Array(_)
    "string" => value is String(_)
    "number" => value is Number(_, ..)
    "boolean" =>
      match value {
        True | False => true
        _ => false
      }
    _ => true
  }
}

///|
pub fn schema_validate(value : Json, schema : ResourceSchema) -> Array[Issue] {
  let issues : Array[Issue] = []
  for field in schema.fields {
    match query_first(value, field.path) {
      None =>
        if field.required {
          issues.push(
            issue(
              "/\{field.path}",
              "required",
              "\{field.path} is required by schema",
            ),
          )
        }
      Some(actual) => {
        if !schema_type_matches(actual, field.type_name) {
          issues.push(
            issue(
              "/\{field.path}",
              "type",
              "\{field.path} must be a \{field.type_name}",
            ),
          )
        }
        match actual {
          Array(items) =>
            if items.length() < field.minimum_items {
              issues.push(
                issue(
                  "/\{field.path}",
                  "empty",
                  "\{field.path} has too few items",
                ),
              )
            }
          _ => ()
        }
      }
    }
  }
  issues
}

///|
pub fn schema_is_valid(value : Json, schema : ResourceSchema) -> Bool {
  schema_validate(value, schema).length() == 0
}

///|
pub fn schema_registry() -> Map[String, ResourceSchema] {
  Map([
    ("Patient", schema_for("Patient")),
    ("Observation", schema_for("Observation")),
    ("Bundle", schema_for("Bundle")),
    ("Condition", schema_for("Condition")),
  ])
}

///|
pub fn schema_for_resource(value : Json) -> ResourceSchema {
  schema_for(resource_type(value).unwrap_or(""))
}

///|
pub fn schema_validate_resource(value : Json) -> Array[Issue] {
  schema_validate(value, schema_for_resource(value))
}

///|
pub fn schema_summary(schema : ResourceSchema) -> String {
  "\{schema.resource_type} \{schema.version.to_string()} fields=\{schema.fields.length()}"
}

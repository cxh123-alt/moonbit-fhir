///|
pub(all) enum Sensitivity {
  Public
  Internal
  Sensitive
  Restricted
} derive(Debug, Eq, ToJson)

///|
pub(all) struct PrivacyPolicy {
  name : String
  sensitive_fields : Array[String]
  restricted_fields : Array[String]
  preserve_resource_type : Bool
  preserve_id : Bool
} derive(Debug, Eq, ToJson)

///|
pub(all) struct PrivacyAudit {
  resource_type : String
  found_sensitive_fields : Array[String]
  removed_fields : Array[String]
  retained_fields : Array[String]
} derive(Debug, Eq, ToJson)

///|
pub fn PrivacyPolicy::standard() -> PrivacyPolicy {
  {
    name: "standard-clinical",
    sensitive_fields: ["telecom", "address", "photo", "identifier", "contact"],
    restricted_fields: [
      "communication", "deceasedDateTime", "multipleBirthInteger",
    ],
    preserve_resource_type: true,
    preserve_id: false,
  }
}

///|
pub fn PrivacyPolicy::strict() -> PrivacyPolicy {
  {
    name: "strict-clinical",
    sensitive_fields: [
      "telecom", "address", "photo", "identifier", "contact", "name",
    ],
    restricted_fields: [
      "communication", "deceasedDateTime", "multipleBirthInteger", "text", "div",
    ],
    preserve_resource_type: true,
    preserve_id: false,
  }
}

///|
pub fn PrivacyPolicy::name(self : PrivacyPolicy) -> String {
  self.name
}

///|
pub fn PrivacyPolicy::field_count(self : PrivacyPolicy) -> Int {
  self.sensitive_fields.length() + self.restricted_fields.length()
}

///|
pub fn classify_field(policy : PrivacyPolicy, field : String) -> Sensitivity {
  if policy.restricted_fields.contains(field) {
    Restricted
  } else if policy.sensitive_fields.contains(field) {
    Sensitive
  } else if field == "resourceType" || field == "id" {
    Internal
  } else {
    Public
  }
}

///|
pub fn policy_allows(policy : PrivacyPolicy, field : String) -> Bool {
  match classify_field(policy, field) {
    Public | Internal => true
    _ => false
  }
}

///|
pub fn sensitive_fields_in_resource(
  value : Json,
  policy : PrivacyPolicy,
) -> Array[String] {
  let output : Array[String] = []
  for field in json_object_keys(value) {
    match classify_field(policy, field) {
      Sensitive | Restricted => output.push(field)
      _ => ()
    }
  }
  output
}

///|
pub fn resource_contains_sensitive_data(
  value : Json,
  policy : PrivacyPolicy,
) -> Bool {
  sensitive_fields_in_resource(value, policy).length() > 0
}

///|
pub fn redact_by_policy(value : Json, policy : PrivacyPolicy) -> Json {
  let fields = policy.sensitive_fields.add(policy.restricted_fields)
  let output = redact_fields(value, fields)
  if policy.preserve_resource_type {
    match resource_type(value) {
      None => output
      Some(kind) =>
        match output {
          Object(values) => {
            values["resourceType"] = Json::string(kind)
            output
          }
          _ => output
        }
    }
  } else {
    output
  }
}

///|
pub fn privacy_audit(value : Json, policy : PrivacyPolicy) -> PrivacyAudit {
  let found = sensitive_fields_in_resource(value, policy)
  let retained : Array[String] = []
  for field in json_object_keys(value) {
    if !found.contains(field) &&
      (policy.preserve_resource_type || field != "resourceType") {
      if policy.preserve_id || field != "id" {
        retained.push(field)
      }
    }
  }
  {
    resource_type: resource_type(value).unwrap_or(""),
    found_sensitive_fields: found,
    removed_fields: found,
    retained_fields: retained,
  }
}

///|
pub fn mask_identifier(value : String, visible? : Int = 2) -> String {
  if value.length() <= visible {
    "*".repeat(value.length())
  } else {
    let prefix = value[0:visible].to_owned()
    prefix + "*".repeat(value.length() - visible)
  }
}

///|
pub fn pseudonymize_identifier(
  value : String,
  scope? : String = "moonbit-fhir",
) -> String {
  let hash = String::hash(scope + ":" + value)
  "anon-\{if hash < 0 { -hash } else { hash }}"
}

///|
pub fn pseudonymize_resource_id(value : Json) -> Json {
  match field_string(value, "id") {
    None => value
    Some(id) =>
      match value {
        Object(fields) => {
          fields["id"] = Json::string(pseudonymize_identifier(id))
          value
        }
        _ => value
      }
  }
}

///|
pub fn privacy_summary(value : Json, policy : PrivacyPolicy) -> String {
  let audit = privacy_audit(value, policy)
  "\{audit.resource_type}: remove=\{audit.removed_fields.length()} retain=\{audit.retained_fields.length()}"
}

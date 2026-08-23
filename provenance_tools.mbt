///|
pub(all) struct ProvenanceActor {
  role : String?
  reference : String?
  display : String?
} derive(Debug, Eq, ToJson)

///|
pub fn provenance_actors(value : Json) -> Array[ProvenanceActor] {
  let output : Array[ProvenanceActor] = []
  for agent in field_array(value, "agent").unwrap_or([]) {
    let actor = object_get(agent, "who").unwrap_or(Json::empty_object())
    output.push({
      role: match object_get(agent, "role") {
        Some(role) => codeable_text(role)
        None => None
      },
      reference: field_string(actor, "reference"),
      display: field_string(actor, "display"),
    })
  }
  output
}

///|
pub fn provenance_targets(value : Json) -> Array[String] {
  query_strings(value, "target[*].reference")
}

///|
pub fn provenance_target_count(value : Json) -> Int {
  provenance_targets(value).length()
}

///|
pub fn provenance_actor_count(value : Json) -> Int {
  provenance_actors(value).length()
}

///|
pub fn provenance_has_actor(value : Json, reference : String) -> Bool {
  provenance_actors(value).any(fn(actor) { actor.reference == Some(reference) })
}

///|
pub fn audit_event_agents(value : Json) -> Array[String] {
  query_strings(value, "agent[*].who.reference")
}

///|
pub fn audit_event_entities(value : Json) -> Array[String] {
  query_strings(value, "entity[*].what.reference")
}

///|
pub fn resource_activity_references(value : Json) -> Array[String] {
  query_resource_references(value)
  .add(provenance_targets(value))
  .add(audit_event_entities(value))
}

///|
pub fn provenance_summary_text(value : Json) -> String {
  let recorded = field_string(value, "recorded").unwrap_or("")
  "actors=\{provenance_actor_count(value)} targets=\{provenance_target_count(value)} recorded=\{recorded}"
}

///|
pub fn provenance_is_complete(value : Json) -> Bool {
  resource_type(value) == Some("Provenance") &&
  provenance_actor_count(value) > 0 &&
  provenance_target_count(value) > 0 &&
  field_string(value, "recorded") is Some(_)
}

///|
pub(all) struct TerminologyCatalog {
  sets : Map[String, ValueSet]
  aliases : Map[String, String]
} derive(Debug, Eq, ToJson)

///|
pub fn TerminologyCatalog::new() -> TerminologyCatalog {
  let catalog : TerminologyCatalog = { sets: Map([]), aliases: Map([]) }
  catalog.add(common_observation_status())
  catalog.add(common_medication_status())
  catalog.add(common_encounter_status())
  catalog.add(common_condition_status())
  catalog
}

///|
pub fn TerminologyCatalog::add(
  self : TerminologyCatalog,
  value_set : ValueSet,
) -> Unit {
  self.sets[value_set.name] = value_set
}

///|
pub fn TerminologyCatalog::add_alias(
  self : TerminologyCatalog,
  alias_name : String,
  name : String,
) -> Unit {
  self.aliases[alias_name] = name
}

///|
pub fn TerminologyCatalog::get(
  self : TerminologyCatalog,
  name : String,
) -> ValueSet? {
  match self.sets.get(name) {
    Some(value_set) => Some(value_set)
    None =>
      match self.aliases.get(name) {
        Some(target) => self.sets.get(target)
        None => None
      }
  }
}

///|
pub fn TerminologyCatalog::contains(
  self : TerminologyCatalog,
  name : String,
  code : String,
) -> Bool {
  self
  .get(name)
  .map(fn(value_set) { value_set.contains(code) })
  .unwrap_or(false)
}

///|
pub fn TerminologyCatalog::names(self : TerminologyCatalog) -> Array[String] {
  self.sets.keys().to_array()
}

///|
pub fn TerminologyCatalog::size(self : TerminologyCatalog) -> Int {
  self.sets.length()
}

///|
pub fn TerminologyCatalog::validate(
  self : TerminologyCatalog,
  name : String,
  path : String,
  system : String?,
  code : String,
) -> TerminologyIssue? {
  match self.get(name) {
    None => Some({ path, system, code, message: "unknown value set \{name}" })
    Some(value_set) => validate_code(path, system, code, value_set)
  }
}

///|
pub fn default_terminology_catalog() -> TerminologyCatalog {
  let catalog = TerminologyCatalog::new()
  catalog.add_alias("observation-status", "Observation.status")
  catalog.add_alias("medication-status", "Medication.status")
  catalog.add_alias("encounter-status", "Encounter.status")
  catalog
}

///|
pub fn terminology_catalog_summary(catalog : TerminologyCatalog) -> String {
  let names = catalog.names().join(", ")
  "\{catalog.size()} value set(s): \{names}"
}

///|
pub fn terminology_status_is_valid(kind : String, status : String) -> Bool {
  let catalog = default_terminology_catalog()
  let name = match kind {
    "Observation" => "observation-status"
    "Medication" => "medication-status"
    "Encounter" => "encounter-status"
    _ => ""
  }
  name != "" && catalog.contains(name, status)
}

///|
pub fn terminology_codes(value_set : ValueSet) -> Array[String] {
  value_set.codes
}

///|
pub fn terminology_missing_codes(
  value_set : ValueSet,
  codes : Array[String],
) -> Array[String] {
  codes.filter(fn(code) { !value_set.contains(code) })
}

///|
pub fn terminology_all_codes_valid(
  value_set : ValueSet,
  codes : Array[String],
) -> Bool {
  terminology_missing_codes(value_set, codes).length() == 0
}

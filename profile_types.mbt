///|
pub(all) enum ProfileRule {
  Required(String)
  Type(String, String)
  Allowed(String, Array[String])
  MinItems(String, Int)
} derive(Debug, Eq, ToJson)

///|
pub(all) struct Profile {
  name : String
  rules : Array[ProfileRule]
} derive(Debug, Eq, ToJson)

///|
pub fn Profile::new(name : String, rules : Array[ProfileRule]) -> Profile {
  { name, rules }
}

///|
pub fn Profile::name(self : Profile) -> String {
  self.name
}

///|
pub fn Profile::rule_count(self : Profile) -> Int {
  self.rules.length()
}

///|
pub fn profile_rule_required(path : String) -> ProfileRule {
  ProfileRule::Required(path)
}

///|
pub fn profile_rule_type(path : String, type_name : String) -> ProfileRule {
  ProfileRule::Type(path, type_name)
}

///|
pub fn profile_rule_allowed(
  path : String,
  values : Array[String],
) -> ProfileRule {
  ProfileRule::Allowed(path, values)
}

///|
pub fn profile_rule_min_items(path : String, count : Int) -> ProfileRule {
  ProfileRule::MinItems(path, count)
}

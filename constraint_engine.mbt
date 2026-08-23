///|
pub(all) enum ConstraintKind {
  Required
  Type
  Date
  Reference
  NonEmpty
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ResourceConstraint {
  path : String
  kind : ConstraintKind
  expected : String
  message : String
} derive(Debug, Eq, ToJson)

///|
pub(all) struct ConstraintSet {
  name : String
  constraints : Array[ResourceConstraint]
} derive(Debug, Eq, ToJson)

///|
pub fn ResourceConstraint::required(
  path : String,
  message? : String = "",
) -> ResourceConstraint {
  { path, kind: Required, expected: "", message }
}

///|
pub fn ResourceConstraint::type_is(
  path : String,
  expected : String,
  message? : String = "",
) -> ResourceConstraint {
  { path, kind: Type, expected, message }
}

///|
pub fn ResourceConstraint::date(
  path : String,
  message? : String = "",
) -> ResourceConstraint {
  { path, kind: Date, expected: "", message }
}

///|
pub fn ResourceConstraint::reference(
  path : String,
  message? : String = "",
) -> ResourceConstraint {
  { path, kind: Reference, expected: "", message }
}

///|
pub fn ResourceConstraint::non_empty(
  path : String,
  message? : String = "",
) -> ResourceConstraint {
  { path, kind: NonEmpty, expected: "", message }
}

///|
pub fn ConstraintSet::new(
  name : String,
  constraints : Array[ResourceConstraint],
) -> ConstraintSet {
  { name, constraints }
}

///|
fn constraint_message(
  constraint : ResourceConstraint,
  fallback : String,
) -> String {
  if constraint.message == "" {
    fallback
  } else {
    constraint.message
  }
}

///|
fn constraint_type_matches(value : Json, expected : String) -> Bool {
  match expected {
    "object" => value is Object(_)
    "array" => value is Array(_)
    "string" => value is String(_)
    "number" => value is Number(_, ..)
    _ => true
  }
}

///|
fn validate_constraint(value : Json, constraint : ResourceConstraint) -> Issue? {
  let path = constraint.path
  match constraint.kind {
    Required =>
      if query_first(value, path) is None {
        Some(
          issue(
            "/\{path}",
            "required",
            constraint_message(constraint, "\{path} is required"),
          ),
        )
      } else {
        None
      }
    Type =>
      match query_first(value, path) {
        None => None
        Some(actual) =>
          if constraint_type_matches(actual, constraint.expected) {
            None
          } else {
            Some(
              issue(
                "/\{path}",
                "type",
                constraint_message(
                  constraint,
                  "\{path} must be \{constraint.expected}",
                ),
              ),
            )
          }
      }
    Date => {
      let text = query_text(value, path, fallback="")
      if text == "" || is_valid_fhir_datetime(text) {
        None
      } else {
        Some(
          issue(
            "/\{path}",
            "value",
            constraint_message(constraint, "\{path} is not a valid date"),
          ),
        )
      }
    }
    Reference => {
      let text = query_text(value, path, fallback="")
      if text == "" || reference_is_well_formed(text) {
        None
      } else {
        Some(
          issue(
            "/\{path}",
            "value",
            constraint_message(constraint, "\{path} is not a valid reference"),
          ),
        )
      }
    }
    NonEmpty =>
      match query_first(value, path) {
        None => None
        Some(actual) =>
          match as_scalar_text(actual) {
            Some(text) =>
              if text == "" {
                Some(
                  issue(
                    "/\{path}",
                    "empty",
                    constraint_message(constraint, "\{path} must not be empty"),
                  ),
                )
              } else {
                None
              }
            None => None
          }
      }
  }
}

///|
pub fn validate_constraints(value : Json, set : ConstraintSet) -> Array[Issue] {
  set.constraints.filter_map(fn(constraint) {
    validate_constraint(value, constraint)
  })
}

///|
pub fn constraints_are_valid(value : Json, set : ConstraintSet) -> Bool {
  validate_constraints(value, set).length() == 0
}

///|
pub fn constraint_count(set : ConstraintSet) -> Int {
  set.constraints.length()
}

///|
pub fn common_observation_constraints() -> ConstraintSet {
  ConstraintSet::new("observation-integration", [
    ResourceConstraint::required("resourceType"),
    ResourceConstraint::required("status"),
    ResourceConstraint::type_is("code", "object"),
    ResourceConstraint::non_empty("status"),
    ResourceConstraint::reference("subject.reference"),
  ])
}

///|
pub fn common_patient_constraints() -> ConstraintSet {
  ConstraintSet::new("patient-integration", [
    ResourceConstraint::required("resourceType"),
    ResourceConstraint::type_is("name", "array"),
    ResourceConstraint::date("birthDate"),
  ])
}

///|
pub fn constraints_summary(set : ConstraintSet) -> String {
  "\{set.name}: \{set.constraints.length()} constraint(s)"
}

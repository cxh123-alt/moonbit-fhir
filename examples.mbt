///|
pub fn example_patient_json() -> String {
  let text =
    #|{
    #|  "resourceType": "Patient",
    #|  "id": "patient-001",
    #|  "name": [{ "given": ["Shanshan"], "family": "Cao" }],
    #|  "gender": "female",
    #|  "birthDate": "1995-05-12"
    #|}
  text
}

///|
pub fn example_observation_json() -> String {
  let text =
    #|{
    #|  "resourceType": "Observation",
    #|  "id": "obs-001",
    #|  "status": "final",
    #|  "code": { "coding": [{ "system": "http://loinc.org", "code": "8480-6" }], "text": "Systolic blood pressure" },
    #|  "subject": { "reference": "Patient/patient-001" },
    #|  "valueQuantity": { "value": 118, "unit": "mmHg" },
    #|  "issued": "2026-08-01T09:30:00+08:00"
    #|}
  text
}

///|
pub fn example_bundle_json() -> String {
  let text =
    #|{
    #|  "resourceType": "Bundle",
    #|  "type": "collection",
    #|  "entry": [
    #|    {
    #|      "fullUrl": "urn:uuid:patient-001",
    #|      "resource": {
    #|        "resourceType": "Patient",
    #|        "id": "patient-001",
    #|        "name": [{ "text": "Shanshan Cao" }]
    #|      }
    #|    },
    #|    {
    #|      "fullUrl": "urn:uuid:obs-001",
    #|      "resource": {
    #|        "resourceType": "Observation",
    #|        "id": "obs-001",
    #|        "status": "final",
    #|        "code": { "text": "Systolic blood pressure" },
    #|        "subject": { "reference": "Patient/patient-001" }
    #|      }
    #|    }
    #|  ]
    #|}
  text
}

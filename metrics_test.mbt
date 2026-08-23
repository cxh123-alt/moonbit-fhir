///|
test "metrics expose payload shape and quality without mutation" {
  let values = [benchmark_patient(1), benchmark_observation(2)]
  let metrics = batch_metrics(values)
  inspect(metrics.length(), content="2")
  inspect(metrics[0].resource_type, content="Patient")
  inspect(metrics[1].valid, content="true")
  inspect(metrics_payload_bytes(values) > 0, content="true")
  inspect(
    metrics_max_payload(values) >= metrics[0].payload_bytes,
    content="true",
  )
}

///|
test "service and operation facades preserve deterministic behavior" {
  let service = FhirService::default()
  let value = benchmark_observation(4)
  inspect(report_is_clean(service.validate(value)), content="true")
  inspect(service.query(value, "code.text").length(), content="1")
  inspect(
    operation_exit_status(operation_outcome(service.validate(value))),
    content="0",
  )
}

///|
test "bulk benchmark scenarios produce reproducible counts" {
  inspect(run_benchmark_validation(8), content="8")
  inspect(run_benchmark_bundle(8), content="8")
  inspect(run_benchmark_ndjson(8), content="8")
  inspect(run_benchmark_search(8), content="8")
}

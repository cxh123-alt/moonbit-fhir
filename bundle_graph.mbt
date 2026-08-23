///|
pub(all) struct GraphEdge {
  from : String
  to : String
  reference : String
} derive(Debug, Eq, ToJson)

///|
pub(all) struct BundleGraph {
  nodes : Int
  edges : Int
  dangling : Int
  node_keys : Array[String]
  edge_list : Array[GraphEdge]
} derive(Debug, Eq, ToJson)

///|
fn bundle_graph_resources(bundle : Json) -> Array[Json] {
  field_array(bundle, "entry")
  .unwrap_or([])
  .filter_map(fn(entry) { object_get(entry, "resource") })
}

///|
pub fn bundle_graph(bundle : Json) -> BundleGraph {
  let resources = bundle_graph_resources(bundle)
  let nodes : Map[String, Json] = Map([])
  let node_keys : Array[String] = []
  for resource in resources {
    match bundle_reference_key(resource) {
      Some(key) =>
        if !nodes.contains(key) {
          nodes[key] = resource
          node_keys.push(key)
        }
      None => ()
    }
  }
  let edge_list : Array[GraphEdge] = []
  let dangling_keys : Map[String, Bool] = Map([])
  for resource in resources {
    match bundle_reference_key(resource) {
      None => ()
      Some(from) =>
        for reference in query_resource_references(resource) {
          if nodes.contains(reference) {
            edge_list.push({ from, to: reference, reference })
          } else {
            dangling_keys[reference] = true
          }
        }
    }
  }
  {
    nodes: node_keys.length(),
    edges: edge_list.length(),
    dangling: dangling_keys.length(),
    node_keys,
    edge_list,
  }
}

///|
pub fn bundle_graph_node_keys(bundle : Json) -> Array[String] {
  bundle_graph(bundle).node_keys
}

///|
pub fn bundle_graph_edges(bundle : Json) -> Array[GraphEdge] {
  bundle_graph(bundle).edge_list
}

///|
pub fn graph_outgoing_edges(
  graph : BundleGraph,
  key : String,
) -> Array[GraphEdge] {
  graph.edge_list.filter(fn(edge) { edge.from == key })
}

///|
pub fn graph_incoming_edges(
  graph : BundleGraph,
  key : String,
) -> Array[GraphEdge] {
  graph.edge_list.filter(fn(edge) { edge.to == key })
}

///|
pub fn bundle_outgoing_references(bundle : Json, key : String) -> Array[String] {
  graph_outgoing_edges(bundle_graph(bundle), key).map(fn(edge) { edge.to })
}

///|
pub fn bundle_incoming_references(bundle : Json, key : String) -> Array[String] {
  graph_incoming_edges(bundle_graph(bundle), key).map(fn(edge) { edge.from })
}

///|
pub fn bundle_dangling_references(bundle : Json) -> Array[String] {
  let stats = analyze_bundle(bundle)
  stats.broken_references
}

///|
pub fn bundle_graph_is_acyclic(bundle : Json) -> Bool {
  let graph = bundle_graph(bundle)
  for edge in graph.edge_list {
    if edge.from == edge.to {
      return false
    }
  }
  true
}

///|
pub fn bundle_graph_summary(bundle : Json) -> String {
  let graph = bundle_graph(bundle)
  "nodes=\{graph.nodes} edges=\{graph.edges} dangling=\{graph.dangling}"
}

///|
pub fn bundle_graph_degree(bundle : Json, key : String) -> (Int, Int) {
  let graph = bundle_graph(bundle)
  (
    graph_outgoing_edges(graph, key).length(),
    graph_incoming_edges(graph, key).length(),
  )
}

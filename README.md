# A Vapor/Swift Elasticsearch Client 🔎
The goal of this project is to provide a comprehensive yet easy to use
Elasticsearch client for Swift. The Vapor server side framework has a large
community around it so integrating with Vapor was a logical first step.  That
said, this library should be very easy to port to another framework (Perfect,
Kitura) or even use by itself for command line utilities and other such
purposes.

Main priorities are to provide index management (field mapping, settings,
tokenizers and analyzers), CRUD support and search results with support for
aggregations. Currently these goals are all being met on some level.

## High Level Features

* Support for creating, updating, requesting and deletion of documents
* High level construction of the Elasticsearch Query DSL
* Execution of constructed search queries
* Execution of many types of aggregations (more are implemented regurally)
* Population of object models when fetching a document and search results (via Swift Codable support)
* Automatic seralization of object models to Elasticsearch (via Swift Codable support)
* Ability to specify the mapping for index creation
* Support for bulk operations

## 📦 Installation

### Package.swift
Add `Elasticsearch` to the Package dependencies:
```swift
dependencies: [
    ...,
    .package(url: "https://github.com/ryangrimm/VaporElasticsearch", .branch("master"))
]
```

as well as to your target (e.g. "App"):

```swift
targets: [
    ...
    .target(
        name: "App",
        dependencies: [... "Elasticsearch" ...]
    ),
    ...
]
```

## Getting started 🚀
Make sure that you've imported `Elasticsearch` everywhere needed:

```swift
import Elasticsearch
```

### Adding the Service
Add the `ElasticsearchDatabase` in your `configure.swift` file:

```swift
let esConfig = ElasticsearchClientConfig(hostname: "localhost", port: 9200)
let es = try ElasticsearchDatabase(config: esConfig)
var databases = DatabasesConfig()
databases.add(database: es, as: .elasticsearch)
services.register(databases)
```

### Simple search example
```swift
struct Document: Codable {

    var id: String
    var title: String
}

func list(_ req: Request) throws -> Future<[Document]> {

	let query = Query(
	    Match(field: "id", value: "42")
	)

	return req.withNewConnection(to: .elasticsearch) { conn in

	    return try conn.search(
		decodeTo: Document.self,
		index: "documents",
		query: SearchContainer(query)
	    )

	}.map(to: [Document].self ) { searchResponse in

	    guard let hits = searchResponse.hits else { return [Document]() }
	    let results = hits.hits.map { $0.source }
	    return results
	}
}
```

### Creating an index (with filter)
```swift

//let client: ElasticsearchClient = ...

let synonymFilter = Analysis.Filter(
	type: "synonym",
	name: "synonym_filter",
	synonyms: ["file, document",
		       "nice, awesome, great"]
)

let analysis = Analysis(
	filter: ["synonym" : synonymFilter]
)

let index = client.createIndex(name: "documents")
	.indexSettings(index: IndexSettings(shards: 5, replicas: 1))
	.analysisSettings(analysis: analysis)
	.property(key: "id", type: MapKeyword())
	.property(key: "title", type: MapText())

try index.create()
```

### Deleting an index
```swift

//let client: ElasticsearchClient = ...
try client.deleteIndex(name: "documents")
```

### Use `bulk`to insert documents
```swift
//let client: ElasticsearchClient = ...

let doc1 = Document(id: 1, title: "hello world")
let doc2 = Document(id: 5, title: "awesome place")

let bulk = client.bulkOperation()
bulk.defaultHeader.index = "documents"

try bulk.create(doc: doc1, id: String(doc1.id))
try bulk.create(doc: doc2, id: String(doc2.id))
// if you want to overwrite documents, use `bulk.index` instead

try bulk.send()
```


## TODO

* Support copy_to

* Implement the KeyedCacheSupporting protocol
* Implement the DatabaseQueryable protocol
* Create a chainable query builder
* Support configuration of tokenizers and analyzers
* Implement the remaining aggregation types
* Implement the decoding for the above aggregation types
* Implement remaining query DSL constructors
These are the remaining query DSL constructors that are left to be
implemented. They are not all of equal value. But pick off those that seem
useful/easy first.

* [Query string](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html)
* [Simple query string](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-simple-query-string-query.html)
* [Terms set](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-terms-set-query.html)
* [Span multi-term query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-span-multi-term-query.html)
* [Span field masking query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-span-field-masking-query.html)
* [Function score query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-function-score-query.html)
* [Boosting query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-boosting-query.html)
* [Constant score query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-constant-score-query.html)
* [Nested query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-nested-query.html)
* [Has child query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-has-child-query.html)
* [Has parent query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-has-parent-query.html)
* [Parent ID query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-parent-id-query.html)
* [Geo shape query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-geo-shape-query.html)
* [Geo bounding box](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-geo-bounding-box-query.html)
* [Geo distance](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-geo-distance-query.html)
* [More like this query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-mlt-query.html)
* [Percolate query](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-percolate-query.html)

* Documentation
* More unit tests
	* Need tests for encoding/decoding round trips of the Map types
* Resolve existing XXX's
* Lots more can be done

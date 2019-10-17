Preston generates provenance logs and history in rdf/nquads format.

This format is supported by Jena's Triple Database (tdb), a fast on-disk triple store. This triple store can be queried using sparql, a query language for rdf.

# getting started
First, install https://jena.apache.org .
On successful installation, the following should rnu

```shell
$ sparql --version
Jena:       VERSION: 3.12.0
Jena:       BUILD_DATE: 2019-05-27T16:07:27+0000
```

# loading data

For small datasets, you can query directly on Preston provenance logs using

```shell
$ preston ls | head > some.nq
$ sparql --data some.nq --query first25.sparql --results tsv
```

where ```first25.sparql``` contains:

```sparql
SELECT ?s ?v ?o WHERE { ?s ?v ?o } LIMIT 25
```

For large datasets, first load the data into a triple store, then query on the data:

```shell 
$ preston ls | bzip2 > huge.nq.bz2
$ tdb2.tdbloader --loc index/ huge.nq.bz2
$ tdb2.tdbquery --loc index --query first25.sparql --results tsv | tail -n+2
```
## rdf/nq in, rdf/nq out

Sparql does not produce valid rdf/nquads, however, you do some tricks to produce triples from a three column result set:

```shell
$ tdb2.tdbquery --loc index --query first25.sparql --results tsv | tail -n+2 | tr '\t' ' ' | sed "s/$/\ ./g" > results.nq
# query the results
$ sparql --data results.nq --query first25.sparql 
```

## performance 

how fast?

### all of Preston GBIF/iDigBio/BioCASe

using: Poelen, Jorrit H. (2019). A biodiversity dataset graph: GBIF, iDigBio, BioCASe (Version 0.0.2) [Data set]. Zenodo. http://doi.org/10.5281/zenodo.3484205 with provenance hash://sha256/d79fb9207329a2813b60713cf0968fda10721d576dcb7a36038faf18027eebc1 
```shell
$ time preston ls | bzip2 > huge.nq.bz2
real	22m30.875s
user	21m24.693s
sys	4m34.099s
$ time tdb2.tdbloader --loc hugeindex huge.nq.bz2

$ time tdb2.tdbquery --loc hugeindex --query count.sparql
```

where ```count.sparql``` is :

```sparql
# count distinct crawls prior to 2019-01-06
SELECT (count(distinct(?crawl)) as ?count)
 WHERE {
   values ?verb { <http://www.w3.org/ns/prov#generatedAtTime> } .
   #?s <http://www.w3.org/ns/prov#generatedAtTime> ?date .
   ?s ?verb ?date .
   # OPTIONAL { ?s <http://www.w3.org/ns/prov#wasGeneratedBy> ?crawl . }
   ?s <http://www.w3.org/ns/prov#wasGeneratedBy> ?crawl . 
   FILTER (?date < "2019-01-06T10:20:13Z"^^<http://www.w3.org/2001/XMLSchema#dateTime>)
}
LIMIT 25
```

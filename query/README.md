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
$ tdbloader --loc index/ huge.nq.bz2
$ tdbquery --loc index --query first25.sparql --results tsv | tail -n+2
```

## capacity queries

### select only idigbio / gbif / biocase

Queries to select generations from individual network can be found at:

 * [select-idigbio.sparql](./select-idigbio.sparql)
 * [select-gbif.sparql](./select-gbif.sparql)
 * [select-biocase.sparql](./select-biocase.sparql)

Note that the "graph" for networks is a little different:

iDigBio - publishers -> publisher uuid -> publisher rss url -> dataset uuid -> dataset url

GBIF - dataset registry page -> dataset uuid -> dataset url

BioCASe - data source registry -> provider url -> dataset url

After building an index, the queries can be executed using something like:

```time tdbquery --loc hugeindex --query select-biocase.sparql --results tsv > somefile.tsv```

Note that the queries are limited to first 25 results, so for full run, please comment that part out.

Example run with timings:

```
$ time tdbquery --loc hugeindex --query select-idigbio.sparql --results tsv | pv -l | gzip > idigbio.tsv.gz
55.1k 0:00:07 [7.83k/s] [             <=>                                                                                     ]

real	0m7.093s
user	0m10.813s
sys	0m0.485s
```


## rdf/nq in, rdf/nq out

Sparql does not produce valid rdf/nquads, however, you do some tricks to produce triples from a three column result set:

```shell
$ tdbquery --loc index --query first25.sparql --results tsv | tail -n+2 | tr '\t' ' ' | sed "s/$/\ ./g" > results.nq
# query the results
$ sparql --data results.nq --query first25.sparql 
```

## performance 

how fast?

Measurements below are done on:
$ sudo lshw -short | grep disk
/0/1/0.0.0       /dev/sda   disk           3TB TOSHIBA DT01ACA3
/0/2/0.0.0       /dev/sdb   disk           3TB TOSHIBA DT01ACA3

(7200 rpm spinning disks) in RAID1 config with 

Intel(R) Core(TM) i7-2600 CPU @ 3.40GHz
and 16GB of DD3 memory.


### all of Preston GBIF/iDigBio/BioCASe

using: Poelen, Jorrit H. (2019). A biodiversity dataset graph: GBIF, iDigBio, BioCASe (Version 0.0.2) [Data set]. Zenodo. http://doi.org/10.5281/zenodo.3484205 with provenance hash://sha256/d79fb9207329a2813b60713cf0968fda10721d576dcb7a36038faf18027eebc1 
```shell
$ time preston ls | bzip2 > huge.nq.bz2
real	22m30.875s
user	21m24.693s
sys	4m34.099s
$ tdbloader --loc hugeindex huge.nq.bz2
04:00:47 INFO  loader               :: -- Start triples data phase
04:00:47 INFO  loader               :: ** Load empty triples table
04:00:47 INFO  loader               :: -- Start quads data phase
04:00:47 INFO  loader               :: ** Load empty quads table
04:00:47 INFO  loader               :: Load: huge.nq.bz2 -- 2019/10/17 04:00:47 CEST
04:00:49 INFO  loader               :: Add: 50,000 triples (Batch: 20,929 / Avg: 20,929)
04:00:51 INFO  loader               :: Add: 100,000 triples (Batch: 28,835 / Avg: 24,254)
...
04:19:12 INFO  loader               :: ** Index SPO->OSP: 11,862,080 slots indexed in 34.32 seconds [Rate: 345,641.75 per second]
04:19:12 INFO  loader               :: -- Finish triples index phase
04:19:12 INFO  loader               :: ** 11,862,080 triples indexed in 74.18 seconds [Rate: 159,902.94 per second]
04:19:12 INFO  loader               :: -- Finish triples load
04:19:12 INFO  loader               :: ** Completed: 33,351,051 triples loaded in 1,105.24 seconds [Rate: 30,175.34 per second]
04:19:12 INFO  loader               :: -- Finish quads load

$ du -d0 -h hugeindex
1.7G	hugeindex
$ time tdbquery --loc hugeindex --query count.sparql
---------
| count |
=========
| 35    |
---------

real	0m21.815s
user	0m25.142s
sys	0m0.743s
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

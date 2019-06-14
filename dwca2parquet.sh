#!/bin/bash
#
# Converts DwC-A in Preston data dir and copies resulting parquets to specified location.
#
# ./dwca2parquet.sh [src dir] [target dir]
#
# example:
#   ./dwca2parquet.sh hdfs:///user/$USER/guoda/data/source=preston-amazon/data hdfs:///user/$USER/guoda/data/source=preston-amazon/dwca
#
# Assumes that spark-shell is available and a Preston dataset exists at hdfs:///user/$USER/guoda/data/source=preston-amazon/data . 
#


[ -f idigbio-spark.jar ] || wget -O idigbio-spark.jar https://github.com/bio-guoda/idigbio-spark/releases/download/0.0.1/iDigBio-LD-assembly-1.5.9.jar 

spark-shell --jars idigbio-spark.jar --conf spark.sql.caseSensitive=true --class bio.guoda.preston.spark.PrestonUtil $@

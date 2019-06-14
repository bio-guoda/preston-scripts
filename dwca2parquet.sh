#!/bin/bash
#
# Converts DwC-A in Preston data dir and copies resulting parquets to specified location.
#
# ./dwca2parquet.sh [src dir] [target dir]
#
# example:
#   ./dwca2parquet.sh file:///user/someuser/preston/data file:///user/some/parquets
#
# Assumes that spark-shell is available.
#

wget -O idigbio-spark.jar https://s3-us-west-2.amazonaws.com/guoda/idigbio-spark/iDigBio-LD-assembly-1.5.9.jar 

spark-shell --jars idigbio-spark.jar --conf spark.sql.caseSensitive=true --class bio.guoda.preston.spark.PrestonUtil $@

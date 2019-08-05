#!/bin/bash
#
# Converts DwC-A in Preston data dir and copies resulting parquets to specified location.
#
# ./dwca2parquet.sh [src dir] [target dir]
#
# example:
#   ./dwca2parquet.sh hdfs:///user/$USER/guoda/data/source=preston-amazon/data hdfs:///user/$USER/guoda/data/source=preston-amazon/dwca
#
# By default, it is assumed that spark-shell is available and a Preston dataset exists at hdfs:///user/$USER/guoda/data/source=preston-amazon/data . 
#

# install prerequisites
source get-libs.sh

input_dir=${1-"hdfs:///user/$USER/guoda/data/source=preston-amazon/data"}
output_dir=${2-"hdfs:///user/$USER/guoda/data/source=preston-amazon/dwca"}

spark-submit \                                                                                                                     
  --master mesos://zk://mesos01:2181,mesos02:2181,mesos03:2181/mesos \ 
  --driver-memory 4G \ 
  --executor-memory 20G \                                                                                               
  --conf spark.sql.caseSensitive=true \ 
  --class bio.guoda.preston.spark.PrestonUtil \
  $IDIGBIO_SPARK_JAR \ 
  "$input_dir" \ 
  "$output_dir"                                                                                                                   

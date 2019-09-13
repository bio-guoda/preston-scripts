#!/bin/bash
#
# Starts a spark-shell in the guoda cluster.
#
# Please use with care and close when done, because it take up all the resources.
#

spark-shell \
  --master mesos://zk://mesos01:2181,mesos02:2181,mesos03:2181/mesos \
  --driver-memory 4G \
  --executor-memory 20G \
  --conf spark.sql.caseSensitive=true

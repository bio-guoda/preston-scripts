#!/bin/bash
#
# Submits spark job provided as argument. Statically configured to use http://guoda.bio infrastructure.
#
# example: 
#   ./submit-job.sh spark-job-preston2parquet.json

curl -X POST http://mesos07.acis.ufl.edu:7077/v1/submissions/create --header "Content-Type:application/json;charset=UTF-8" --data @$1


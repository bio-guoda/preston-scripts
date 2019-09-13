#!/bin/bash
#
# Stops a running framework.
# 
# You can find the framework id by:
# * visiting http://mesos02.acis.ufl.edu:5050/#/frameworks .
# * executing: "curl http://mesos02.acus.ufl.edu:5050/frameworks" and parsing the results.
# ./stop-framework.sh [framework id]

set -xe
curl -X POST http://mesos02:5050/master/teardown -d "frameworkId=$1"

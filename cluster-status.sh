#!/bin/bash
#
# Returns a snapshot of the status of the GUODA cluster. 
#
# See https://github.com/bio-guoda/guoda-services/issues/9 and https://github.com/bio-guoda/guoda-services/issues/19 .
#
# usage:
#
#   ./cluster-status.sh
#

set -xe
curl  http://mesos02:5050/metrics/snapshot | ./jq .

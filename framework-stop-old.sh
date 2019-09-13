#!/bin/bash
#
# Stops frameworks that have been active for more than 14 days. 
#
# See https://github.com/bio-guoda/guoda-services/issues/14 .
#
# usage:
#
#   ./framework-stop-old.sh

set -xe
./framework-list.sh | ./jq --raw-output '. | select(.days_active > 14) | .id' | xargs -L1 ./framework-stop.sh    




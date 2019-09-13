#!/bin/bash
#
# Stops frameworks that have been active for more than 14 days. 
#
# usage:
#
#   ./framework-stop-old.sh

set -xe
./framework-list.sh | ./jq --raw-output '. | select(.days_active > 14) | .id' | xargs ./framework-stop.sh    




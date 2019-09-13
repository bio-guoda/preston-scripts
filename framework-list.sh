#!/bin/bash
#
# Lists active frameworks . Used in combination with stopFramework to remove zombies. 
#
# usage:
#
#   ./framework-list.sh

set -xe
curl --silent http://mesos02:5050/master/frameworks | ./jq -f list-frameworks.jq




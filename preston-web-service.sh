#!/bin/bash
#
# Reads an HTTP request from stdin, runs the preston command indicated in the request URI, and returns the output of that command.
#
# Designed for use with socat,
#
#   socat TCP4-LISTEN:8080,reuseaddr,fork SYSTEM:"./preston-web-service.sh" 
#
# then e.g.
#
#   curl 'localhost:8080/version'
#
#   curl 'localhost:8080/cat/hash://sha256/abc...'
# 

read -r REQUEST_METHOD REQUEST_URI REQUEST_HTTP_VERSION

IFS=/ read -r _ cmd args <<<"$REQUEST_URI"

cat <<HEADER
HTTP/1.1 200 OK
Content-Type: application/octet-stream
HEADER

echo

preston $cmd $args


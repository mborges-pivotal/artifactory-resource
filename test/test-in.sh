#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_get_version_from_artifactory() {

  local local_ip=$(find_docker_host_ip)	
  #local_ip="localhost"

  local src=$(mktemp -d $TMPDIR/in-src.XXXXXX)
  local endpoint="http://${local_ip}:8081/artifactory"
  local regex="carshare-(admin|api|customer)-(?<version>.*).tar.gz"
  local folder="/UrbanActive/Products/Maven/admin"
  local version="1.0.0-rc.0"

  in_without_credentials_with_version $endpoint $regex $folder $version $src 
  
}

it_cant_get_version_from_artifactory() {

  local local_ip=$(find_docker_host_ip) 
  #local_ip="localhost"

  local src=$(mktemp -d $TMPDIR/in-src.XXXXXX)
  local endpoint="http://${local_ip}:8081/artifactory"
  local regex="carshare-(admin|api|customer)-(?<version>.*).tar.gz"
  local folder="/UrbanActive/Products/Maven/admin"
  local version="B.A.D"

  in_without_credentials_with_version $endpoint $regex $folder $version $src
  
}

run it_can_get_version_from_artifactory
# check for exit code > 0
#run it_cant_get_version_from_artifactory


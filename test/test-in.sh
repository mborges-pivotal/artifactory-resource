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

it_can_get_version_from_artifactory_with_credentials() {

  local local_ip=$(find_docker_host_ip) 
  #local_ip="localhost"

  local src=$(mktemp -d $TMPDIR/in-src.XXXXXX)
  local endpoint="http://${local_ip}:8081/artifactory"
  local regex="carshare-(admin|api|customer)-(?<version>.*).tar.gz"
  local folder="/UrbanActive/Products/Maven/admin"
  local version="1.0.0-rc.0"
  local username="admin"
  local password="password"

  in_with_credentials_with_version $endpoint $regex $folder $version $src $username $password
  
}

#run it_can_get_version_from_artifactory
run it_can_get_version_from_artifactory_with_credentials

# check for exit code > 0
#run it_cant_get_version_from_artifactory


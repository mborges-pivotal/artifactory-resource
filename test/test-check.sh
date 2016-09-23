#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_list_releases_from_artifactory() {

  local local_ip=$(find_docker_host_ip)	
  #local_ip="localhost"

  local src=$(mktemp -d $TMPDIR/in-src.XXXXXX)
  local endpoint="http://${local_ip}:8081/artifactory"
  local regex="carshare-(admin|api|customer)-(?<version>.*).tar.gz"
  local folder="/UrbanActive/Products/Maven/admin"

  check_without_credentials_and_version $endpoint $regex $folder $src 
  
}

it_can_list_releases_from_artifactory_with_version() {

  local local_ip=$(find_docker_host_ip) 
  #local_ip="localhost"

  local src=$(mktemp -d $TMPDIR/in-src.XXXXXX)
  local endpoint="http://${local_ip}:8081/artifactory"
  local regex="carshare-(admin|api|customer)-(?<version>.*).tar.gz"
  local folder="/UrbanActive/Products/Maven/admin"
  local version="1.0.0"

  check_without_credentials_with_version $endpoint $regex $folder $version $src
  
}

it_can_list_releases_from_protected_artifactory_with_version() {

  local local_ip=$(find_docker_host_ip) 
  #local_ip="localhost"

  local src=$(mktemp -d $TMPDIR/in-src.XXXXXX)
  local endpoint="http://${local_ip}:8081/artifactory"
  local regex="carshare-(admin|api|customer)-(?<version>.*).tar.gz"
  local folder="/UrbanActive/Products/Maven/admin"
  local version="1.0.0"
  local username="admin"
  local password="password"

  check_with_credentials_with_version $endpoint $regex $username $password $folder $version $src
  
}

run it_can_list_releases_from_artifactory
run it_can_list_releases_from_artifactory_with_version
run it_can_list_releases_from_protected_artifactory_with_version


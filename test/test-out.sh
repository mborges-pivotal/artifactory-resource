#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_deploy_release_to_artifactory() {

  local local_ip=$(find_docker_host_ip)
  #local_ip=localhost

  local src=$(mktemp -d $TMPDIR/out-src.XXXXXX)
  local endpoint="http://${local_ip}:8081/artifactory"
  local regex="carshare-(?<module>admin|api|customer)-(?<version>.*).tar.gz"

  local repository="/UrbanActive/Products/Maven/admin"
  local file="carshare-admin-1.0.0-rc.0.tar.gz"

  local version=1.0.0-rc.1

  deploy_without_credentials $endpoint $regex $repository $file $version $src 
}

it_can_deploy_release_to_artifactory_with_credentials() {

  local local_ip=$(find_docker_host_ip)
  #local_ip=localhost

  local src=$(mktemp -d $TMPDIR/out-src.XXXXXX)
  local endpoint="http://${local_ip}:8081/artifactory"
  local regex="carshare-(?<module>admin|api|customer)-(?<version>.*).tar.gz"

  local repository="/libs-snapshot-local"
  local file="carshare-admin-1.0.0-rc.0.tar.gz"

  local username="admin"
  local password="password"

  local version=1.0.0-rc.1

  deploy_with_credentials $endpoint $regex $repository $file $version $src $username $password 
}

run it_can_deploy_release_to_artifactory_with_credentials
run it_can_deploy_release_to_artifactory


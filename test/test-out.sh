#!/bin/bash

set -e

source $(dirname $0)/helpers.sh

it_can_deploy_release_to_artifactory() {

  local local_ip=$(find_docker_host_ip)
  #local_ip=localhost

  local src=$(mktemp -d $TMPDIR/out-src.XXXXXX)
  local endpoint="http://${local_ip}:8081/artifactory"
  local regex="carshare-(?<module>admin|api|customer)-(?<version>.*).tar.gz"

  local folder="/UrbanActive/Products/Maven/admin"
  local file="carshare-admin-1.0.0-rc.0.tar.gz"

  local version=1.0.0-rc.0

  deploy_without_credentials $endpoint $regex $folder $file $version $src | jq -e "
    .version == {version: $(echo $version | jq -R .)}
  "
}


run it_can_deploy_release_to_artifactory


#!/bin/bash

set -e -u

set -o pipefail

export TMPDIR_ROOT=$(mktemp -d /tmp/artifactory-tests.XXXXXX)
trap "rm -rf $TMPDIR_ROOT" EXIT

if [ -d /opt/resource ]; then
  resource_dir=/opt/resource
else
  resource_dir=$(cd $(dirname $0)/../assets && pwd)
fi

run() {
  export TMPDIR=$(mktemp -d ${TMPDIR_ROOT}/artifactory-tests.XXXXXX)

  echo -e 'running \e[33m'"$@"$'\e[0m...'
  eval "$@" 2>&1 | sed -e 's/^/  /g'
  echo ""
}

find_primary_ip() {
  ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'
}

find_docker_host_ip() {
  /sbin/ip route | awk '/default/ { print $3 }'
}

create_version_file() {
  local version=$1
  local src=$2

  mkdir $src/version
  echo "$version" > $src/version/number

  echo version/number
}

create_file() {
  local src=$1
  local file=$2

  # Mock the artifact
  mkdir $src/build-output
  echo "Dummy File" > $src/build-output/$file
  touch $src/build-output/$file

  echo "$src/build-output/$file"
}

# CHECK
check_without_credentials_and_version() {

  local endpoint=$1
  local regex=$2
  local folder=$3
  local src=$4

  jq -n "{
    source: {
      endpoint: $(echo $endpoint | jq -R .),
      repository: $(echo $folder | jq -R .),
      regex: $(echo $regex | jq -R .)
    }
  }" | $resource_dir/check "$src" | tee /dev/stderr
}

# CHECK
check_without_credentials_with_version() {

  local endpoint=$1
  local regex=$2
  local folder=$3
  local version=$4
  local src=$5

  jq -n "{
    source: {
      endpoint: $(echo $endpoint | jq -R .),
      repository: $(echo $folder | jq -R .),
      regex: $(echo $regex | jq -R .)
    },
    version: { version: $(echo $version| jq -R .)
    }  
  }" | $resource_dir/check "$src" | tee /dev/stderr
}

# CHECK
check_with_credentials_with_version() {

  local endpoint=$1
  local regex=$2
  local username=$3
  local password=$4
  local folder=$5
  local version=$6
  local src=$7

  jq -n "{
    source: {
      endpoint: $(echo $endpoint | jq -R .),
      repository: $(echo $folder | jq -R .),
      regex: $(echo $regex | jq -R .),
      username: $(echo $username | jq -R .),
      password: $(echo $password | jq -R .)
    },
    version: { version: $(echo $version| jq -R .)
    }  
  }" | $resource_dir/check "$src" | tee /dev/stderr
}

# IN
in_without_credentials_with_version() {

  local endpoint=$1
  local regex=$2
  local folder=$3
  local version=$4
  local src=$5

  jq -n "{
    source: {
      endpoint: $(echo $endpoint | jq -R .),
      repository: $(echo $folder | jq -R .),
      regex: $(echo $regex | jq -R .)
    },
    version: { version: $(echo $version| jq -R .)
    }  
  }" | $resource_dir/in "$src" | tee /dev/stderr
}

# IN
in_with_credentials_with_version() {

  local endpoint=$1
  local regex=$2
  local folder=$3
  local version=$4
  local src=$5

  local username=$6
  local password=$7

  jq -n "{
    source: {
      endpoint: $(echo $endpoint | jq -R .),
      username: $(echo $username | jq -R .),
      password: $(echo $password | jq -R .),
      repository: $(echo $folder | jq -R .),
      regex: $(echo $regex | jq -R .)
    },
    version: { version: $(echo $version| jq -R .)
    }  
  }" | $resource_dir/in "$src" | tee /dev/stderr
}

# OUT
deploy_without_credentials() {

  local endpoint=$1
  local regex=$2
  local repository=$3
  local file=$(create_file "$6" "$4")
  local version=$5
  local src=$6

  local version_file=$(create_version_file "$version" "$src")

  jq -n "{
    params: {
      file: $(echo $file | jq -R .),
      version_file: $(echo $version_file | jq -R .)
    },
    source: {
      endpoint: $(echo $endpoint | jq -R .),
      repository: $(echo $repository | jq -R .),
      regex: $(echo $regex | jq -R .)
    }
  }" | $resource_dir/out "$src" | tee /dev/stderr
}

# OUT
deploy_with_credentials() {

 local endpoint=$1
  local regex=$2
  local repository=$3
  local file=$(create_file "$6" "$4")
  local version=$5
  local src=$6

  local username=$7
  local password=$8

  local version_file=$(create_version_file "$version" "$src")

  cat <<EOF | $resource_dir/out "$src" | tee /dev/stderr
  {
    "params": {
      "file": "$file",
      "version_file": "$version_file"
    },
    "source": {
      "endpoint": "$endpoint",
      "repository": "$repository",
      "username": "$username",
      "password": "$password"
    }
  }
EOF
}


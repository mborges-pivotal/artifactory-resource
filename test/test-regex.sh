#!/bin/bash

# parse file
applyRegex() {
  local regex=$1
  local file=$2

  if [[ $file =~ $regex ]];
    then
        version="${BASH_REMATCH[1]}"
        echo "${version}" 
    else
        echo "$file doesn't match" >&2 # this could get noisy if there are a lot of non-matching files
        exit 1
    fi
    echo "${version}"
}

# Use jq regex since it support grouping
# "carshare-(?<module>admin|api|customer)-(?<version>.*).tar.gz" 
# "carshare-api-1.0.0-rc.0.tar.gz"
applyRegex_version() {
  local regex=$1
  local file=$2

  jq -n "{
  version: $(echo $file | jq -R .)
  }" | jq --arg v "$regex" '.version | capture($v)' | jq -r '.version'

}

# retrieve all versions from artifactory
# e.g url=http://localhost:8081/artifactory/api/storage/UrbanActive/Products/Maven/admin
#     regex=carshare-(admin|api|customer)-(?<version>.*).tar.gz
artifactory_artifacts() {
  local artifacts_url=$1
  local regex=$2

  curl $1 | jq --arg v "$regex" '[.children[].uri | capture($v)]' | jq 'sort_by(.version)'

}

# retrieve current from artifactory
# e.g url=http://localhost:8081/artifactory/api/storage/UrbanActive/Products/Maven/admin
#     regex=carshare-(admin|api|customer)-(?<version>.*).tar.gz
artifactory_current_version() {
  local artifacts_url=$1
  local regex=$2

  curl $1 | jq --arg v "$regex" '[.children[].uri | capture($v)]' | jq 'sort_by(.version)' | jq '[.[length-1] | {version: .version}]'

}

# check provided version returning all version
# e.g url=http://localhost:8081/artifactory/api/storage/UrbanActive/Products/Maven/admin
#     regex=carshare-(admin|api|customer)-(?<version>.*).tar.gz
#     version=1.0.0.2
artifactory_versions() {
  local artifacts_url=$1
  local regex=$2

  curl $1 | jq --arg v "$regex" '[.children[].uri | capture($v)]' | jq 'sort_by(.version)' | jq '[.[] | {version: .version}]'

}

check_version() {
  local artifacts_url=$1
  local regex=$2
  local version=$3

  result=$(artifactory_versions "$artifacts_url" "$regex")
  echo $result | jq --arg v "$version" '[foreach .[] as $item ([]; $item ; if $item.version >= $v then $item else empty end)]'

}

# check provided version returning all version
# e.g url=http://localhost:8081/artifactory/api/storage/UrbanActive/Products/Maven/admin
#     regex=carshare-(admin|api|customer)-(?<version>.*).tar.gz
#     version=1.0.0.2
artifactory_files() {
  local artifacts_url=$1
  local regex="(?<uri>$2)"

  curl $1 | jq --arg v "$regex" '[.children[].uri | capture($v)]' | jq 'sort_by(.version)' | jq '[.[] | {uri: .uri, version: .version}]'

}

in_file_with_version() {
  local artifacts_url=$1
  local regex="(?<uri>$2)"
  local version=$3

  result=$(artifactory_files "$artifacts_url" "$regex")
  echo $result | jq --arg v "$version" '[foreach .[] as $item ([]; $item ; if $item.version == $v then $item else empty end)]'

}

check_file_with_version() {
  local artifacts_url=$1
  local regex=$2
  local version=$3

  result=$(artifactory_versions "$artifacts_url" "$regex")
  echo $result | jq --arg v "$version" '[foreach .[] as $item ([]; $item ; if $item.version == $v then $item else empty end)]'

}


# curl http://localhost:8081/artifactory/api/storage/UrbanActive/Products/Maven/admin | 
# jq '.children[].uri | capture("carshare-admin-(?<version>.*).tar.gz")'
# jq '[.children[].uri | capture("carshare-admin-(?<version>.*).tar.gz")]'

#result=$(applyRegex "(?P<file>carshare-(?:api|customer|admin)-(?P<version>.*).tar.gz)" "carshare-admin-1.0.0-rc.0.tar.gz")
version=$(applyRegex_version "carshare-(?<module>admin|api|customer)-(?<version>.*).tar.gz" "carshare-api-1.0.0-rc.0.tar.gz")
echo "version -> $version"

url=http://localhost:8081/artifactory/api/storage/UrbanActive/Products/Maven/admin 
echo "Testing retrieving artifactis with version group"
echo $(artifactory_artifacts "$url" "carshare-(admin|api|customer)-(?<version>.*).tar.gz")

echo "Testing retrieving artifactis with module and version group"
echo $(artifactory_artifacts "$url" "carshare-(?<module>admin|api|customer)-(?<version>.*).tar.gz")

echo "Testing retrieving current version"
echo $(artifactory_current_version "$url" "carshare-(admin|api|customer)-(?<version>.*).tar.gz")

echo "Testing check version"
result=$(artifactory_versions "$url" "carshare-(admin|api|customer)-(?<version>.*).tar.gz")
echo $result

result='[ { "version": "1.0.0-rc.0" }, { "version": "1.0.0.2" }, { "version": "1.0.0.3" } ]'

echo "Testing check by version output"
echo $result | jq '[foreach .[] as $item ([]; $item ; if $item.version >= "1.0.0.2" then $item else empty end)]'

echo "Testing artifactory files"
result=$(artifactory_files "$url" "carshare-(admin|api|customer)-(?<version>.*).tar.gz")
echo $result

echo "Testing in with good version"
result=$(in_file_with_version "$url" "carshare-(admin|api|customer)-(?<version>.*).tar.gz" "1.0.0.2")
echo $result

echo "############### Testing check by version output function"
url="-u admin:password http://192.168.1.224:8081/artifactory/api/storage/libs-snapshot-local/Pivotal"
echo $(check_version "$url" "carshare-(admin|api|customer)-(?<version>.*).tar.gz" "1.0.0.2")


#echo '[ { "version": "1.1.0-rc.0" }, { "version": "1.0.0.2" } ]' | jq 'sort_by(.version)'



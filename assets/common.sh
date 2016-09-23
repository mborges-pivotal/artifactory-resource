
# Using jq regex so we can support groups
applyRegex_version() {
  local regex=$1
  local file=$2

  jq -n "{
  version: $(echo $file | jq -R .)
  }" | jq --arg v "$regex" '.version | capture($v)' | jq -r '.version'

}

# retrieve current from artifactory
# e.g url=http://localhost:8081/artifactory/api/storage/UrbanActive/Products/Maven/admin
#     regex=carshare-(admin|api|customer)-(?<version>.*).tar.gz
artifactory_current_version() {
  local artifacts_url=$1
  local regex=$2

  curl $1 | jq --arg v "$regex" '[.children[].uri | capture($v)]' | jq 'sort_by(.version)' | jq '[.[length-1] | {version: .version}]'

}

# Return all versions
# e.g url=http://localhost:8081/artifactory/api/storage/UrbanActive/Products/Maven/admin
#     regex=carshare-(admin|api|customer)-(?<version>.*).tar.gz
artifactory_versions() {
  local artifacts_url=$1
  local regex=$2

  curl $1 | jq --arg v "$regex" '[.children[].uri | capture($v)]' | jq 'sort_by(.version)' | jq '[.[] | {version: .version}]'

}

# return uri and version of all files
# e.g url=http://localhost:8081/artifactory/api/storage/UrbanActive/Products/Maven/admin
#     regex=carshare-(admin|api|customer)-(?<version>.*).tar.gz
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


# return the list of versions from provided version
#     version=1.0.0.2
check_version() {
  local artifacts_url=$1
  local regex=$2
  local version=$3

  result=$(artifactory_versions "$artifacts_url" "$regex")  #result=$(curl "$artifacts_url" "$regex")
  echo $result | jq --arg v "$version" '[foreach .[] as $item ([]; $item ; if $item.version >= $v then $item else empty end)]'

}

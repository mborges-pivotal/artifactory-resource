# Artifactory Resource

Deploys and retrieve artifacts from artifactory. 

This resource was tested with the [Artifactory] (https://www.jfrog.com/confluence/display/RTF/Running+with+Docker) docker images.

## Todo
* At deployment (out), we should use artifactory build capabilities. So concourse becomes first class CI citizen to artifactory
* clean-up tests
* use properties concept, needed for artifactory build integration
* improve error handling. Not showing the errors. E.g. curl without user:password
* check version sort semantic. E.g. 1.0.1 is coming before 1.0.1-rc1 (meaning, is older when in fact is a release). Mayb it is fine because we're not supposed to have releases in the same folder (with and without -rc9)
* Maybe allow the artifactory path to be configure as a parameters on put and get

## Source Configuration

* `endpoint`: *Required.* The artifactory REST API endpoint. eg. http://192.168.1.224:8081/artifactory.
* `repository`: *Required.* The artifactory repository which includes any folder path. eg. /ext-snapshot-local/Products/admin.
* `regex`: *Required.* Regular expression used to extract artifact version, must contain 'version' group. ```E.g. pivotal-(admin|api|customer)-(?<version>.*).tar.gz```
* `username`: *Optional.* Username for HTTP(S) auth when accessing an authenticated repository.
* `password`: *Optional.* Password for HTTP(S) auth when accessing an authenticated repository.

## Parameter Configuration

* `file`: *Required for put* The file to upload to artifactory
* `regex`: *Optional* overwrites the source regex. 
* `folder`: *Optional.* appended to the repository in source - must start with forward slash /

Resource configuration for an authenticated repository:

``` yaml
resources:
- name: artifactory
  type: artifactory
  source:
    endpoint: http://192.168.1.224:8081/artifactory
    repository: "/ext-snapshot-local/Products/admin"
    regex: "pivotal-admin-(?<version>.*).tar.gz"
```

Deploying an artifact build by Maven

``` yaml
jobs:
- name: build
  plan:
  - get: source-code
    trigger: true
  - get: version
    params: { pre: rc }
  - task: build
    file: source-code/ci/build.yml
  - put: milestone
    resource: artifactory
    params:
      file: build-output/myartifact-*.jar
  - put: version
    params: { file: version/number }
```

## Behavior

### `check`: ...

Relies on the regex to retrieve artifact versions 


### `in`: ...

Same as check, but retrieves the artifact based on the provided version


### `out`: Deploy to a repository.

Deploy the artifact.

#### Parameters

* `file`: *Required.* The path to the artifact to deploy.

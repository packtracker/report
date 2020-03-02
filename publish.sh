#!/bin/bash

set -e

if [[ $# -eq 0 ]]; then
cat <<-HELP
  ./publish.sh <version> <environment>

  Publishes docker image and CircleCI Orb

  <version> - SemVer identifier of the release
  <environment> - "development" (default) or "production"
HELP
exit
fi

[[ -z "$1" ]] && { echo "No version specified" ; exit 1; }
version="$1"

[[ -z "$2" ]] && { echo "No environment specified, defaulting to development"; }
environment="${2:-development}"


if [ "$environment" == "production" ]; then
cat <<-VERSIONING
  It looks like you're trying to publish to production!

  Be sure that you have bumped the version in the following places:
    - Dockerfile
    - orb.yml
    - README.md

VERSIONING
fi

read -p "Ready to publish to $environment? " -n 1 -r
echo    # (optional) move to a new line
if ! [[ $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

if [ "$environment" == "production" ]; then
  dockertag="packtracker/report:$version"
  circlecitag="packtracker/report@$version"
else
  dockertag="packtracker/report:$version-dev"
  circlecitag="packtracker/report@dev:$version"
fi

echo "Publishing docker image: $dockertag"
docker build -f Dockerfile.base -t $dockertag .
docker push $dockertag

echo "Publishing circleci orb: $circlecitag"
circleci orb validate ./orb.yml
circleci orb publish ./orb.yml $circlecitag

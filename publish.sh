#!/bin/sh

set -eu

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

  read -p "Ready to publish? " -n 1 -r
  echo    # (optional) move to a new line
  if ! [[ $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
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

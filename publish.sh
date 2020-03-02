[[ -z "$1" ]] && { echo "No version specified" ; exit 1; }
version="$1"

[[ -z "$2" ]] && { echo "No environment specified, defaulting to development"; }
environment="${2:-development}"

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

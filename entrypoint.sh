#!/bin/sh

set -eu

: "${PT_PROJECT_TOKEN:?'You must set the PT_PROJECT_TOKEN secret'}"

if [ -n "${PT_PROJECT_ROOT:-}" ]; then
  echo "Custom root directory detected, navigating to: $PT_PROJECT_ROOT"
  cd $PT_PROJECT_ROOT
fi

CRA_VERSION=$(jq '.dependencies | .["react-scripts"]' package.json)

if [ -e yarn.lock ]; then
  yarn config set ignore-engines true
  packager="yarn"
  install="add"
elif [ -e package.json ]; then
  packager="npm"
  install="install"
else
  echo "Could not find package.json within $(pwd)" 1>&2
  echo 'Try setting a custom root directory with the $PT_PROJECT_ROOT environment variable to set a custom root path.' 1>&2
  exit 2
fi

if [ "$CRA_VERSION" != "null" ]; then
  echo "Detected Create React App ($CRA_VERSION)"
  echo yes | $packager run eject
  export WEBPACK_CONFIG_PATH='./config/webpack.config.js'
fi

$packager install
$packager $install @packtracker/webpack-plugin@2.2.0

export NODE_ENV="production"

cp /report.js ./report.js
node ./report.js

git reset --hard HEAD
git clean -fxd

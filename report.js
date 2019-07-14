const util = require('util')
const fs = require('fs')
const webpack = require('webpack')
const PacktrackerPlugin = require('@packtracker/webpack-plugin')

let config = {}
if (fs.existsSync(process.env.WEBPACK_CONFIG_PATH)) {
  console.log(`packtracker: webpack config file loaded (${process.env.WEBPACK_CONFIG_PATH})`)
  config = require(process.env.WEBPACK_CONFIG_PATH)
} else {
  console.log(`packtracker: webpack config file not found`)
}


config.plugins = config.plugins || []

if (process.env.GITHUB_EVENT_PATH) {
  console.log(`packtracker: loading github config`)
  config.plugins.push(new PacktrackerPlugin(githubConfig()))
} else if (process.env.CIRCLECI) {
  console.log(`packtracker: loading circle config`)
  config.plugins.push(new PacktrackerPlugin(circleConfig()))
}

webpack(config, (err) => {
  if (err) {
    console.log(`packtracker: webpack build failed`)
    process.exit(1)
  } else {
    console.log(`packtracker: webpack build succeeded`)
    process.exit(0)
  }
})

function githubConfig () {
  const event = require(process.env.GITHUB_EVENT_PATH)
  console.log(util.inspect(event))
  return {
    upload: true,
    fail_build: true,
    branch: event.ref.replace('refs/heads/', ''),
    author: event.head_commit.author.email,
    message: event.head_commit.message,
    commit: process.env.GITHUB_SHA,
    committed_at: parseInt(+new Date(event.head_commit.timestamp) / 1000),
    prior_commit: event.before,
  }
}

function circleConfig () {
  return {
    upload: true,
    fail_build: true,
    branch: process.env.CIRCLE_BRANCH,
    commit: process.env.CIRCLE_SHA1,
  }
}

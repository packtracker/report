FROM packtracker/report:2.3.0

LABEL "com.github.actions.name"="Webpack Stat Reporter (packtracker.io)"
LABEL "com.github.actions.description"="Report your webpack build stats to the packtracker.io service."
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="gray-dark"

ENTRYPOINT ["/entrypoint.sh"]

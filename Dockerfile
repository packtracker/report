FROM packtracker/report:2.1.2

LABEL "com.github.actions.name"="Report to packtracker.io"
LABEL "com.github.actions.description"="Report your webpack build stats to the packtracker.io service."
LABEL "com.github.actions.icon"="upload-cloud"
LABEL "com.github.actions.color"="#363636"

ENTRYPOINT ["/entrypoint.sh"]

FROM node:12-slim

RUN apt-get update && apt-get install jq git yarn -y && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh
COPY ./report.js /report.js

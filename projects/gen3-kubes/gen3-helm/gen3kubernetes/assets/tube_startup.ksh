#!/usr/bin/env bash

cp /usr/share/gen3/tube/creds.json /tube/creds.json
cp /usr/share/gen3/tube/etlMapping.yaml /tube/etlMapping.yaml

test -f /usr/share/gen3/tube/schemas.tar.gz.base64 \
        && base64 --decode /usr/share/gen3/tube/schemas.tar.gz.base64 | tar xzvf -C $PATH_TO_SCHEMA_DIR -
pip install gdcdictionary


echo "HAL - I'm going to sleep indefinitely, wake me when we get to Jupyter"
while true; do sleep 5; done

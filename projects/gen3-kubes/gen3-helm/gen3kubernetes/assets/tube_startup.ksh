#!/usr/bin/env bash

cp /usr/share/gen3/tube/etl_creds.json /tube/creds.json
cp /usr/share/gen3/tube/etlMapping.yaml /tube/etlMapping.yaml

pip install gdcdictionary

echo "HAL - I'm going to sleep indefinitely, wake me when we get to Jupyter"
while true; do sleep 5; done

#!/bin/bash
# Script to create and re-create es indices and setup guppy
TUBE=`kubectl get pods | grep tube | awk '{print $1}'`
GUPPY=`kubectl get pods | grep guppy | awk '{print $1}'`

ES=`kubectl exec $TUBE -- env | grep ES_URL | awk -F = '{print $2}'`

kubectl exec $TUBE -- curl -X DELETE http://$ES:9200/etl_0
sleep 2
kubectl exec $TUBE -- curl -X DELETE http://$ES:9200/file_0
sleep 2
kubectl exec $TUBE -- curl -X DELETE http://$ES:9200/file-array-config_0
sleep 2
kubectl exec $TUBE -- curl -X DELETE http://$ES:9200/etl-array-config_0
sleep 2
kubectl exec $TUBE -- bash -c "set -x && python run_config.py && python run_etl.py"

kubectl delete pod $GUPPY

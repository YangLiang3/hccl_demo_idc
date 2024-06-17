#!/bin/bash -x 

kubectl delete -f job/1.15.1/all_reduce/all/hccl_demo_ar_64cards.yaml

terminating_llama_pod=$(kubectl get po -n alibaba | grep  alibaba | grep Terminating)
if [ -n "$terminating_llama_pod" ]; then
    sleep 120
fi

#create the job to start the run
kubectl create -f job/1.15.1/all_reduce/all/hccl_demo_ar_64cards.yaml
sleep 2
kubectl get pods -n alibaba  | grep alibaba
sleep 12
kubectl get pods -n alibaba | grep alibaba
sleep 12
kubectl get pods -n alibaba  | grep alibaba
sleep 20
kubectl get pods -n alibaba  | grep alibaba
./logs

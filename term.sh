#!/bin/bash -x 

#delete previous jobs
kubectl delete -f job/1.15.1/${2}/all/hccl_demo_ar_${1}.yaml >/dev/null 2>&1

terminating_llama_pod=$(kubectl get po -n alibaba | grep  alibaba | grep Terminating)
if [ -n "$terminating_llama_pod" ]; then
    echo "Terminating Pods takes 2 minutes"
    sleep 10
fi

#verify no pods are stuck 
terminating_llama_pod=$(kubectl get po -n alibaba | grep  alibaba | grep Terminating)
if [ -n "$terminating_llama_pod" ]; then
    echo "Terminating Pods takes 2 minutes"
    sleep 10
else 
	echo "No pods are stuck"
fi



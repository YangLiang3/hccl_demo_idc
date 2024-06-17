#!/bin/bash -x 

#delete previous jobs
kubectl delete -f job/1.15.1/all_reduce/all/hccl_demo_ar_64cards.yaml >/dev/null 2>&1
#kubectl delete mpijob alibaba-llamav2-70b-32 -n habanalabs   >/dev/null 2>&1

terminating_llama_pod=$(kubectl get po -n alibaba | grep  alibaba | grep Terminating)
if [ -n "$terminating_llama_pod" ]; then
    echo "Terminating Pods takes 2 minutes"
    sleep 120
fi

#verify no pods are stuck 
terminating_llama_pod=$(kubectl get po -n alibaba | grep  alibaba | grep Terminating)
if [ -n "$terminating_llama_pod" ]; then
    echo "Terminating Pods takes 2 minutes"
    sleep 120
else 
	echo "No pods are stuck"
fi



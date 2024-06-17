#!/bin/bash
WORKER_DIR="${WORKER_DIR:-/}";
COPY_HCL="${COPY_HCL:-False}";

cp $HOME_DIR/hccl_demo_p/launch/limits.conf /etc/security/;

if [ "$COPY_HCL" = "True" ]; then
    cp /mnt/weka/alibaba/hccl_demo_p/launch/1.14.0-248/libhcl.so /usr/lib/habanalabs/;
fi


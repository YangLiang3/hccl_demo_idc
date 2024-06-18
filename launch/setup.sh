#!/bin/bash
WORKER_DIR="${WORKER_DIR:-/}";
COPY_HCL="${COPY_HCL:-False}";

cp $WORKER_DIR/launch/limits.conf /etc/security/;

if [ "$COPY_HCL" = "True" ]; then
    cp $WORKER_DIR/launch/1.14.0-248/libhcl.so /usr/lib/habanalabs/;
fi


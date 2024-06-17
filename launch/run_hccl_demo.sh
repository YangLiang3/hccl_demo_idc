#!/bin/bash

HOME_DIR="${HOME_DIR:-/home/ltran}";
WORKER_DIR="${WORKER_DIR:-${HOME_DIR}/experiments/hccl_test}";
MODEL_PATH="${MODEL_PATH:-${WORKER_DIR}/hccl_demo}";
# MPI_ROOT="/opt/amazon/openmpi/";
SYNAPSE_VERSION="${SYNAPSE_VERSION:-1.6.1-92}";

HCCL_TEST="${HCCL_TEST:-all_reduce}";
HCCL_LOOP=${HCCL_LOOP:-1000};
HCCL_SIZE="${HCCL_SIZE:-256M}";
HCCL_GROUP_MODE="${HCCL_GROUP_MODE:-0}"
HCCL_MPI_NODE="${HCCL_MPI_NODE:-2}"

HOSTSFILE=${HOSTSFILE:-$OMPI_MCA_orte_default_hostfile}
NUM_NODES=$(wc -l < $HOSTSFILE)
NGPU_PER_NODE=8;
N_CARDS=$((NUM_NODES*NGPU_PER_NODE));
TIMESTAMP_DIR=$(date -d "today" +"%Y"-"%m"-"%d");
TIMESTAMP=$(date -d "today" +"%Y"-"%m"-"%d"_"%H"-"%M");

RESULT_DESCRIPTION="${RESULT_DESCRIPTION:-}";
RESULTS_DIR=$WORKER_DIR/results/hccl_demo/$SYNAPSE_VERSION/$HCCL_TEST/$RESULT_DESCRIPTION/${N_CARDS}/${TIMESTAMP_DIR}/${TIMESTAMP};
MPILOG_DIR=$RESULTS_DIR/mpi_log;

DEBUG="${DEBUG:-False}";
if [ "$DEBUG" = "True" ]; then
        # DEBUG_CMD="-x LOG_LEVEL_ALL="4" -x ENABLE_CONSOLE="true"";
        DEBUG_CMD="-x LOG_LEVEL_ALL_HCL=2 -x LOG_LEVEL_HCL_API=0";
        # DEBUG_CMD="-x LOG_LEVEL_HCL="3" -x ENABLE_CONSOLE="true"";
        # DEBUG_CMD="-x CONGESTION_WINDOW=128 -x ENABLE_EXPERIMENTAL_FLAGS=true";
        # DEBUG_CMD="-x TRACE_POINT_ENABLE=1 -x HABANA_LOGS=$RESULTS_DIR -x HBN_SYNAPSE_LOGGER_COMMANDS=stop_data_capture:no_eager_flush:use_pid_suffix -x LD_PRELOAD=/usr/local/lib/python3.8/dist-packages/habana_frameworks/torch/lib/pytorch_synapse_logger.so";
fi


CONGESTION_WINDOW="${CONGESTION_WINDOW:-False}";
if [ "$CONGESTION_WINDOW" = "True" ]; then
        CONGESTION_WINDOW_CMD="-x CONGESTION_WINDOW=48 -x ENABLE_EXPERIMENTAL_FLAGS=true";
fi

HCCL_SPRAY="${HCCL_SPRAY:-False}";
if [ "$HCCL_SPRAY" = "True" ]; then
        HCCL_SPRAY_CMD="-x HCL_SCALE_OUT_QP_SETS=2 -x EXP_FLAGS=true";
fi

if [ "$HCCL_TEST" = "send_recv" ]; then
        SEND_RECV_ARGS="--ranks_list $RANKS_LIST";
fi

EXTRA_ARGS="${EXTRA_ARGS:-}";

SIZE_RANGE="${SIZE_RANGE:-}";


if [ -z "$SIZE_RANGE"]; then
        SIZE_CMD="--size $HCCL_SIZE";
else
        SIZE_CMD="--size_range $SIZE_RANGE ";
fi




cd ${MODEL_PATH};
CMD="python ${MODEL_PATH}/run_hccl_demo.py \
        --test $HCCL_TEST \
        --loop $HCCL_LOOP \
        $SIZE_CMD \
        $SEND_RECV_ARGS \
	--group $HCCL_GROUP_MODE \
	--mpi_node $HCCL_MPI_NODE \
        -mpi ";
echo CMD ${CMD};

mkdir -p $RESULTS_DIR;
mkdir -p $RESULTS_DIR/habana_logs;
mkdir -p $MPILOG_DIR;
chmod -R a+rx $RESULTS_DIR;
chmod -R a+rx $RESULTS_DIR/habana_logs;
chmod -R a+rx $MPILOG_DIR;

set -eo pipefail;

$CMD \
        -np ${N_CARDS} \
        --allow-run-as-root \
        --bind-to core \
        --map-by ppr:4:socket:PE=6 \
        --rank-by core --report-bindings \
        --tag-output \
        --output-filename $MPILOG_DIR \
        --merge-stderr-to-stdout  \
        -x PYTHONPATH="/usr/lib/habanalabs/:$PYTHONPATH" \
        -x HABANA_LOGS="$RESULTS_DIR/habana_logs" \
        -x HCL_USE_IBVERBS=False \
        $EXTRA_ARGS \
        $CONGESTION_WINDOW_CMD \
        $DEBUG_CMD \
        $HCCL_SPRAY_CMD \
        2>&1 | ts '[%Y-%m-%d %H:%M:%S]' | tee $RESULTS_DIR/run.log ;

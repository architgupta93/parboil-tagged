#  !/bin/bash
export PARBOIL_DIR='/home/ag/bigdata/2_Gpgpu_Architecture/parboil'
export DATASET_DIR=$PARBOIL_DIR/datasets
export LOGS_DIR=$PARBOIL_DIR/logs
./parboil compile bfs cuda
cp gpgpu-sim/* benchmarks/bfs/build/cuda_default/
pushd benchmarks/bfs/build/cuda_default/
export dateNow=`date +%Y-%m-%d--%H-%M`
./bfs $DATASET_DIR/bfs/NY/input/graph_input.dat > $LOGS_DIR/$dateNow--bfs.log


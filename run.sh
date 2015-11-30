#  !/bin/bash
PARBOIL_DIR='/home/ag/bigdata/2_Gpgpu_Architecture/parboil'
DATASET_DIR=$PARBOIL_DIR/datasets
LOGS_DIR=$PARBOIL_DIR/logs

EXE='0'
for key in $@
do
	case $key in
		-x | --execute)	
			./parboil compile bfs cuda
			cp gpgpu-sim/* benchmarks/bfs/build/cuda_default/
			pushd benchmarks/bfs/build/cuda_default/
			EXE='1'
			;;
		-c | --clean)
			./parboil clean bfs
			;;
		-l | --clear-logs)
			rm $LOGS_DIR/*
			;;
		*)
			;;	
	esac
done

if [ $EXE -ne "0" ];
then
	export dateNow=`date +%Y-%m-%d--%H-%M`
	./bfs $DATASET_DIR/bfs/NY/input/graph_input.dat > $LOGS_DIR/$dateNow--bfs.log
	popd
fi


#  !/bin/bash
source make.config

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
			rm -rf logs/*
			rm -rf output/*
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
	mkdir -p $LOGS_DIR
	mkdir -p $RESULTS_DIR
	mkdir -p $LOGS_DIR/bfs
	#./bfs -i $DATASET_DIR/bfs/NY/input/graph_input.dat > $LOGS_DIR/$dateNow--bfs.log
	./bfs -i $RODINIA_DATA -o $RESULTS_DIR/bfs/$dateNow--result.log > $LOGS_DIR/bfs/$dateNow--bfs.log
	popd
fi


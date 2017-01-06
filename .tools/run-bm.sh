# !/bin/bash

source /home/ag/bigdata/2_Gpgpu_Architecture/rodinia_3.0/cuda/.tools/config.sh

INPUT='default'
OUTPUT='default'
EXE_DIR=''
EXE_OPTS=''

# Reading command line arguments and setting appropriate system variable required to
# run the benchmark (on GPU or GPGPU-SIM)

function help_gpu
{
	echo "You can use this script to run the Rodinia benchmar suite"
	echo "Usage ./run.sh -[option(s)-short] [arguments]"
	echo "List of available options:"
	echo "-x | --execute  <BENCHMARK> 	Runs the benchmark on a GPU"
	echo "-s | --simulate <BENCHMARK> 	Runs the benchmark on GPGPU-SIM"
	echo "-c | --clean    <BENCHMARK>	Make clean on the benchmark"
	echo "-i | --input    <FILENAME> 	Input file for the benchmark (Optional)"
	echo "-o | --output   <FILENAME> 	Output file for the benchmark (Optional)"
	echo "-h | --help 			Prints this help file"
	return
}

function run_default
{
	echo "Running BFS with 4096 nodes on GPGPU-SIM by default"
	pushd $RODINIA_DIR/bfs
	if [ -z "$LD_LIBRARY_PATH" ]; then
		echo "Temporarily setting up LD_LIBRARY_PATH. Please configure manually"
		source /home/ag/0_Unison/4_Collections/1_scripts/gpgpu-sim-config.sh
	fi
	./run.sh -s
	popd
	return
}

function invalid_input
{
	read -p "Press h for help. Press any other key to run the default configuration" -n1 -s
	if [ "$REPLY" == 'h' ] || [ $REPLY == 'H' ];  then
		help_gpu
	else
		run_default
	fi
	return
}

if [ $# -eq 0 ]; then
	invalid_input
	exit
fi

while [[ $# -gt 0 ]]
do
	key=$1
	case $key in
		-t | --test)
			echo "debug feature. Not for regular use"
			echo `source /home/ag/0_Unison/4_Collections/1_scripts/gpgpu-sim-config.sh`
			exit
			;;
		-d | --default)
			run_default
			exit
			;;
			
		-h | --help)
			help_gpu
			exit
			;;

		-x | --execute)
			echo "Preparing $2 for GPU"
			EXE_DIR="$RODINIA_DIR/$2"	
			EXE_OPTS=$key
			shift
			;;

		-s | --simulate)
			echo "Preparing $2 for GPGPU-SIM"
			EXE_DIR="$RODINIA_DIR/$2"
			EXE_OPTS="$key"
			shift
			;;

		-c | --clean)
			EXE_DIR="$RODINIA_DIR/$2"
			if [ "$2" == 'all' ]; then
				rm -rf $OUTPUT_DIR/*
				rm -rf $RUN_DIR/*
				rm -rf $LOGS_DIR/*
				for bm in `ls $RODINIA_DIR`; do
					cd $bm
					make clean
					cd ..
				done
				exit
			else
				EXE_OPTS="$key"
				shift
			fi
			;;

		-i | --input)
			INPUT=$2
			EXE_OPTS="$EXE_OPTS $key $INPUT"
			shift
			;;

		-o | --output)
			OUTPUT=$2
			EXE_OPTS="$EXE_OPTS $key $OUTPUT"
			shift
			;;

		*)
			echo "Invalid input recorded!"
			invalid_input
			exit
			;;
	esac
	shift
done

# Checking that the executable directory has been set and also is valid
if [ "$EXE_DIR" != '' ] && [ -f $EXE_DIR/run.sh ]; then
	echo "Checking environment variables"
	pushd $EXE_DIR
	if [ "$LD_LIBRARY_PATH" == '' ]; then
		source /home/ag/0_Unison/4_Collections/1_scripts/gpgpu-sim-config.sh
	fi
	./run.sh $EXE_OPTS
	popd
else
	echo "Executable not specified or not found."
	echo "Use ./run.sh -h for help"	
fi

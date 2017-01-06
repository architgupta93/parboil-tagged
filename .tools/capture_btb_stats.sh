# !/bin/bash

dateNow=`date +%Y-%m-%d--%H-%M-%S`
START_TOKEN='BRANCH_STATS_PRINT: For Kernel(uid='
END_TOKEN='kernel_launch_uid = '
EOF_TOKEN=''		# Every BTB table is followed by a new line
			# This is to make it easy to read it inside
			# another program. Use $'\n' for inserting
			# 2 newline characters
BECNHMARK=''
INPUT_FILE=''
OUTPUT_BTB_FILE=results/btb_record--"$dateNow".txt
OUTPUT_KERNEL_FILE=results/kernel_names--"$dateNow".txt
EXCESS_HEAD_LINES='4'
EXCESS_TAIL_LINES='9'
ADDITIONAL_TAIL_LINES='3'
THREAD_STATS_EXCESS_HEAD_LINES='3'

while [[ $# > 0 ]]
do
	key=$1
	case $key in
		-c | --clean)
			rm -f results/btb_record--*.txt
			rm -f results/kernel_names--*.txt
			make clean
			exit
			;;

		-i | --input)		# specify the input file and parse it
			INPUT_FILE=$2		
			shift
			;;
		*)
			echo "Invalid input syntax"
			exit
			;;
	esac		# end case statement
	shift
done

if [[ $INPUT_FILE != '' ]] && [[ -f $INPUT_FILE ]]; then
	write_index=1
	c_active='0'
	c_extrinsic='0'
	c_intrinsic='0'
	
	# Lines following the END_TOKEN are the gpu_ipc/gpu_instructions etc
	# We will read them individually using regex and grep

	echo "Testing file sanity... [Checking if atleast one kernel record is present]"
	static_branch_counts=`grep -A 1 "CF_UTILS" $INPUT_FILE | tail -n 1`
	capture=`grep -A $ADDITIONAL_TAIL_LINES -B 1 "\<$END_TOKEN$write_index\>" $INPUT_FILE`

#	kernel_name=`echo "$capture" | grep -oP '(?<=kernel_name = ).*'`
#	gpu_ipc=`echo "$capture" | grep -oP '(?<=gpu_ipc =)[0-9]*'`
#	gpu_sim_cycle=`echo "$capture" | grep -oP '(?<=gpu_sim_cycle = )[0-9]*'`
#	gpu_sim_insn=`echo "$capture" | grep -oP '(?<=gpu_sim_insn = )[0-9]*'`
#
#	capture_data=`sed -n "/\<$START_TOKEN$write_index\>/,/\<$END_TOKEN$write_index\>/p" $INPUT_FILE`	     
#	thread_stats=`echo "$capture" | grep -A $THREAD_STATS_EXCESS_HEAD_LINES "Thread stats" | tail -n 1 | grep -o '[0-9]*'`
#
#	# Thread stats collects the active/extrinsic/intrinsic data from the log file. -A 3 would give 
#	# the Thread stats header line as well as the next three lines. EXCESS_HEAD_LINES=3, thus,
#	# does the job for us since we need to read just the last line for evaluation	
#	active_slots=`echo "$thread_stats" | head -n1`
#	c_active=$((c_active + active_slots))
#
#	extrinsic_slots=`echo "$thread_stats" | head -n2 | tail -n1`
#	c_extrinsic=$((c_extrinsic + extrinsic_slots))
#
#	intrinsic_slots=`echo "$thread_stats" | tail -n1`
#	c_intrinsic=$((c_intrinsic + intrinsic_slots))
#
#	write_btb=`echo "$capture_data" | head -n-$EXCESS_TAIL_LINES | tail -n+$[$EXCESS_HEAD_LINES+1]`
#	echo "$write_btb" > $OUTPUT_BTB_FILE
#	echo "$kernel_name" > $OUTPUT_KERNEL_FILE
#	#echo "$EOF_TOKEN" >> $OUTPUT_BTB_FILE
	
	echo "Kernel $kernel_name found. Searching for more kernels"
	while [[ $capture != "" ]]
	do
#		write_index=$[$write_index+1]
#		capture=`grep -A $ADDITIONAL_TAIL_LINES -B 1 "\<$END_TOKEN$write_index\>" $INPUT_FILE`
		kernel_name=`echo "$capture" | grep -oP '(?<=kernel_name = ).*'`
		gpu_ipc=`echo "$capture" | grep -oP '(?<=gpu_ipc = )[0-9.]*'`
		gpu_sim_cycle=`echo "$capture" | grep -oP '(?<=gpu_sim_cycle = )[0-9]*'`
		gpu_sim_insn=`echo "$capture" | grep -oP '(?<=gpu_sim_insn = )[0-9]*'`
		capture_data=`sed -n "/\<$START_TOKEN$write_index\>/,/\<$END_TOKEN$write_index\>/p" $INPUT_FILE`	     
		thread_stats=`echo "$capture_data" | grep -A $THREAD_STATS_EXCESS_HEAD_LINES "Thread stats" | tail -n 1 | grep -o '[0-9]*'`

		active_slots=`echo "$thread_stats" | head -n1`
		c_active=$((c_active + active_slots))

		extrinsic_slots=`echo "$thread_stats" | head -n2 | tail -n1`
		c_extrinsic=$((c_extrinsic + extrinsic_slots))

		intrinsic_slots=`echo "$thread_stats" | tail -n1`
		c_intrinsic=$((c_intrinsic + intrinsic_slots))

#		echo ""
#		echo "Thread-Slot-Stats:"
#		echo "Active: $c_active, Extrinsic: $c_extrinsic, Intrinsic: $c_intrinsic"

		write_btb=`echo "$capture_data" | head -n-$EXCESS_TAIL_LINES | tail -n+$[$EXCESS_HEAD_LINES+1]`

		echo "$write_btb" >> $OUTPUT_BTB_FILE
		echo "$kernel_name" >> $OUTPUT_KERNEL_FILE
		#echo "$EOF_TOKEN" >> $OUTPUT_BTB_FILE
		write_index=$[$write_index+1]
		capture=`grep -A $ADDITIONAL_TAIL_LINES -B 1 "\<$END_TOKEN$write_index\>" $INPUT_FILE`
	done

	make parse
	./parse $OUTPUT_BTB_FILE $OUTPUT_KERNEL_FILE
	echo ""
	echo "Thread-Slot-Stats:"
	echo "Active: $c_active, Extrinsic: $c_extrinsic, Intrinsic: $c_intrinsic"
	echo ""
	echo "Static branch stats"
	echo "$static_branch_counts"
	echo ""
else
	echo "Invalid input filename ($INPUT_FILE) supplied"
	exit
fi

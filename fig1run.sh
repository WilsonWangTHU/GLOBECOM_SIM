#/bin/bash
# the running of POMDP
cd /home/wtw/GLOBECOM_SIM

if [$# -eq 0]; then
	echo "Syntax error! please input the number"
else

# test for different arrive rate
	for (( iArrival = 1; iArrival <= $1; iArrival ++ )) 
	do
		filename="$iArrival""fig1arrivalRate.POMDP"
		outputFilename="$iArrival""fig1arrivalRateResult"
		outputRecordFilename="$iArrival""fig1arrivalRecord"
		/home/wtw/simulation/pomdp/pomdp-solve-5.3/src/pomdp-solve -pomdp ./$filename -stop_criteria bellman -stop_delta 1e-2 -o $outputFilename 
		echo "the $iArrival th test finished."
	done
fi

#/bin/bash
# the running of POMDP
cd /home/wtw/GLOBECOM_SIM
if [$# -eq 0]; then
	echo "Syntax error! please input the number"
else

# test for different arrive rate
for (( iArrival = 1; iArrival <= $1; iArrival ++ ))do
	filename="$iArrival""fig3leaveRate.POMDP"
	outputFilename="$iArrival""fig3leaveRateResult"
	outputRecordFilename="$iArrival""fig3leaveRecord"
	/home/wtw/simulation/pomdp/pomdp-solve-5.3/src/pomdp-solve -pomdp ./$filename -stop_criteria bellman -stop_delta 1e-2 -o $outputFilename
done
fi

#/bin/bash
# the running of POMDP
cd /home/wtw/GLOBECOM_SIM

# test for different arrive rate
for (( iArrival = 1; iArrival <= $1; iArrival ++ ))do
	filename="$iArrival""fig5lightRate.POMDP"
	outputFilename="$iArrival""fig5lightRateResult"
	outputRecordFilename="$iArrival""fig5lightRecord"
	/home/wtw/simulation/pomdp/pomdp-solve-5.3/src/pomdp-solve -pomdp ./$filename -stop_criteria bellman -stop_delta 1e-2 -o $outputFilename
done

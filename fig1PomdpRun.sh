#/bin/bash
# the running of POMDP
cd ./fig1Pomdp

for Rate in {1..8}
do
	filename="$Rate""arrivalRate.POMDP"
	outputFilename="$Rate""arrivalRateResult"
	/home/wtw/simulation/pomdp/pomdp-solve-5.3/src/pomdp-solve -pomdp ./$filename -stop_criteria bellman -stop_delta 1e-2 -o $outputFilename 
done

# test for different arrive rat

#!/bin/bash

dbroot=$1
app=".png"
test=${dbroot}/*${app}
filelist=`ls $test`
for fpng in $filelist
do
	test="$fpng $app"
	fname=`basename $test`
	fjpg=${dbroot}/$fname".jpg"
    feps=${dbroot}/$fname".eps"
	# echo $fpng $fjpg $feps
	convert $fpng $fjpg
	convert $fjpg eps2:$feps
	
done;
	

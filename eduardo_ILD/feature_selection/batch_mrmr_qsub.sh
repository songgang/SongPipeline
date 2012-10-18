#!/bin/bash
# 
# try parameters on mrmr+svm
# bash batch_mrmr_qsub.sh 0.4 0.1 1 1e-3 /mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/mrmr_tmp

# % mrmr_threshold_value = 0.494;
# % job_id = 'mrmr-1';

echo T1=$1
echo INC=$2
echo T2=$3
echo L=$4
echo data_path=$5

CURDIR=`pwd`
# CURDIR=/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script


T1=$1
INC=$2
T2=$3
L=$4
data_path=$5
MATLAB_EXEC=/home/local/matlab_r2007a/bin/matlab

echo  "thres=$1; job_id='test' \""

j=1
for thres in $(seq $T1 $INC $T2)
do
  let j=$j+1
  job_id="thres-$j"
  echo
  echo "thres=$thres lambda=$L job_id=$job_id"
  echo "data_path=$data_path"

  
  echo qsub -b y -j N $job_id $MATLAB_EXEC -nojvm -nosplash -nodisplay -r "\"cd $CURDIR; startup; mrmr_threshold_value=$thres; job_id='$job_id'; lambda=$L; data_path='$data_path', script_mrmr_svm_leave_one_out_qsub; exit;\""
done





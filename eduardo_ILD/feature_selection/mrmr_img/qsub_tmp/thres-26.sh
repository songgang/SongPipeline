#!\bin\bash

/home/local/matlab_r2007a/bin/matlab -nojvm -nosplash -nodisplay -r "cd /home/songgang/project/ATCases/script; startup; mrmr_threshold_value=0.54; job_id='thres-26'; lambda=1e-3; data_path='/home/songgang/project/ATCases/script/mrmr_tmp', script_mrmr_svm_leave_one_out_qsub; exit;"

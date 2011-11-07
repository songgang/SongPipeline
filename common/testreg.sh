#!/bin/bash
#$ -S /bin/bash

# input


fixImage=/home/songgang/project/KobeLung/data/input/0004/Series0008/0004_Series0008.nii.gz
movImage=/home/songgang/project/KobeLung/data/input/0004/Series0014/0004_Series0014.nii.gz
fixMask=/home/songgang/project/KobeLung/data/output/0004/0004_Series0008-whole-lung-mask.nii.gz
movMask=/home/songgang/project/KobeLung/data/output/0004/0004_Series0014-whole-lung-mask.nii.gz

# output
outputPre=/home/songgang/project/KobeLung/data/output/0004/0004_Series0014_regto_Series0008

source /home/songgang/project/KobeLung/script/SongPipeline/common/lung_registration_with_mask.sh $fixImage $movImage $fixMask $movMask $outputPre


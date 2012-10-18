#!/bin/bash
# output file is eduardo.tar in the current directory

DBROOT=/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases
A='*'

OLDDIR=`pwd`

cd $DBROOT

tar -cvf eduardo.tar \
    Dec_06_2008/$A/reg_*/fixed_resampled.nii.gz \
    Dec_06_2008/$A/reg_*/moving_resampled.nii.gz \
    Dec_06_2008/$A/reg2_*/moving_resampled_warped.nii.gz \
    Dec_06_2008/$A/reg2_*/dynamic-*_resampled.nii.gz \
    Dec_06_2008/$A/reg2_*/fixed_airway_resampled_dilated.nii.gz \
    Dec_06_2008/$A/reg2_*/fixed_airway_resampled.nii.gz \
    Dec_06_2008/$A/reg2_*/fixed_vessel_resampled_dilated.nii.gz \
    Dec_06_2008/$A/reg2_*/fixed_vessel_resampled.nii.gz \
    Dec_06_2008/$A/reg2_*/nonsevere_resampled.nii.gz \
    Dec_06_2008/$A/reg2_*/severe_resampled.nii.gz \
    Dec_06_2008/$A/reg2_*/aeroted_mask_resampled.nii.gz \
    Dec_06_2008/$A/reg2_*/diff_resampled_median.nii.gz

cd $OLDDIR

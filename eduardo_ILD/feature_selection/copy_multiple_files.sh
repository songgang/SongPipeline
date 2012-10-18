#!/bin/bash
# list multiple files and backup them to another directory

DBROOT=/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases
A='9*'

OLDDIR=`pwd`

cd $DBROOT

ALLSRC=`find \
    $DBROOT/Dec_06_2008/$A/reg_*/fixed_resampled.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg_*/moving_resampled.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg2_*/moving_resampled_warped.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg2_*/dynamic-*_resampled.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg2_*/fixed_airway_resampled_dilated.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg2_*/fixed_airway_resampled.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg2_*/fixed_vessel_resampled_dilated.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg2_*/fixed_vessel_resampled.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg2_*/nonsevere_resampled.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg2_*/severe_resampled.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg2_*/aeroted_mask_resampled.nii.gz \
    $DBROOT/Dec_06_2008/$A/reg2_*/diff_resampled_median.nii.gz`
    
for word in $ALLSRC
do
	echo "[$word]"
done	    

cd $OLDDIR

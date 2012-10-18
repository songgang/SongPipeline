#!/bin/bash

##
# This script performs the following operations:
#   1. registers (using ANTS) $1-fixed to $2-moving
#   2. calculates the principal strain magnitude images
#   3. calculates the jacobian determinant image
# 
# DO NOT WRITE # $ and together
##

FIXEDIMAGE=$1
MOVINGIMAGE=$2
RESDIR=$3
FIXEDMASKIMAGE=$4

ANTSDIR=/mnt/data1/tustison/PICSL/ANTS/bin64
BINDIR=/mnt/data1/tustison/Utilities/bin64

# DO=echo
DO=myecho
EDO=emptyecho


function checkfile
{
    local myfile=$1
    if [ ! -f $myfile ]
    then
        echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        echo $myfile 'DOES NOT EXIST!!!'
        echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    exit
    fi
}

MYDO(){
# echo "-------------------------------------------------"
# echo $*
# echo "-------------------------------------------------"
 $*
# echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
}

function myecho
{
    echo
    echo $*
    # time $1
    $*
}

tic(){
START=$(date +%s)
}

toc(){
# START=$(date +%s)
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
}

function myecho
{
    # echo
    # echo "$*"
    # time $1
    # $1
    $*
}

function emptyecho
{
    # echo
    # echo $*
    # time $1
    # $1
    # $*
    echo $1
}

 checkfile $FIXEDIMAGE
 checkfile $MOVINGIMAGE
 checkfile $FIXEDMASKIMAGE

 echo "have all needed files"
 

tic

# MYDO $BINDIR/ResampleImage 3 \
#  $FIXEDIMAGE \
#  $RESDIR/fixed_resampled.nii.gz \
#  256x256x256 1 0

# MYDO $BINDIR/ResampleImage 3 \
#  $MOVINGIMAGE \
#  $RESDIR/moving_resampled.nii.gz \
#  256x256x256 1 0

# MYDO $BINDIR/ResampleImage 3 \
#  $FIXEDMASKIMAGE \
#  $RESDIR/mask_resampled.nii.gz \
#  256x256x256 1 1

# MYDO $BINDIR/ThresholdImage 3 \
#  $RESDIR/mask_resampled.nii.gz \
#  $RESDIR/mask_resampled.nii.gz \
#  2 4 1 0

 MYDO $ANTSDIR/ANTS 3 -o $RESDIR/ants.nii.gz \
  -i 200x75x25x5 \
  -m PR[$RESDIR/fixed_resampled.nii.gz,$RESDIR/moving_resampled.nii.gz,1,5] \
  -r Gauss[3,0.5] \
  -t SyN[1]
#  --number-of-affine-iterations 0

 
 MYDO $ANTSDIR/ComposeMultiTransform 3 \
  $RESDIR/totalWarp.nii.gz \
  -R $RESDIR/fixed_resampled.nii.gz \
  $RESDIR/antsWarp.nii.gz \
  $RESDIR/antsAffine.txt
  
 MYDO $BINDIR/CreatePrincipalStrainImages 3 \
  $RESDIR/totalWarp.nii.gz \
  $RESDIR/totalWarpPS \
  1 $RESDIR/mask_resampled.nii.gz 

MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 \
  $RESDIR/totalWarpPS1.nii.gz \
  $RESDIR/mask_resampled.nii.gz \
  1 100 > $RESDIR/principalStrains1Statistics.txt

MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 \
  $RESDIR/totalWarpPS2.nii.gz \
  $RESDIR/mask_resampled.nii.gz \
  1 100 > $RESDIR/principalStrains2Statistics.txt

MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 \
  $RESDIR/totalWarpPS3.nii.gz \
  $RESDIR/mask_resampled.nii.gz \
  1 100 > $RESDIR/principalStrains3Statistics.txt

MYDO $ANTSDIR/CreateJacobianDeterminantImage 3 \
  $RESDIR/totalWarp.nii.gz \
  $RESDIR/totalJacobian.nii.gz 0

MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 \
  $RESDIR/totalJacobian.nii.gz \
  $RESDIR/mask_resampled.nii.gz \
  1 100 > $RESDIR/jacobianStatistics.txt

toc

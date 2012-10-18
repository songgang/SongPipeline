#!/bin/bash

##
# This script performs the following operations:
#   1. registers (using ANTS) $1-fixed to $2-moving
#   2. calculates the principal strain magnitude images
#   3. calculates the jacobian determinant image
##

FIXEDIMAGE=$1
MOVINGIMAGE=$2
RESDIR=$3
FIXEDMASKIMAGE=$4

ANTSDIR=/mnt/data1/tustison/PICSL/ANTS/bin64
BINDIR=/mnt/data1/tustison/Utilities/bin64

# DO=echo
DO=myecho

function myecho
{
    # echo
    echo $*
    # time $1
    # $1
    # $*
}


$DO $BINDIR/ResampleImage 3 \
  $FIXEDIMAGE \
  $RESDIR/fixed_resampled.nii.gz \
  256x256x256 1 0

$DO $BINDIR/ResampleImage 3 \
  $MOVINGIMAGE \
  $RESDIR/moving_resampled.nii.gz \
  256x256x256 1 0

$DO $BINDIR/ResampleImage 3 \
  $FIXEDMASKIMAGE \
  $RESDIR/mask_resampled.nii.gz \
  256x256x256 1 1

$DO $BINDIR/ThresholdImage 3 \
  $RESDIR/mask_resampled.nii.gz \
  $RESDIR/mask_resampled.nii.gz \
  2 3 1 0

$DO $ANTSDIR/ANTS 3 -o $RESDIR/ants.nii.gz \
  -i 100x40x20x5 \
  -m PR[$RESDIR/fixed_resampled.nii.gz,$RESDIR/moving_resampled.nii.gz,1,5] \
  -r Gauss[3,0.5] \
  -t SyN[1]

# $DO $ANTSDIR/ANTS 3 -o $RESDIR/ants.nii.gz \
#  -i 0 \
#  -m PR[$RESDIR/fixed_resampled.nii.gz,$RESDIR/moving_resampled.nii.gz,1,5] \
#  -r Gauss[3,0.5] \
#  -t SyN[1] \
#  --number-of-affine-iterations 0
 

  

#!/bash

##
# updated: 2009 / Oct / 9
# created airway mask: XXX_airways.nii.gz in reg2/exp2insp and need to exclude airway from
#   lung regions.
#   needs: $OLDRESDIR/mask_resampled.nii.gz  -multiply $OLDRESDIR/fixed_resampled.nii.gz
#
# This script performs the following operations:
#  from the inspiration image, get segmentation mask of 
#   1. non-aerated area ( threshold > 0 HU ?)
#   2. emphysema area or non-emphysema with severe air trapping ( threshold < -910 )
#  from the registration field
#   4. compute warped expiration image
#	5. compute the differencing image of inspiration to the warped expiration
#     5.1 use Median filter to smooth out the image
#   6. dynamic air trapping ( try various thrsholds on the differencing image)
#  compute the volume of
#   aerated v0 = #1 (the whole lung should be computed, v0 should be whole lung - vessle only )
#   emphysema v1 = #2 in #1
#   dynamic_air_trapping v2 = #6 in (!#2 in #1)
#   total_air_trapping v3 = v1 + v2
# 
#   for matlab
#   correlation v1, v2, v3 / v0 with PFT 


# DO NOT WRITE # $ and together
##

FIXEDIMAGE=$1
MOVINGIMAGE=$2
RESDIR=$3
FIXEDMASKIMAGE=$4
MOVINGMASKIMAGE=$5
AIRWAYMASK=$6
AIRWAYMASKDIR=$7
OLDRESDIR=$8

ANTSDIR=/mnt/data1/tustison/PICSL/ANTS/bin64
BINDIR=/mnt/data1/tustison/Utilities/bin64
C3D=/mnt/aibs1/songgang/pkg/bin/c3d
#C3D=/mnt/aibs1/songgang/project/c3d/gccrel-x32/c3d
MEDFILTER=/mnt/aibs1/songgang/project/imgfea/gccrel-x64nothread/MedianFilter
IMDILATE=/mnt/aibs1/songgang/cis537/myutil/gccrel/imdilate

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
# checkfile $FIXEDMASKIMAGE
# checkfile $MOVINGMASKIMAGE
 checkfile $AIRWAYMASKDIR/$AIRWAYMASK
# checkfile $RESDIR/antsAffine.txt
 checkfile $OLDRESDIR/mask_resampled.nii.gz

 echo "have all needed files"
 
tic
 
#   1. non-aerated area ( threshold > 0 HU ?)

# MYDO $BINDIR/ResampleImage 3 \
#  $FIXEDMASKIMAGE \
#  $RESDIR/mask_resampled2.nii.gz \
#  256x256x256 1 1

# MYDO $BINDIR/ThresholdImage 3 \
#  $RESDIR/mask_resampled2.nii.gz \
#  $RESDIR/mask_resampled2.nii.gz \
#  2 3 1 0

# MYDO $BINDIR/ResampleImage 3 \
#  $FIXEDIMAGE \
#  $RESDIR/fixednn_resampled.nii.gz \
#  256x256x256 1 1

# MYDO $C3D $OLDRESDIR/fixed_resampled.nii.gz -threshold -Inf -50 1 0 $OLDRESDIR/mask_resampled.nii.gz -multiply -o $RESDIR/aeroted_mask_resampled1.nii.gz
MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/aeroted_mask_resampled.nii.gz > $RESDIR/res"-aeroted-Volume.txt"
# rm $RESDIR/aeroted_mask_resampled1.nii.gz


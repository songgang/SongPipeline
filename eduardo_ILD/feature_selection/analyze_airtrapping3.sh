#$ -S /bin/bash

## analyze_airtrapping3.sh
# updated: 2010 Aug 16
# use dilate 1 voxel in airway mask



## analyze_airtrapping2.sh
# updated: 2010 Aug 13
# clean up the way to compute the lung volume
# use lung segmentation mask(from nick's program, or simply use thresholding) - airway - vessel
# for both insp and exp
# btw, change the emphysema volume from -960 to -950




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

ANTSDIR=/home/tustison/build/ANTS/bin
BINDIR=/home/tustison/build/Utilities/bin
C3D=/home/songgang/mnt/pkg/c3d/c3d-0.8.2-Linux-i686/bin/c3d
MEDFILTER=/home/songgang/mnt/project/imgfea/gccrel-x64nothread/MedianFilter
IMDILATE=/home/songgang/mnt/cis537/myutil/gccrel/imdilate


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
echo "-------------------------------------------------"
echo $*
echo "-------------------------------------------------"
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

# MYDO $C3D $RESDIR/fixed_resampled.nii.gz -threshold -Inf -50 1 0 $OLDRESDIR/mask_resampled.nii.gz -multiply -o $RESDIR/aeroted_mask_resampled1.nii.gz
# MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/aeroted_mask_resampled1.nii.gz > $RESDIR/res"-aeroted-Volume.txt"
# rm $RESDIR/aeroted_mask_resampled1.nii.gz

## this block is temporarily commented to test the new emphysema threshold -960
#
# MYDO $C3D $AIRWAYMASKDIR/$AIRWAYMASK -interpolation NearestNeighbor -resample 256x256x256 -o $RESDIR/fixed_airway_resampled.nii.gz
# MYDO $IMDILATE $RESDIR/fixed_airway_resampled.nii.gz 2 $RESDIR/fixed_airway_resampled_dilated.nii.gz
# MYDO $C3D $RESDIR/fixed_airway_resampled_dilated.nii.gz -o $RESDIR/fixed_airway_resampled_dilated.nii.gz
# MYDO $C3D $OLDRESDIR/fixed_resampled.nii.gz -threshold -300 Inf 1 0 -o $RESDIR/fixed_vessel_resampled.nii.gz
# MYDO $IMDILATE $RESDIR/fixed_vessel_resampled.nii.gz 2 $RESDIR/fixed_vessel_resampled_dilated.nii.gz


# MYDO $C3D $OLDRESDIR/mask_resampled.nii.gz $RESDIR/fixed_airway_resampled_dilated.nii.gz -scale -1 -shift 1 -multiply $RESDIR/fixed_vessel_resampled_dilated.nii.gz -scale -1 -shift 1 -multiply $OLDRESDIR/fixed_resampled.nii.gz -threshold -Inf -500 1 0 -multiply -o $RESDIR/aeroted_mask_resampled.nii.gz

# $BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/aeroted_mask_resampled.nii.gz > $RESDIR/res"-aeroted-Volume.txt"

# MYDO $C3D $OLDRESDIR/mask_resampled.nii.gz $RESDIR/fixed_airway_resampled.nii.gz -scale -1 -shift 1 -multiply $RESDIR/fixed_vessel_resampled.nii.gz -scale -1 -shift 1 -multiply $OLDRESDIR/fixed_resampled.nii.gz -threshold -Inf -500 1 0 -multiply -o $RESDIR/aeroted2_mask_resampled.nii.gz

MYDO $C3D $OLDRESDIR/mask_resampled.nii.gz $RESDIR/fixed_airway_resampled.nii.gz -dilate 1 1x1x1vox -scale -1 -shift 1 -multiply $RESDIR/fixed_vessel_resampled.nii.gz -scale -1 -shift 1 -multiply $OLDRESDIR/fixed_resampled.nii.gz -threshold -Inf -300 1 0 -multiply -o $RESDIR/aeroted3_mask_resampled.nii.gz

$BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/aeroted3_mask_resampled.nii.gz > $RESDIR/res"-aeroted3-Volume.txt"



# MYDO $C3D $OLDRESDIR/moving_mask_resampled.nii.gz $RESDIR/moving_airway_resampled_fake_dilated.nii.gz -scale -1 -shift 1 -multiply $RESDIR/moving_vessel_resampled_dilated.nii.gz -scale -1 -shift 1 -multiply $OLDRESDIR/moving_resampled.nii.gz -threshold -Inf -500 1 0 -multiply -o $RESDIR/moving_aeroted_mask_resampled.nii.gz

# $BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/moving_aeroted_mask_resampled.nii.gz > $RESDIR/res"-moving-aeroted-Volume.txt"

MYDO $C3D $OLDRESDIR/moving_mask_resampled.nii.gz $RESDIR/moving_airway_resampled_fake.nii.gz -scale -1 -shift 1 -multiply $RESDIR/moving_vessel_resampled.nii.gz -scale -1 -shift 1 -multiply $OLDRESDIR/moving_resampled.nii.gz -threshold -Inf -300 1 0 -multiply -o $RESDIR/moving_aeroted3_mask_resampled.nii.gz

$BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/moving_aeroted3_mask_resampled.nii.gz > $RESDIR/res"-moving-aeroted3-Volume.txt"


#
## this block is temporarily commented to test the new emphysema threshold -960


	
# MYDO $BINDIR/ResampleImage 3  $MOVINGMASKIMAGE   $RESDIR/moving_mask_resampled.nii.gz  256x256x256 1 1

# MYDO $BINDIR/ThresholdImage 3  $RESDIR/moving_mask_resampled.nii.gz $RESDIR/moving_mask_resampled.nii.gz 2 3 1 0

# MYDO $C3D $RESDIR/moving_resampled.nii.gz -threshold -Inf -50 1 0 $RESDIR/moving_mask_resampled.nii.gz -multiply -o $RESDIR/aeroted_moving_mask_resampled.nii.gz
	
# MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/aeroted_moving_mask_resampled.nii.gz > $RESDIR/res"-moving-aeroted-Volume.txt"
 echo here

#   2. emphysema area or non-emphysema with severe air trapping ( threshold < -910 )
MYDO $C3D $OLDRESDIR/fixed_resampled.nii.gz -threshold -Inf -950 1 0 $RESDIR/aeroted_mask_resampled.nii.gz -multiply -o $RESDIR/severe_resampled.nii.gz
$BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/severe_resampled.nii.gz >  $RESDIR/res"-severe-Volume.txt"

#   4. compute warped expiration image
#	5. compute the differencing image of inspiration to the warped expiration
#   6. dynamic air trapping ( try various thrsholds on the differencing image)

# MYDO $ANTSDIR/WarpImageMultiTransform 3 $RESDIR/moving_resampled.nii.gz $RESDIR/moving_resampled_warped.nii.gz -R $RESDIR/fixed_resampled.nii.gz $RESDIR/ants2Warp.nii.gz $RESDIR/ants2Affine.txt
# MYDO $C3D $RESDIR/fixed_resampled.nii.gz -scale -1 $RESDIR/moving_resampled_warped.nii.gz -add -o $RESDIR/diff_resampled.nii.gz
# MYDO $MEDFILTER $RESDIR/diff_resampled.nii.gz $RESDIR/diff_resampled_median.nii.gz 2.0

MYDO $C3D $RESDIR/aeroted_mask_resampled.nii.gz $RESDIR/severe_resampled.nii.gz -scale -1 -add -o $RESDIR/nonsevere_resampled.nii.gz

# dynamic_threshold_list=(5 25 50 75 100 125 150 175 200 225 250 275 300)

# num_threshold=${#dynamic_threshold_list[*]}
# for ((i=0; i < num_threshold; i++))
# do
#    T=${dynamic_threshold_list[i]}
    
#    MYDO $C3D $RESDIR/diff_resampled_median.nii.gz -threshold 0 $T 1 0 $RESDIR/nonsevere_resampled.nii.gz -multiply -o $RESDIR/dynamic"-"$T"_resampled.nii.gz"
#	MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $RESDIR/dynamic"-"$T"_resampled.nii.gz" > $RESDIR/res-dynamic"-"$T"-Median-Volume.txt" 
#    MYDO $RESDIR/dynamic"-"$T"_resampled.nii.gz"

# done 	
 




toc

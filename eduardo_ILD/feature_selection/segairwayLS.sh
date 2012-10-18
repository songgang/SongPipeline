#!/bin/bash
#
#
#

INPUTIMAGE=$1
RESDIR=$2
AIRWAYMASK=$3
LUNGNAME=$4

OUTPUTPREFIX=$2/$4

C3D=/home/songgang/mnt/pkg/bin/c3d
EXECDIR=/home/songgang/mnt/project/segtree/gccrel-itkcvs

MYDO(){
echo "-------------------------------------------------"
echo $*
echo "-------------------------------------------------"
$*
echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
}


LUNGMASK=${OUTPUTPREFIX}_lungs.nii.gz
# AIRWAYMASK=${OUTPUTPREFIX}_airways.nii.gz
SEPARATEMASK=${OUTPUTPREFIX}_separate.nii.gz
# instead of naming the final output here, use the input parameter
# SMOOTHMASK=${OUTPUTPREFIX}_smooth.nii.gz
SMOOTHMASK=$FINALMASK 

# THRESHIMAGE=${OUTPUTPREFIX}_threshold.nii.gz
# TMPIMAGE=${OUTPUTPREFIX}_tmp.nii.gz
TMPIMAGE=$INPUTIMAGE

UTILITIESDIR=/mnt/data1/tustison/Utilities/bin64

# load the seed point
SEEDFILE=$RESDIR"/airway_seed.txt"
SEED=`cat $SEEDFILE` 


MYDO $EXECDIR/Medial 3 $INPUTIMAGE -LS -gradient_sigma 0.1 -speed_beta 0.05 -stop_time 1000 -seed_index '['$SEED']' -freezing_intensity -900 -debug_file_prefix $RESDIR/$LUNGNAME

MYDO $C3D  $RESDIR/$LUNGNAME"_time.nii.gz" -threshold [0 1500 1 0] $RESDIR/$LUNGNAME"_time.nii.gz" -multiply  $RESDIR/$LUNGNAME"_time.nii.gz" -threshold [0 1500 0 1] -scale 1500 -add -o $RESDIR/$LUNGNAME"_time.nii.gz"

MYDO $C3D $RESDIR/$LUNGNAME"_time.nii.gz" -threshold [0 240 1 0] -o $AIRWAYMASK

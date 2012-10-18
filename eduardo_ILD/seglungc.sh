#!/bin/bash
#$ -S /bin/bash

#
#
#

INPUTIMAGE=$1
RESDIR=$2
FINALMASK=$3
LUNGNAME=$4

OUTPUTPREFIX=$2/$4

MYDO(){
# echo "-------------------------------------------------"
# echo $*
# echo "-------------------------------------------------"
$*
echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
}

echo Segment lung ...

#C3D=/home/songgang/mnt/pkg/c3d/c3d-0.8.2-Linux-x86_64/bin/c3d
C3D=/home/songgang/pkg/bin/c3d
# UTILITIESDIR=/home/tustison/build/Utilities/bin
UTILITIESDIR=/home/tustison/Utilities/bin64


TMPIMAGE=${OUTPUTPREFIX}_halfsize.nii.gz
LUNGMASK=${OUTPUTPREFIX}_halfsize_lungs.nii.gz
AIRWAYMASK=${OUTPUTPREFIX}_halfsize_airways.nii.gz
SEPARATEMASK=${OUTPUTPREFIX}_halfsize_separate.nii.gz
SMOOTHMASK=${OUTPUTPREFIX}_halfsize_smooth.nii.gz

MYDO $C3D $INPUTIMAGE -interpolation Linear -resample 50% -o $TMPIMAGE

MYDO ${UTILITIESDIR}/ExtractLungs $TMPIMAGE $LUNGMASK 
MYDO ${UTILITIESDIR}/SegmentAirways $TMPIMAGE $LUNGMASK $AIRWAYMASK
MYDO ${UTILITIESDIR}/SeparateLungs $TMPIMAGE $AIRWAYMASK $SEPARATEMASK
MYDO ${UTILITIESDIR}/SmoothLungs $SEPARATEMASK $SMOOTHMASK 15

atmp=`$C3D $INPUTIMAGE -info`
btmp=`echo $atmp | awk '{sub(/\[/, ""); sub(/\]/,""); sub(/\,/,""); sub(/\,/, ""); sub(/\;/,""); print $5"x"$6"x"$7}'`
MYDO $C3D $SMOOTHMASK -interpolation NearestNeighbor -resample $btmp -o $FINALMASK
${UTILITIESDIR}/ChangeImageInformation 3 $FINALMASK $FINALMASK 4 $INPUTIMAGE


# remove the vessels from the
echo Removing vessels ...
 
VesselLowerThres=-50 # need to confirm this with Eduardo! 
MYDO $C3D $INPUTIMAGE -threshold $VesselLowerThres Inf 1 0 $FINALMASK -as M -multiply -threshold 2 3 1 0 -as V -scale 5 -push V -scale -1 -shift 1 -push M -times -add -o $FINALMASK 





MYDO ln -s $INPUTIMAGE $2/$4.nii.gz

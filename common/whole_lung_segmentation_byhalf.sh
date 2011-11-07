#!/bin/bash
#$ -S /bin/bash

# segmentation of whole lung
#
#

# inputs
INPUTIMAGE=$1

# outputs
OUTPUTLABEL=$2

# paths for all binary utilities
C3D=/home/songgang/pkg/bin/c3d
UTILITIESDIR=/home/songgang/project/tustison/Utilities/gccrel

# default temp working directory in the sub directory
# of output label file
TEMPROOT=`dirname $OUTPUTLABEL`
IMAGENAME=`basename $INPUTIMAGE` # ${INPUTIMAGE##*/}
IMAGENAME=${IMAGENAME%%.*}
TEMPDIR=${TEMPROOT}/${IMAGENAME}-whole-lung-seg-tmp

echo TEMPROOT $TEMPROOT
echo IMAGENAME $IMAGENAME
echo TEMPDIR $TEMPDIR
if [ ! -d $TEMPDIR ]; then mkdir -p $TEMPDIR; fi

# main routine starts here
MYDO()
{
 echo "-------------------------------------------------"
 echo $*
 echo "-------------------------------------------------"
 $*
echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
}

echo Segment lung ...

InputLung=$INPUTIMAGE
HalfInputLung=$TEMPDIR/${IMAGENAME}-halfsize.nii.gz
FirstRoundLungMask=$TEMPDIR/${IMAGENAME}-first-round-lung-mask.nii.gz
AirwayMask=$TEMPDIR/${IMAGENAME}-halfsize-airways.nii.gz
LobeDivisionMask=$TEMPDIR/${IMAGENAME}-halfsize-lobe-division.nii.gz
SmoothLobeDivisionMask=$TEMPDIR/${IMAGENAME}-halfsize-smooth-lobe-division.nii.gz
TmpOutputLabel=$TEMPDIR/${IMAGENAME}-smooth-lobe-division.nii.gz


echo 0
MYDO $C3D $InputLung -interpolation Linear -resample 50% -o $HalfInputLung
echo 1
MYDO ${UTILITIESDIR}/ExtractLungs $HalfInputLung $FirstRoundLungMask
echo 2
MYDO ${UTILITIESDIR}/SegmentAirways $HalfInputLung $FirstRoundLungMask $AirwayMask
echo 3
MYDO ${UTILITIESDIR}/SeparateLungs $HalfInputLung $AirwayMask $LobeDivisionMask
echo 4
MYDO ${UTILITIESDIR}/SmoothLungs $LobeDivisionMask $SmoothLobeDivisionMask 15
echo 5
atmp=`$C3D $InputLung -info`
btmp=`echo $atmp | awk '{sub(/\[/, ""); sub(/\]/,""); sub(/\,/,""); sub(/\,/, ""); sub(/\;/,""); print $5"x"$6"x"$7}'`
MYDO $C3D $SmoothLobeDivisionMask -interpolation NearestNeighbor -resample $btmp -o $TmpOutputLabel
MYDO ${UTILITIESDIR}/ChangeImageInformation 3 $TmpOutputLabel $TmpOutputLabel 4 $InputLung
MYDO $C3D $TmpOutputLabel -threshold 2 Inf 1 0 -o $OUTPUTLABEL



# remove the vessels from the
# echo Removing vessels ...
#
#VesselLowerThres=-50 # need to confirm this with Eduardo! 
#MYDO $C3D $INPUTIMAGE -threshold $VesselLowerThres Inf 1 0 $FINALMASK -as M -multiply -threshold 2 3 1 0 -as V -scale 5 -push V -scale -1 -shift 1 -push M -times -add -o $FINALMASK 


#MYDO ln -fs $INPUTIMAGE $2/$4.nii.gz


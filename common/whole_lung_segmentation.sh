#$ -S /bin/bash
#!/bin/bash

# segmentation of whole lung

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

if [ ! -d $TEMPDIR ]; then
  mkdir -p $TEMPDIR
fi


# main routine starts here
MYDO(){
 echo "-------------------------------------------------"
 echo $*
 echo "-------------------------------------------------"
 $*
echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
}


# four steps to segmentation whole lung
InputLung=$INPUTIMAGE
FirstRoundLungMask=$TEMPDIR/${IMAGENAME}-first-round-lung-mask.nii.gz
AirwayMask=$TEMPDIR/${IMAGENAME}-airway.nii.gz
LobeDivisionMask=$TEMPDIR/${IMAGENAME}-lobe-division.nii.gz
SmoothLobeDivisionMask=$TEMPDIR/${IMAGENAME}-smooth-lobe-division.nii.gz

# using only the first step and the last smooth step
# output a binary lung mask (original label==2)
echo 1
# MYDO ${UTILITIESDIR}/ExtractLungs $InputLung $FirstRoundLungMask
echo 4
# MYDO ${UTILITIESDIR}/SmoothLungs $FirstRoundLungMask $SmoothLobeDivisionMask 15
echo 5
# MYDO cp $FirstRoundLungMask $OUTPUTLABEL
MYDO $C3D $SmoothLobeDivisionMask -threshold 2 2 1 0 -o $OUTPUTLABEL
if [ 1 ]; then
echo "this command only for displaying"
echo rm $FirstRoundLungMask
fi

# skip all the four steps temporarily 
:<<ajfadksfjadfjadsfjdska
echo 1
MYDO ${UTILITIESDIR}/ExtractLungs $InputLung $FirstRoundLungMask
echo 2
MYDO ${UTILITIESDIR}/SegmentAirways $InputLung $FirstRoundLungMask $AirwayMask
echo 3
MYDO ${UTILITIESDIR}/SeparateLungs $InputLung $AirwayMask $LobeDivisionMask
echo 4
MYDO ${UTILITIESDIR}/SmoothLungs $LobeDivisionMask $SmoothLobeDivisionMask 15
echo 5
MYDO cp $SmoothLobeDivisionMask $OUTPUTLABEL
if [ 1 ]; then
echo haha
echo rm $FirstRoundLungMask $AirwayMask $LobeDivisionMask $SmoothLobeDivisionMask
fi
ajfadksfjadfjadsfjdska

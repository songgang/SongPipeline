#!/bin/bash
#$ -S /bin/bash


# convert the deformation field in the vtk format
# input
#   fixImage
#   fixMask
# output is the default paraview directory

ORIGFIXEDIMAGE=$1

# output is the default paraview directory

function ConvertDeformationToVTK
{
  # for Cuneyt's pipeline
  # convert the defomration field to vtk of vectors
  ORIGFIXEDIMAGE=$1

  fixImageName=$(basename $ORIGFIXEDIMAGE)
  fixImageName=${fixImageName%%.*}
  echo $fixImageName
  dog=$( perl -e '@a=split("-", "'$fixImageName'");print @a[0]');
  timing=$( perl -e '@a=split("-", "'$fixImageName'");print @a[1]');
  pos=$( perl -e '@a=split("-", "'$fixImageName'");print @a[2]');
  pressure=$( perl -e '@a=split("-", "'$fixImageName'");print @a[3]');

#  PVDIR=/home/songgang/project/Cuneyt/Jan2012/output/${dog}-${timing}/${pos}-${pressure}/LobeMasks/ParaviewFiles
  PVDIR=/home/songgang/project/Cuneyt/Jan2012/output/${dog}-${timing}/${pos}-fix-30cm-mov-10cm/LobeMasks/ParaviewFiles 
  mkdir -p $PVDIR

  C3D=/home/songgang/pkg/bin/c3d

  AVANTS=/home/songgang/project/tustison/Utilities/gccrel/ConvertDeformationFieldToAvantsLandmarkFiles
  # this version is for xvec/yvec/zvec format files
  # AVANTS=/home/tustison/Utilities/bin64/ConvertDeformationFieldToAvantsLandmarkFiles
  AVANTS2=/home/tustison/Utilities/bin64/ConvertAvantsLandmarkFileToVTK

  TOTALVECTORFIELD=/home/songgang/project/Cuneyt/Jan2012/output/${dog}-${timing}/${pos}-fix-30cm-mov-10cm/${dog}-${timing}-${pos}-fix-30cm-mov-10cmTotalWarp.nii.gz

  FIXEDMASK=/home/songgang/project/Cuneyt/Jan2012/output/${dog}-${timing}/${pos}-${pressure}/${dog}-${timing}-${pos}-${pressure}-lungmask.nii.gz

  


  # input will be the deformation field and the masks
  if [ ! -f $TOTALVECTORFIELD ];
  then
    echo -e "$TOTALVECTORFIELD : not existed!!"
        exit;
  fi;

  if [ ! -f $FIXEDMASK ];
  then
    echo -e "$FIXEDMASK: not existed!!";
        exit;
  fi;



  # temporarily disabled
# $AVANTS 3 $TOTALVECTORFIELD ${PVDIR}/${dog}-${timing}-${pos}-TotalWarp 1 $FIXEDMASK
# $AVANTS2 ${PVDIR}/${dog}-${timing}-${pos}-TotalWarpFixed.txt ${PVDIR}/${dog}-${timing}-${pos}-TotalWarpMoving.txt ${PVDIR}/${dog}-${timing}-${pos}-TotalWarp 2
#/bin/gzip ${PVDIR}/${dog}-${timing}-${pos}-TotalWarpFixed.txt
#/bin/gzip ${PVDIR}/${dog}-${timing}-${pos}-TotalWarpMoving.txt
#/bin/gzip ${PVDIR}/${dog}-${timing}-${pos}-TotalWarpFixed.vtk
#/bin/gzip ${PVDIR}/${dog}-${timing}-${pos}-TotalWarpMoving.vtk

# recomputing principle vector field in the same directory of total vector field
NICKPS=/home/songgang/project/tustison/Utilities/gccrel/CreatePrincipalStrainImages
PSVECOUTPUTPRE=/home/songgang/project/Cuneyt/Jan2012/output/${dog}-${timing}/${pos}-fix-30cm-mov-10cm/${dog}-${timing}-${pos}-fix-30cm-mov-10cm_PSvec
PS1VECTORFIELD=${PSVECOUTPUTPRE}1.nii.gz

PSMAGOUTPUTPRE=/home/songgang/project/Cuneyt/Jan2012/output/${dog}-${timing}/${pos}-fix-30cm-mov-10cm/${dog}-${timing}-${pos}-fix-30cm-mov-10cm_PS

SMOOTHTOTALVECTORFIELD=/home/songgang/project/Cuneyt/Jan2012/output/${dog}-${timing}/${pos}-fix-30cm-mov-10cm/${dog}-${timing}-${pos}-fix-30cm-mov-10cmTotalWarp-smooth.nii.gz

# the strain computation is sensitive to noise (needs to compute gradient) adds extra smoothing here
  
/home/songgang/pkg/bin/c3d -mcs $TOTALVECTORFIELD -foreach -smooth 20vox -endfor -omc 3 $SMOOTHTOTALVECTORFIELD

# recompute the ps1 eigenvalues since deformation were not smoothed before
$NICKPS 3 $SMOOTHTOTALVECTORFIELD $PSMAGOUTPUTPRE 1 $FIXEDMASK

$NICKPS 3 $SMOOTHTOTALVECTORFIELD $PSVECOUTPUTPRE 0 $FIXEDMASK
# not needed any more, have changed Nick's code
# change the image header since PS1 from Nick's output is different from the original input
# $C3D $FIXEDMASK $PS1VECTORFIELD -copy-transform -o $PS1VECTORFIELD

$AVANTS 3 $PS1VECTORFIELD ${PVDIR}/${dog}-${timing}-${pos}-PS1 1 $FIXEDMASK
$AVANTS2 ${PVDIR}/${dog}-${timing}-${pos}-PS1Fixed.txt ${PVDIR}/${dog}-${timing}-${pos}-PS1Moving.txt ${PVDIR}/${dog}-${timing}-${pos}-PS1 2
# zip the files
/bin/gzip -f ${PVDIR}/${dog}-${timing}-${pos}-PS1Fixed.txt
/bin/gzip -f ${PVDIR}/${dog}-${timing}-${pos}-PS1Moving.txt
/bin/gzip -f ${PVDIR}/${dog}-${timing}-${pos}-PS1Fixed.vtk
/bin/gzip -f ${PVDIR}/${dog}-${timing}-${pos}-PS1Moving.vtk


}

ConvertDeformationToVTK $ORIGFIXEDIMAGE 



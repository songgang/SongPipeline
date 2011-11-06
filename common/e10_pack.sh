# request Bourne shell as shell for job
#$ -S /bin/sh

# for EMPIRE10
# packing the result to EMPIRE10 format

DIMENSION=3

OUTPUT=$1
ORIGFIXEDIMAGE=$2
SUBMITPRE=$3
SUBMITDIR=$4
ORIGMOVINGIMAGE=$5




ANTSDIRECTORY=/home/songgang/pkg/bin/ANTS/gccrel_itk_mt_test3
COMPOSEWARP=${ANTSDIRECTORY}/ComposeMultiTransform
RENAMING=/home/songgang/project/Empire10/Empire10/Script/mv_rename_mhd.pl
WARPIMAGE=${ANTSDIRECTORY}/WarpImageMultiTransform

AFFINE=${OUTPUT}Affine.txt
VECTORFIELD=${OUTPUT}Warp.nii.gz
TOTALVECTORFIELD=${SUBMITPRE}.mhd

ORIGDEFORMED=${OUTPUT}origdeformed.nii.gz


$COMPOSEWARP $DIMENSION $TOTALVECTORFIELD -R $ORIGFIXEDIMAGE $VECTORFIELD $AFFINE

$WARPIMAGE 3 $ORIGMOVINGIMAGE $ORIGDEFORMED $TOTALVECTORFIELD -R $ORIGFIXEDIMAGE

/usr/bin/perl $RENAMING   ${SUBMITPRE}xvec.mhd ${SUBMITDIR}/defX.mhd;
/usr/bin/perl $RENAMING   ${SUBMITPRE}yvec.mhd ${SUBMITDIR}/defY.mhd;
/usr/bin/perl $RENAMING   ${SUBMITPRE}zvec.mhd ${SUBMITDIR}/defZ.mhd;






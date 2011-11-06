# request Bourne shell as shell for job
#$ -S /bin/sh

# for EMPIRE10
# use padded images to register

ANTSDIRECTORYNICK=/home/tustison/ANTS/bin64
ANTSDIRECTORY=/home/songgang/pkg/bin/ANTS/gccrel_itk_mt_test3
MTANTSDIRECTORY=/home/songgang/project/mANTS/gccrel-mt
UTILITYDIRECTORY=/home/tustison/Utilities/bin64

ANTS=${MTANTSDIRECTORY}/ANTS
WARPIMAGE=${ANTSDIRECTORY}/WarpImageMultiTransform
COMPOSEWARP=${ANTSDIRECTORY}/ComposeMultiTransform
MEASURESIM=${MTANTSDIRECTORY}/MeasureImageSimilarityMT

DIMENSION=3

OUTPUT=$1
AFFINEMETRIC=${2}
ITERATIONS=$3
TRANSFORMATION=$4
REGULARIZATION=$5
IMAGEMETRIC=$6
USERECURSIVEGAUSSIAN=${7}
FIXEDIMAGE=$8
MOVINGIMAGE=$9
AFFINIT=${10}




DEFORMEDIMAGE=${OUTPUT}deformed.nii.gz
VECTORFIELD=${OUTPUT}Warp.nii.gz
AFFINE=${OUTPUT}Affine.txt




echo "---- registering $FIXEDIMAGE (fix) and $MOVINGIMAGE (mov) ----"
echo $ANTS $DIMENSION --output-naming $OUTPUT --image-metric $IMAGEMETRIC --number-of-iterations $ITERATIONS --transformation-model  $TRANSFORMATION --regularization $REGULARIZATION --affine-metric-type MI  --geodesic 2  --initial-affine $AFFINIT --continue-affine false --number-of-threads 8 --use-recursive-gaussian $USERECURSIVEGAUSSIAN > ${OUTPUT}ANTSCall.txt
echo "initial date:" `date` >> ${OUTPUT}ANTSCall.txt
echo
echo initial affine registration
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo Using affine init: $AFFINIT
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo 
echo
echo "after initial affine date:" `date` >> ${OUTPUT}ANTSCall.txt
echo
echo deformable registration
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/usr/bin/time $ANTS $DIMENSION --output-naming $OUTPUT --image-metric $IMAGEMETRIC --number-of-iterations $ITERATIONS --transformation-model  $TRANSFORMATION --regularization $REGULARIZATION --affine-metric-type MI  --geodesic 2  --initial-affine $AFFINIT --continue-affine false --number-of-threads 8 --use-recursive-gaussian $USERECURSIVEGAUSSIAN
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo 
echo
echo "after ANTS date:" `date` >> ${OUTPUT}ANTSCall.txt
$WARPIMAGE $DIMENSION $MOVINGIMAGE $DEFORMEDIMAGE $VECTORFIELD $AFFINE -R $FIXEDIMAGE
$MEASURESIM 3 4 $FIXEDIMAGE $DEFORMEDIMAGE >> ${OUTPUT}ANTSCall.txt


echo "after compute jacobian date:" `date` >> ${OUTPUT}ANTSCall.txt






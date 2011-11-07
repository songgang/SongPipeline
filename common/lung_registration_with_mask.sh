#!/bin/bash
#$ -S /bin/bash

# register a pair of lung images + binary masks
# 1) preprocess, 
#   1.1) normalize the lung images within masks to [0, 1] by linearly streching
#   1.2) pad the preprocessed images
# 2) register image, using Greedy SyN + Cross Correlation
#   2.1) initialize the affine by register the lung masks, using ANTS
#   2.2) deformable registration using ANTS



# input
#  fixImage
#  movImage
#  fixMask
#  movMask
#  iterations
#  radius
# output 
#  warped moving image
#  deformation fields




# input
fixImage=$1
movImage=$2
fixMask=$3
movMask=$4

# output
outputPre=$5


if [ $# -lt 5 ]; then
  echo "Need 5 parameters: fixImage movImage fixMask movMask outputPre"
  exit;
fi

# internal parameters
padRadius=10


# paths for all binary utilities
C3D=/home/songgang/pkg/bin/c3d
UTILITIESDIR=/home/songgang/project/tustison/Utilities/gccrel
# ANTSDIRECTORY=/home/songgang/pkg/bin/ANTS/gccrel_itk_mt_test3
ANTSDIRECTORY=/home/songgang/project/ANTS/gccrel-Nov-06-2011/Examples
# MTANTSDIRECTORY=/home/songgang/project/mANTS/gccrel-mt
# UTILITIESDIR=/home/tustison/Utilities/bin64


# default temp working directory in the sub directory
# of output label file
tempRoot=`dirname $outputPre`
fixImageName=`basename $fixImage`
fixImageName=${fixImageName%%.*} # remove substring from back
movImageName=`basename $movImage`
movImageName=${movImageName%%.*} # remove substring from back
# tempDir=${tempRoot}/${fixImageName}-${movImageName}-reg-tmp
tempDir=${outputPre}-tmp

if [ ! -d $tempDir ]; then
  mkdir -p $tempDir
fi

function MYDO
{
  echo "-------------------------------------------------"
  echo $*
  echo "-------------------------------------------------"
   $*
  echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
}


function preprocess 
{

  DIMENSION=3

  INPUTIMAGE=$1
  MASKIMAGE=$2
  OUTPUTIMAGE=$3
  TEMPDIR=$4

  TEMPPREFIX=`basename $INPUTIMAGE`
  TEMPPREFIX=${TEMPPREFIX%%.*}
  TEMPPREFIX=$TEMPDIR/$TEMPPREFIX

  MYDO $C3D $INPUTIMAGE $MASKIMAGE -times -o $TEMPPREFIX"-preprocess-tmp1.nii.gz"
  MYDO ${UTILITIESDIR}/RescaleImageIntensity 3 $TEMPPREFIX"-preprocess-tmp1.nii.gz" $TEMPPREFIX"-preprocess-tmp2.nii.gz" 0 1
  MYDO $C3D $TEMPPREFIX"-preprocess-tmp2.nii.gz" -scale -1 -shift 1 $MASKIMAGE -times -o $TEMPPREFIX"-preprocess-tmp3.nii.gz"
  MYDO $ANTSDIRECTORY/ImageMath 3 $OUTPUTIMAGE PadImage $TEMPPREFIX"-preprocess-tmp3.nii.gz" $padRadius

  MYDO cp $TEMPPREFIX"-preprocess-tmp3.nii.gz" $OUTPUTIMAGE

  MYDO rm $TEMPPREFIX"-preprocess-tmp3.nii.gz"
  MYDO rm $TEMPPREFIX"-preprocess-tmp2.nii.gz"
  MYDO rm $TEMPPREFIX"-preprocess-tmp1.nii.gz"


}


function register
{

  ANTS=${ANTSDIRECTORY}/ANTS
  WARPIMAGE=${ANTSDIRECTORY}/WarpImageMultiTransform
  COMPOSEWARP=${ANTSDIRECTORY}/ComposeMultiTransform
  # MEASURESIM=${MTANTSDIRECTORY}/MeasureImageSimilarityMT
  WARPIMAGE=${ANTSDIRECTORY}/WarpImageMultiTransform

  DIMENSION=3

  fixProcess=$1
  fixMask=$2
  fixOrig=$3
  movProcess=$4
  movMask=$5
  movOrig=$6
  outputPre=$7
  tempDir=$8

  iterations="200x200x200x200x50"
  # iterations="1x0x0x0x0"
  metricRadius=2
  gradientStep=0.25
  gradientSigma=6.0
  totalFieldSigma=0


  OUTPUT=$outputPre
  AFFINEMETRIC="MSQ[$fixMask,$movMask,1]"
  ITERATIONS=$iterations
  TRANSFORMATION="SyN[$gradientStep]"
  REGULARIZATION="Gauss[$gradientSigma,$totalFieldSigma]"
  IMAGEMETRIC="CC[$fixProcess,$movProcess,1,$metricRadius]"
  USERECURSIVEGAUSSIAN="false"

  FIXEDIMAGE=$fixOrig
  MOVINGIMAGE=$movOrig

  # output filename
  DEFORMEDIMAGE=${OUTPUT}deformed.nii.gz
  VECTORFIELD=${OUTPUT}Warp.nii.gz
  AFFINE=${OUTPUT}Affine.txt

  echo "---- registering"
  echo "fix: $FIXEDIMAGE"
  echo "mov: $MOVINGIMAGE"
  echo "----"
  echo $ANTS $DIMENSION --output-naming ${OUTPUT}initaff --image-metric $AFFINEMETRIC --number-of-iterations 0 --transformation-model $TRANSFORMATION --regularization $REGULARIZATION --affine-metric-type MI --number-of-affine-iterations 10000x10000x10000x10000 > ${OUTPUT}ANTSCall.txt
  echo $ANTS $DIMENSION --output-naming $OUTPUT --image-metric $IMAGEMETRIC --number-of-iterations $ITERATIONS --transformation-model  $TRANSFORMATION --regularization $REGULARIZATION --affine-metric-type MI  --initial-affine ${OUTPUT}initaffAffine.txt --continue-affine false --number-of-threads 8 --use-recursive-gaussian $USERECURSIVEGAUSSIAN >> ${OUTPUT}ANTSCall.txt
  echo "initial date:" `date` >> ${OUTPUT}ANTSCall.txt
  echo
  echo initial affine registration
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MYDO /usr/bin/time $ANTS $DIMENSION --output-naming ${OUTPUT}initaff --image-metric $AFFINEMETRIC --number-of-iterations 0 --transformation-model $TRANSFORMATION --regularization $REGULARIZATION --affine-metric-type MI --number-of-affine-iterations 10000x10000x10000x10000

  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo 
  echo
  echo "after initial affine date:" `date` >> ${OUTPUT}ANTSCall.txt
  echo
  echo deformable registration
  echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MYDO /usr/bin/time $ANTS $DIMENSION --output-naming $OUTPUT --image-metric $IMAGEMETRIC --number-of-iterations $ITERATIONS --transformation-model  $TRANSFORMATION --regularization $REGULARIZATION --affine-metric-type MI --initial-affine ${OUTPUT}initaffAffine.txt --continue-affine false --number-of-threads 8 --use-recursive-gaussian $USERECURSIVEGAUSSIAN

  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo 
  echo
  echo "after ANTS date:" `date` >> ${OUTPUT}ANTSCall.txt

  MYDO $WARPIMAGE $DIMENSION $MOVINGIMAGE $DEFORMEDIMAGE $VECTORFIELD $AFFINE -R $FIXEDIMAGE

}





# step 1: preprocess
# input: $fixImage
# output: $fixImageName"-preprocessed.nii.gz"

fixProcessed=${tempDir}/${fixImageName}-preprocessed.nii.gz
movProcessed=${tempDir}/${movImageName}-preprocessed.nii.gz

# :<<abkadfjadksfjkadsjfv
preprocess $fixImage $fixMask $fixProcessed $tempDir
preprocess $movImage $movMask $movProcessed $tempDir

# abkadfjadksfjkadsjfv

# step 2: registration
# input: 
#  $fixProcessed, $fixMask, $fixImage
#  $movProcessed, $movMask, $movImage
# output:
#  $outputPre
# temp:
#  $tempDir

register $fixProcessed $fixMask $fixImage $movProcessed $movMask $movImage $outputPre $tempDir

# optional step 3: unpad all the deformation field











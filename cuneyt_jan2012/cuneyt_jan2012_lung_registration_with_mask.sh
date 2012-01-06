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
fixLobeMaskDir=$5

# output
outputPre=$6


if [ $# -lt 6 ]; then
  echo "Need 6 parameters: fixImage movImage fixMask movMask fixLobeMaskDir outputPre"
  exit;
fi

# internal parameters
padRadius=10


# paths for all binary utilities
C3D=/home/songgang/pkg/bin/c3d
UTILITIESDIR=/home/songgang/project/tustison/Utilities/gccrel
ANTSDIRECTORY=/home/songgang/project/ANTS/gccrel-Nov-06-2011/Examples


# default temp working directory in the sub directory
# of output label file
tempRoot=`dirname $outputPre`
fixImageName=`basename $fixImage`
fixImageName=${fixImageName%%.*} # remove substring from back
movImageName=`basename $movImage`
movImageName=${movImageName%%.*} # remove substring from back
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


function preprocess()
{

  local DIMENSION=3

  local INPUTIMAGE=$1
  local MASKIMAGE=$2
  local OUTPUTIMAGE=$3
  local TEMPDIR=$4

  local TEMPPREFIX=`basename $INPUTIMAGE`
  local TEMPPREFIX=${TEMPPREFIX%%.*}
  local TEMPPREFIX=$TEMPDIR/$TEMPPREFIX

  MYDO $C3D $INPUTIMAGE $MASKIMAGE -times -o $TEMPPREFIX"-preprocess-tmp1.nii.gz"
  MYDO ${UTILITIESDIR}/RescaleImageIntensity 3 $TEMPPREFIX"-preprocess-tmp1.nii.gz" $TEMPPREFIX"-preprocess-tmp2.nii.gz" 0 1
  MYDO $C3D $TEMPPREFIX"-preprocess-tmp2.nii.gz" -scale -1 -shift 1 $MASKIMAGE -times -o $TEMPPREFIX"-preprocess-tmp3.nii.gz"
  MYDO $ANTSDIRECTORY/ImageMath 3 $OUTPUTIMAGE PadImage $TEMPPREFIX"-preprocess-tmp3.nii.gz" $padRadius

  MYDO cp $TEMPPREFIX"-preprocess-tmp3.nii.gz" $OUTPUTIMAGE

  MYDO rm $TEMPPREFIX"-preprocess-tmp3.nii.gz"
  MYDO rm $TEMPPREFIX"-preprocess-tmp2.nii.gz"
  MYDO rm $TEMPPREFIX"-preprocess-tmp1.nii.gz"


}


function register()
{

  local ANTS=${ANTSDIRECTORY}/ANTS
  local WARPIMAGE=${ANTSDIRECTORY}/WarpImageMultiTransform
  local COMPOSEWARP=${ANTSDIRECTORY}/ComposeMultiTransform
  # local MMEASURESIM=${MTANTSDIRECTORY}/MeasureImageSimilarityMT
  local WARPIMAGE=${ANTSDIRECTORY}/WarpImageMultiTransform

  local DIMENSION=3

  local fixProcess=$1
  local fixMask=$2
  local fixOrig=$3
  local movProcess=$4
  local movMask=$5
  local movOrig=$6
  local outputPre=$7
  local tempDir=$8

  local iterations="200x200x200x200x50"
  # local Miterations="1x0x0x0x0"
  local metricRadius=2
  local gradientStep=0.25
  local gradientSigma=6.0
  local totalFieldSigma=0


  local OUTPUT=$outputPre
  local AFFINEMETRIC="MSQ[$fixMask,$movMask,1]"
  local ITERATIONS=$iterations
  local TRANSFORMATION="SyN[$gradientStep]"
  local REGULARIZATION="Gauss[$gradientSigma,$totalFieldSigma]"
  local IMAGEMETRIC="CC[$fixProcess,$movProcess,1,$metricRadius]"
  local USERECURSIVEGAUSSIAN="false"

  local FIXEDIMAGE=$fixOrig
  local MOVINGIMAGE=$movOrig

  # output filename
  local DEFORMEDIMAGE=${OUTPUT}deformed.nii.gz
  local VECTORFIELD=${OUTPUT}Warp.nii.gz
  local AFFINE=${OUTPUT}Affine.txt

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

function ComposeDeformation()
{
  # compute the Jacobian of the composed deformation field

  local ANTS=${ANTSDIRECTORY}/ANTS
  local WARPIMAGE=${ANTSDIRECTORY}/WarpImageMultiTransform
  local COMPOSEWARP=${ANTSDIRECTORY}/ComposeMultiTransform
  local JACOBIAN=${ANTSDIRECTORY}/ANTSJacobian


  DIMENSION=3

  OUTPUT=$1
  FIXEDIMAGE=$2
  MOVINGIMAGE=$3
  FIXEDMASK=$4
  ORIGFIXEDIMAGE=$5
  ORIGMOVINGIMAGE=$6

  echo
  echo $OUTPUT
  echo $FIXEDIMAGE
  echo $MOVINGIMAGE
  echo $FIXEDMASK
  echo $ORIGFIXEDIMAGE
  echo $ORIGMOVINGIMAGE
  echo ${OUTPUT}ANTSCall.txt


  DEFORMEDIMAGE=${OUTPUT}deformed.nii.gz
  VECTORFIELD=${OUTPUT}Warp.nii.gz
  AFFINE=${OUTPUT}Affine.txt
  TOTALVECTORFIELD=${OUTPUT}TotalWarp.nii.gz
  DEFORMEDORIGIMAGE=${OUTPUT}OrigDeformed.nii.gz

  # if [ "A" != "A" ]
  # then


  echo >> ${OUTPUT}ANTSCall.txt
  echo "compose deformation initial date:" `date` >> ${OUTPUT}ANTSCall.txt
  echo
  echo "--- compose the affine and the deformation field --- " `date` >> ${OUTPUT}ANTSCall.txt
  echo $COMPOSEWARP $DIMENSION $TOTALVECTORFIELD $VECTORFIELD $AFFINE -R $FIXEDIMAGE >> ${OUTPUT}ANTSCall.txt
  $COMPOSEWARP $DIMENSION $TOTALVECTORFIELD $VECTORFIELD $AFFINE -R $FIXEDIMAGE >> ${OUTPUT}ANTSCall.txt
  echo

  echo "--- compute the jacobian of the composed deformation --- " `date` >> ${OUTPUT}ANTSCall.txt
  echo $JACOBIAN $DIMENSION $TOTALVECTORFIELD ${OUTPUT} 0 $FIXEDMASK 0 >> ${OUTPUT}ANTSCall.txt
  $JACOBIAN $DIMENSION $TOTALVECTORFIELD ${OUTPUT} 0 $FIXEDMASK 0 >> ${OUTPUT}ANTSCall.txt
  echo


  # making some extra symbol links here
#  ln -fs $FIXEDMASK `dirname $OUTPUT`
#  ln -fs $ORIGFIXEDIMAGE `dirname $OUTPUT`
#  ln -fs $ORIGMOVINGIMAGE `dirname $OUTPUT`

  echo "compose deforamtion ending date" `date` >> ${OUTPUT}ANTSCall.txt

}




function AnalyzeDeformation()
{
  # for Cuneyt's pipeline
  # compute the Jacobian of the composed deformation field
  # compute Nick's principal strain and directional strain
  # compute the statistics on each lobe and the whole lung 

  local STRAIN=$UTILITIESDIR/CreatePrincipalStrainImages
  local STRAIN2=$UTILITIESDIR/CreateDirectionalStrainImages
  local STATS=$UTILITIESDIR/CalculateFirstOrderStatisticsFromImage

#  local STRAIN="echo $STRAIN"
#  local STRAIN2="echo $STRAIN2"
#  local STATS="echo $STATS"

  ORIGFIXEDIMAGE=$1
  FIXEDMASK=$2
  FIXEDLOBEMASKDIR=$3
  OUTPUT=$4



  TOTALVECTORFIELD=${OUTPUT}TotalWarp.nii.gz


  fixImageName=$(basename $ORIGFIXEDIMAGE)
  fixImageName=${fixImageName%%.*}


  echo $fixImageName
  dog=$( perl -e '@a=split("-", "'$fixImageName'");print @a[0]');
  timing=$( perl -e '@a=split("-", "'$fixImageName'");print @a[1]');
  pos=$( perl -e '@a=split("-", "'$fixImageName'");print @a[2]');
  pressure=$( perl -e '@a=split("-", "'$fixImageName'");print @a[3]');



  # input will be the deformation field and the masks
  if [ ! -f $TOTALVECTORFIELD ];
  then
    echo -e "$TOTALVECTORFIELD : not existed!!"
    #    exit;
  fi;

  if [ ! -f $FIXEDMASK ];
  then
    echo -e "$FIXEDMASK: not existed!!";
    #    exit;
  fi;


  if [ $timing == 'PRE' ];
  then
    lobes=( 'LLL' 'LML' 'LUL' 'RCL' 'RLL' 'RML' 'RUL' );
  elif [ $timing == 'POST' ];
  then
    lobes=( 'LLL' 'LML' 'LUL' );
  else
    echo "!!!!!!!!!!!! wroing timing:? $timing";
  fi;

  $STRAIN 3 $TOTALVECTORFIELD ${OUTPUT}_PS 1 ${FIXEDMASK}
  $STRAIN 3 $TOTALVECTORFIELD ${OUTPUT}_PS 0 ${FIXEDMASK}
  $STRAIN2 3 $TOTALVECTORFIELD ${OUTPUT}_DSxx 0x0 ${FIXEDMASK}
  $STRAIN2 3 $TOTALVECTORFIELD ${OUTPUT}_DSyy 1x1 ${FIXEDMASK}
  $STRAIN2 3 $TOTALVECTORFIELD ${OUTPUT}_DSzz 2x2 ${FIXEDMASK}
  $STRAIN2 3 $TOTALVECTORFIELD ${OUTPUT}_DSxy 0x1 ${FIXEDMASK}
  $STRAIN2 3 $TOTALVECTORFIELD ${OUTPUT}_DSxz 0x2 ${FIXEDMASK}
  $STRAIN2 3 $TOTALVECTORFIELD ${OUTPUT}_DSyz 1x2 ${FIXEDMASK}

  for (( i=0; i<${#lobes[*]}; i++))
  do
    lobe=${lobes[$i]};
    lobemask=$FIXEDLOBEMASKDIR/$lobe-$fixImageName.hdr;
    echo $lobemask
    if [ ! -f $lobemask ];
    then
      echo "$lobemask lobe mask not exist!!!";
    fi;

    N=976;
    $STATS 3 ${OUTPUT}_PS1.nii.gz $lobemask $N > ${OUTPUT}_PS1_${lobe}.txt
    $STATS 3 ${OUTPUT}_PS2.nii.gz $lobemask $N > ${OUTPUT}_PS2_${lobe}.txt
    $STATS 3 ${OUTPUT}_PS3.nii.gz $lobemask $N > ${OUTPUT}_PS3_${lobe}.txt

    $STATS 3 ${OUTPUT}_DSxxLagrangian.nii.gz ${lobemask} $N > ${OUTPUT}_DSxx_${lobe}.txt
    $STATS 3 ${OUTPUT}_DSyyLagrangian.nii.gz ${lobemask} $N > ${OUTPUT}_DSyy_${lobe}.txt
    $STATS 3 ${OUTPUT}_DSzzLagrangian.nii.gz ${lobemask} $N > ${OUTPUT}_DSzz_${lobe}.txt
    $STATS 3 ${OUTPUT}_DSxyLagrangian.nii.gz ${lobemask} $N > ${OUTPUT}_DSxy_${lobe}.txt
    $STATS 3 ${OUTPUT}_DSxzLagrangian.nii.gz ${lobemask} $N > ${OUTPUT}_DSxz_${lobe}.txt
    $STATS 3 ${OUTPUT}_DSyzLagrangian.nii.gz ${lobemask} $N > ${OUTPUT}_DSyz_${lobe}.txt


  done;

  $STATS 3 ${OUTPUT}_PS1.nii.gz $FIXEDMASK 1 > ${OUTPUT}_PS1_lung.txt
  $STATS 3 ${OUTPUT}_PS2.nii.gz $FIXEDMASK 1 > ${OUTPUT}_PS2_lung.txt
  $STATS 3 ${OUTPUT}_PS3.nii.gz $FIXEDMASK 1 > ${OUTPUT}_PS3_lung.txt

  $STATS 3 ${OUTPUT}_DSxxLagrangian.nii.gz ${FIXEDMASK} 1 > ${OUTPUT}_DSxx_lung.txt
  $STATS 3 ${OUTPUT}_DSyyLagrangian.nii.gz ${FIXEDMASK} 1 > ${OUTPUT}_DSyy_lung.txt
  $STATS 3 ${OUTPUT}_DSzzLagrangian.nii.gz ${FIXEDMASK} 1 > ${OUTPUT}_DSzz_lung.txt
  $STATS 3 ${OUTPUT}_DSxyLagrangian.nii.gz ${FIXEDMASK} 1 > ${OUTPUT}_DSxy_lung.txt
  $STATS 3 ${OUTPUT}_DSxzLagrangian.nii.gz ${FIXEDMASK} 1 > ${OUTPUT}_DSxz_lung.txt
  $STATS 3 ${OUTPUT}_DSyzLagrangian.nii.gz ${FIXEDMASK} 1 > ${OUTPUT}_DSyz_lung.txt



}






# step 1: preprocess
# input: $fixImage
# output: $fixImageName"-preprocessed.nii.gz"

fixProcessed=${tempDir}/${fixImageName}-preprocessed.nii.gz
movProcessed=${tempDir}/${movImageName}-preprocessed.nii.gz

 preprocess $fixImage $fixMask $fixProcessed $tempDir
 preprocess $movImage $movMask $movProcessed $tempDir


# step 2: registration
# input: 
#  $fixProcessed, $fixMask, $fixImage
#  $movProcessed, $movMask, $movImage
# output:
#  $outputPre
# temp:
#  $tempDir

 register $fixProcessed $fixMask $fixImage $movProcessed $movMask $movImage $outputPre $tempDir




 ComposeDeformation $outputPre $fixProcessed $movProcessed $fixMask $fixImage $movImage

# step 3: post analyze the deformation field
AnalyzeDeformation $fixImage $fixMask $fixLobeMaskDir $outputPre




# optional step 3: unpad all the deformation field











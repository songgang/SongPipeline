# request Bourne shell as shell for job
#$ -S /bin/sh

ANTS=/home/tustison/ANTS/bin64/ANTS
WARP=/home/tustison/ANTS/bin64/WarpImageMultiTransform
COMPWARP=/home/tustison/ANTS/bin64/ComposeMultiTransform
STRAIN=/home/tustison/Utilities/bin64/CreatePrincipalStrainImages
STRAIN2=/home/tustison/Utilities/bin64/CreateDirectionalStrainImages
STATS=/home/tustison/Utilities/bin64/CalculateFirstOrderStatisticsFromImage
THRESH=/home/tustison/Utilities/bin64/ThresholdImage
CONVERT=/home/tustison/Utilities/bin64/ConvertImage
AVANTS=/home/tustison/Utilities/bin64/ConvertDeformationFieldToAvantsLandmarkFiles
AVANTS2=/home/tustison/Utilities/bin64/ConvertAvantsLandmarkFileToVTK
CHANGE=/home/tustison/Utilities/bin64/ChangeImageInformation
FLIP=/home/tustison/Utilities/bin64/FlipImage
LOM=/home/tustison/Utilities/bin64/LabelOverlapMeasures

fixedImageDirectory=$1
movingImageDirectory=$2
outputDirectory=$3
timePoint=$4
mask=$5

fixedImage=${fixedImageDirectory}/${timePoint}.nii.gz
movingImage=${movingImageDirectory}/${timePoint}.nii.gz
output=${outputDirectory}/ants${timePoint}.nii.gz
prefix=${outputDirectory}/ants${timePoint}

TMPFIXEDMASK=${prefix}_fixed_tmp.nii.gz
TMPMOVINGMASK=${prefix}_moving_tmp.nii.gz

$THRESH 3 ${fixedImageDirectory}/${mask} ${TMPFIXEDMASK} 0 0 0 1
$THRESH 3 ${movingImageDirectory}/${mask} ${TMPMOVINGMASK} 0 0 0 1

#  $ANTS 3 -m MSQ[${TMPFIXEDMASK},${TMPMOVINGMASK},1,4] \
#         -t Elast[0.5] \
#         -i 0 \
#         -r DMFFD[2x2x2,0,3] \
#         -o ${outputDirectory}/ants${timePoint}_initial
#
#  $ANTS 3 -m MSQ[${fixedImage},${movingImage},1,4] \
#         -a ${outputDirectory}/ants${timePoint}_initialAffine.txt \
#         -t Elast[0.5] \
#         -i 50x50x50x20 \
#         -r DMFFD[2x2x2,0,3] \
#         -o $output

$COMPWARP 3 ${prefix}TotalWarp.nii.gz -R $fixedImage ${prefix}Warp.nii.gz ${prefix}Affine.txt
$WARP 3 $movingImage ${prefix}Warped.nii.gz -R $fixedImage ${prefix}TotalWarp.nii.gz
$WARP 3 ${movingImageDirectory}/${mask} ${prefix}Warped${mask} -R $fixedImage --use-NN ${prefix}TotalWarp.nii.gz
$LOM 3 ${prefix}Warped${mask} ${fixedImageDirectory}/${mask} > ${outputDirectory}/antsLabelOverlapMeasures${timePoint}.txt

PVDIR=${fixedImageDirectory}/ParaviewFiles/

if [ ! -d ${PVDIR} ];
then
  /bin/mkdir ${PVDIR}
fi

$AVANTS 3 ${prefix}TotalWarp.nii.gz ${PVDIR}/TotalWarp${timePoint} 1 $TMPFIXEDMASK
$AVANTS2 ${PVDIR}/TotalWarp${timePoint}Fixed.txt \
  ${PVDIR}/TotalWarp${timePoint}Moving.txt \
  ${PVDIR}/TotalWarp${timePoint} 2

$STRAIN 3 ${prefix}TotalWarp.nii.gz ${prefix}_PS 1 ${TMPFIXEDMASK}
$STRAIN 3 ${prefix}TotalWarp.nii.gz ${prefix}_PS 0 ${TMPFIXEDMASK}
$AVANTS 3 ${prefix}_PS1.nii.gz ${PVDIR}/PS1${timePoint} 1 $TMPFIXEDMASK
$AVANTS2 ${PVDIR}/PS1${timePoint}Fixed.txt \
  ${PVDIR}/PS1${timePoint}Moving.txt \
  ${PVDIR}/PS1${timePoint} 2

$STRAIN2 3 ${prefix}TotalWarp.nii.gz ${prefix}_DSxx 0x0 ${TMPFIXEDMASK}
$STRAIN2 3 ${prefix}TotalWarp.nii.gz ${prefix}_DSyy 1x1 ${TMPFIXEDMASK}
$STRAIN2 3 ${prefix}TotalWarp.nii.gz ${prefix}_DSzz 2x2 ${TMPFIXEDMASK}
$STRAIN2 3 ${prefix}TotalWarp.nii.gz ${prefix}_DSxy 0x1 ${TMPFIXEDMASK}
$STRAIN2 3 ${prefix}TotalWarp.nii.gz ${prefix}_DSxz 0x2 ${TMPFIXEDMASK}
$STRAIN2 3 ${prefix}TotalWarp.nii.gz ${prefix}_DSyz 1x2 ${TMPFIXEDMASK}

name[0]=Airways
name[1]=LL
name[2]=LM
name[3]=LU
name[4]=RC
name[5]=RL
name[6]=RM
name[7]=RU

$CONVERT 3 ${fixedImageDirectory}/${timePoint}.nii.gz ${PVDIR}/${timePoint}.mha

for (( i = 0; i < ${#name[*]}; i++ ))
do

   ## Convert segmentation files to .mha

  image="";

  if [ $timePoint == "Pre" ];
  then
    image=${name[$i]}pre
  fi

  if [ $timePoint == "Post3mo" ];
  then
    image=${name[$i]}3mo
  fi

  if [ $timePoint == "Post15mo" ];
  then
    image=${name[$i]}15mo
  fi


 if [ $i -gt 0 ];
 then
  $STATS 3 ${prefix}_PS1.nii.gz ${fixedImageDirectory}/${mask} $i > ${prefix}_PS1_${name[$i]}.txt
  $STATS 3 ${prefix}_PS2.nii.gz ${fixedImageDirectory}/${mask} $i > ${prefix}_PS2_${name[$i]}.txt
  $STATS 3 ${prefix}_PS3.nii.gz ${fixedImageDirectory}/${mask} $i > ${prefix}_PS3_${name[$i]}.txt

  $STATS 3 ${prefix}_DSxxLagrangian.nii.gz ${fixedImageDirectory}/${mask} $i > ${prefix}_DSxx_${name[$i]}.txt
  $STATS 3 ${prefix}_DSyyLagrangian.nii.gz ${fixedImageDirectory}/${mask} $i > ${prefix}_DSyy_${name[$i]}.txt
  $STATS 3 ${prefix}_DSzzLagrangian.nii.gz ${fixedImageDirectory}/${mask} $i > ${prefix}_DSzz_${name[$i]}.txt
  $STATS 3 ${prefix}_DSxyLagrangian.nii.gz ${fixedImageDirectory}/${mask} $i > ${prefix}_DSxy_${name[$i]}.txt
  $STATS 3 ${prefix}_DSxzLagrangian.nii.gz ${fixedImageDirectory}/${mask} $i > ${prefix}_DSxz_${name[$i]}.txt
  $STATS 3 ${prefix}_DSyzLagrangian.nii.gz ${fixedImageDirectory}/${mask} $i > ${prefix}_DSyz_${name[$i]}.txt
 fi

 if [ ! -e "${fixedImageDirectory}/${image}.nii.gz" ];
 then
   continue;
 fi

#   $CONVERT 3 ${fixedImageDirectory}/${image}.nii.gz \
#     ${PVDIR}/${image}.mha
#   $FLIP 3 ${PVDIR}/${image}.mha \
#     ${PVDIR}/${image}.mha 0x0x1
#   $CHANGE 3 ${PVDIR}/${image}.mha \
#     ${PVDIR}/${image}.mha \
#     4 ${PVDIR}/${timePoint}.mha
#
#   if [ $i -gt 0 ];
#   then
#     $CONVERT 3 ${fixedImageDirectory}/${image}_vessels.nii.gz \
#       ${PVDIR}/${image}_vessels.mha
#     $FLIP 3 ${PVDIR}/${image}_vessels.mha \
#       ${PVDIR}/${image}_vessels.mha 0x0x1
#     $CHANGE 3 ${PVDIR}/${image}_vessels.mha \
#       ${PVDIR}/${image}_vessels.mha \
#       4 ${PVDIR}/${timePoint}.mha
#   fi
done

/bin/rm ${TMPFIXEDMASK}
/bin/rm ${prefix}TotalWarpxvec.nii.gz
/bin/rm ${prefix}TotalWarpyvec.nii.gz
/bin/rm ${prefix}TotalWarpzvec.nii.gz

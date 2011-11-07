#!/bin/bash
#$ -S /bin/bash


commonScriptDir=/home/songgang/project/GermanLung/script/SongPipeline/common


# block comment
#:<<adfadsfasdfadsffdfd
imgList="
8351666/8351666_post_lobe_resection_12_10_10
8351666/8351666_post_lobe_resection_27_1_11
8351666/8351666_pre_lobe_resection_22_6_10
"
#
origDir=/home/songgang/project/GermanLung/input/Nifty
maskDir=/home/songgang/project/GermanLung/output/segmentation
regDir=/home/songgang/project/GermanLung/output/registration
#imgList="
#0002/Series0017
#"

# block comment
#:<<adfadsfasdfadsffdfd
regList="
8351666
8351666_pre_lobe_resection_22_6_10
8351666_post_lobe_resection_12_10_10

8351666
8351666_post_lobe_resection_12_10_10
8351666_post_lobe_resection_27_1_11

8351666
8351666_pre_lobe_resection_22_6_10
8351666_post_lobe_resection_27_1_11
"
#adfadsfasdfadsffdfd


regList=( $regList ) # convert to array from string
nbImg=`echo ${#regList[@]} / 3 | bc` # get number of elements in array
echo ${#regList[@]} / 3 

echo "Total $nbImg registration cases"

for (( i=0; i<nbImg; i++)); do
  subject=${regList[i*3]};
  fixSeries=${regList[i*3+1]};
  movSeries=${regList[i*3+2]};
  
  
  echo
  echo $imageA
  # subject=${imageA%/*} # remove substring from back
  # series=${imageA#*/} # remove substring from begin
  
  echo "subject:" $subject "fix:" $fixSeries "mov:" $movSeries
  
  origFixImagePath=$origDir/$subject/$fixSeries.nii.gz
  origMovImagePath=$origDir/$subject/$movSeries.nii.gz
  maskFixPath=$maskDir/$subject/${fixSeries}-whole-lung-mask.nii.gz
  maskMovPath=$maskDir/$subject/${movSeries}-whole-lung-mask.nii.gz 
  regOutputPrefix=$regDir/$subject/${subject}_fix_${fixSeries}_mov_${movSeries}
  
  # make sure the output directory exists
  regOutputDir=`dirname $regOutputPrefix`
  if [ ! -d $regOutputDir ]; then
    mkdir -p $regOutputDir
  fi
  
  echo "Registration pair of lungs for: $subject fix: $fixSeries mov: $movSeries"
  qsub -pe serial 8 -e $regOutputDir -o $regOutputDir -j y \
        $commonScriptDir/lung_registration_with_mask.sh \
        $origFixImagePath \
        $origMovImagePath \
        $maskFixPath \
        $maskMovPath \
        $regOutputPrefix
done;




# bash ../../../script/SongPipeline/whole_lung_segmentation.sh ../../input/0001/Series0011/0001_Series0011.nii.gz 0001_Series0011-whole-lung-mask.nii.gz

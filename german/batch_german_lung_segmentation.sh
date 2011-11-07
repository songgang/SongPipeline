#!/bin/bash
#$ -S /bin/bash


commonScriptDir=/home/songgang/project/GermanLung/script/SongPipeline/common

srcDir=/home/songgang/project/GermanLung/input/Nifty
dstDir=/home/songgang/project/GermanLung/output/segmentation

#imgList="
#0002/Series0017
#"

# block comment
#:<<adfadsfasdfadsffdfd
imgList="
8351666/8351666_post_lobe_resection_12_10_10
8351666/8351666_post_lobe_resection_27_1_11
8351666/8351666_pre_lobe_resection_22_6_10
"
#adfadsfasdfadsffdfd


imgList=( $imgList ) # convert to array from string
nbImg=${#imgList[@]} # get number of elements in array

echo "Total $nbImg files"

for (( i=0; i<nbImg; i++)); do
  imageA=${imgList[i]};
  
  echo
  echo $imageA
  subject=${imageA%/*} # remove substring from back
  series=${imageA#*/} # remove substring from begin
  
  echo $subject "-->" $series
  
  inputImagePath=$srcDir/$subject/${series}.nii.gz
  outputImagePath=$dstDir/$subject/${series}-whole-lung-mask.nii.gz
  
  # make sure the output directory exists
  outputDir=`dirname $outputImagePath`
  if [ ! -d $outputDir ]; then
    mkdir -p $outputDir
  fi
  
  echo "Segmentation whole lung for:"
  echo "$inputImagePath"
  qsub -pe serial 4 -e $dstDir/$subject -o $dstDir/$subject -j y \
        $commonScriptDir/whole_lung_segmentation_byhalf.sh \
        $inputImagePath \
        $outputImagePath

done;




# bash ../../../script/SongPipeline/whole_lung_segmentation.sh ../../input/0001/Series0011/0001_Series0011.nii.gz 0001_Series0011-whole-lung-mask.nii.gz

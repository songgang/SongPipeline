#!/bin/bash
#$ -S /bin/bash


commonScriptDir=/home/songgang/project/KobeLung/script/SongPipeline/common

srcDir=/home/songgang/project/KobeLung/data/input
dstDir=/home/songgang/project/KobeLung/data/output

#imgList="
#0002/Series0017
#"

# block comment
#:<<adfadsfasdfadsffdfd
imgList="
0001/Series0011
0001/Series0017
0002/Series0011
0002/Series0017
0003/Series0011
0003/Series0017
0006/Series0011
0006/Series0017
0008/Series0011
0008/Series0017
0009/Series0011
0009/Series0017
0004/Series0008
0004/Series0014
0005/Series0008
0005/Series0014
0007/Series0008
0007/Series0014
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
  
  inputImagePath=$srcDir/$subject/$series/${subject}_${series}.nii.gz
  outputImagePath=$dstDir/$subject/${subject}_${series}-whole-lung-mask.nii.gz
  
  # make sure the output directory exists
  outputDir=`dirname $outputImagePath`
  if [ ! -d $outputDir ]; then
    mkdir -p $outputDir
  fi
  
  echo "Segmentation whole lung for: \n$inputImagePath"
  qsub -pe serial 4 -e $dstDir/$subject -o $dstDir/$subject -j y \
        $commonScriptDir/whole_lung_segmentation.sh \
        $inputImagePath \
        $outputImagePath

done;




# bash ../../../script/SongPipeline/whole_lung_segmentation.sh ../../input/0001/Series0011/0001_Series0011.nii.gz 0001_Series0011-whole-lung-mask.nii.gz

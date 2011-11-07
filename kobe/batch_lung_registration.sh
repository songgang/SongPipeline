#!/bin/bash
#$ -S /bin/bash


commonScriptDir=/home/songgang/project/KobeLung/script/SongPipeline/common

origDir=/home/songgang/project/KobeLung/data/input
maskDir=/home/songgang/project/KobeLung/data/output
regDir=/home/songgang/project/KobeLung/data/output
#imgList="
#0002/Series0017
#"

# block comment
#:<<adfadsfasdfadsffdfd
regList="
0001
Series0011
Series0017

0002
Series0011
Series0017

0003
Series0011
Series0017

0006
Series0011
Series0017

0008
Series0011
Series0017

0009
Series0011
Series0017

0004
Series0008
Series0014

0005
Series0008
Series0014
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
  
  origFixImagePath=$origDir/$subject/$fixSeries/${subject}_${fixSeries}.nii.gz
  origMovImagePath=$origDir/$subject/$movSeries/${subject}_${movSeries}.nii.gz
  maskFixPath=$maskDir/$subject/${subject}_${fixSeries}-whole-lung-mask.nii.gz
  maskMovPath=$maskDir/$subject/${subject}_${movSeries}-whole-lung-mask.nii.gz 
  regOutputPrefix=$regDir/$subject/${subject}_${fixSeries}_regto_${movSeries}
  
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

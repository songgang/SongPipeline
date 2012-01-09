#!/bin/bash
#$ -S /bin/bash


commonScriptDir=/home/songgang/project/GermanLung/script/SongPipeline/common


#
origDir=/home/songgang/project/Cuneyt/Jan2012/input/gzipped
maskDir=/home/songgang/project/Cuneyt/Jan2012/output
regDir=/home/songgang/project/Cuneyt/Jan2012/output
#imgList="
#0002/Series0017
#"

# block comment
#:<<adfadsfasdfadsffdfd
regList="
ALVIN-POST
PRONE-10cm
PRONE-30cm

ALVIN-POST
SUPINE-10cm
SUPINE-30cm

ALVIN-PRE
SUPINE-10cm
SUPINE-30cm

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

  dog=$( perl -e '$_="'$subject'";/(.+)-(.+)/;print $1;')
  timing=$( perl -e '$_="'$subject'";/(.+)-(.+)/;print $2;')
  position=$( perl -e '$_="'$fixSeries'";/(.+)-(.+)/;print $1;')
  fixPressure=$( perl -e '$_="'$fixSeries'";/(.+)-(.+)/;print $2;')
  movPressure=$( perl -e '$_="'$movSeries'";/(.+)-(.+)/;print $2;')
  
  echo
  echo -e "dog:\t$dog"
  echo -e "timing:\ttiming"
  echo -e "position:\tposition"
  
  # subject=${imageA%/*} # remove substring from back
  # series=${imageA#*/} # remove substring from begin
  
  echo "subject:" $subject "fix:" $fixSeries "mov:" $movSeries
  
  origFixImagePath=$origDir/$subject/$fixSeries/$subject-$fixSeries.hdr
  origMovImagePath=$origDir/$subject/$movSeries/$subject-$movSeries.hdr
  maskFixPath=$maskDir/$subject/$fixSeries/$subject-$fixSeries-lungmask.nii.gz
  maskMovPath=$maskDir/$subject/$movSeries/$subject-$movSeries-lungmask.nii.gz 
  regOutputPrefix=$regDir/$subject/$position-fix-${fixPressure}-mov-${movPressure}/$dog-$timing-$position-fix-${fixPressure}-mov-${movPressure}
  fixLobeMaskPath=$origDir/$subject/$fixSeries/MaskFiles


  # make sure the output directory exists
  regOutputDir=`dirname $regOutputPrefix`
  if [ ! -d $regOutputDir ]; then
  echo
    mkdir -p $regOutputDir
  fi
  
  
  
  echo "Registration pair of lungs for: $subject fix: $fixSeries mov: $movSeries"
  
  ls $origFixImagePath
  ls $origMovImagePath
  ls $maskFixPath
  ls $maskMovPath
  ls $regOutputDir
  
#  $commonScriptDir/lung_registration_with_mask.sh \
   qsub -pe serial 8 -e $regOutputDir -o $regOutputDir -j y \
        cuneyt_jan2012_lung_registration_with_mask.sh \
        $origFixImagePath \
        $origMovImagePath \
        $maskFixPath \
        $maskMovPath \
        $fixLobeMaskPath \
        $regOutputPrefix

#  . cuneyt_jan2012_analyze_deformation.sh $origFixImagePath $maskFixPath $fixLobeMaskPath $regOutputPrefix


done;




# bash ../../../script/SongPipeline/whole_lung_segmentation.sh ../../input/0001/Series0011/0001_Series0011.nii.gz 0001_Series0011-whole-lung-mask.nii.gz

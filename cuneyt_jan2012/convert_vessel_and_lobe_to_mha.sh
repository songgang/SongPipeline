#!/bin/bash
#$ -S /bin/bash


# currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
# echo $currentDir;
commonScriptDir=/home/songgang/project/Cuneyt/Jan2012/script/SongPipeline/cuneyt_jan2012

inputImg=$1;
outputDir=$2;
lobes=( 'LLL' 'LML' 'LUL' 'RCL' 'RLL' 'RML' 'RUL' );

C3D=/home/songgang/pkg/bin/c3d

dogtiming=`perl -e '$_="'$inputImg'"; /(.+\/)*(.+)\/(.+)\/(.+).hdr$/; print $2;'`;
pospressure=`perl -e '$_="'$inputImg'"; /(.+\/)*(.+)\/(.+)\/(.+).hdr$/; print $3;'`;
imgname=`perl -e '$_="'$inputImg'"; /(.+\/)*(.+)\/(.+)\/(.+).hdr$/; print $4;'`;
inputDir=`dirname $inputImg`;
	
dog=`perl -e'$_="'$dogtiming'"; /(.+)-(.+)/;print $1;'`;
timing=`perl -e'$_="'$dogtiming'"; /(.+)-(.+)/;print $2;'`;


if [ $timing == 'PRE' ]
then
  lobes=( 'LLL' 'LML' 'LUL' 'RCL' 'RLL' 'RML' 'RUL' );
elif [ $timing == 'POST' ]
then
  lobes=( 'LLL' 'LML' 'LUL'  );
else
  exit;
fi;

	
pos=`perl -e'$_="'$pospressure'"; /(.+)-(.+)/;print $1;'`;
pressure=`perl -e'$_="'$pospressure'"; /(.+)-(.+)/;print $2;'`;


	echo "--------------------------------"
	echo -e "inputImg: \t$inputImg"
	echo -e "dog: \t$dog"
	echo -e "timing: \t$timing"
	echo -e "pos: \t$pos"
	echo -e "pressuure: \t$pressure"
	echo -e "lobes: \t${lobes[*]}"


# make output dir
subout=$outputDir/$dogtiming/$pospressure
outputMaskNiftyDirectory=$subout/LobeMasks
outputMaskMhaDirectory=$subout/LobeMasks/ParaviewFiles
mkdir -p $outputMaskNiftyDirectory
mkdir -p $outputMaskMhaDirectory

# convert the HRCT image to mha
# $C3D $inputImg -o $outputMaskMhaDirectory/$(basename $inputImg .hdr).mha
/bin/gzip -f $outputMaskMhaDirectory/$(basename $inputImg .hdr).mha

# convert each lobe to lobe mask and vessel mask
for (( i=0; i<${#lobes[@]}; i++ ))
do
  echo "lobe $i: ${lobes[$i]}"

  inputMaskFile=$inputDir/MaskFiles/${lobes[$i]}-$imgname.hdr
  /usr/bin/perl $commonScriptDir/extract_vessel.pl $inputMaskFile $outputMaskNiftyDirectory $outputMaskMhaDirectory

done;


exit;






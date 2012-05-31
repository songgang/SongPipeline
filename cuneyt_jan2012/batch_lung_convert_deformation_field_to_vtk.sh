#!/bin/bash
## -S /bin/bash


# batch to convert the deformation field to vtk
# iterating over the fixed image file names


commonScriptDir=/home/songgang/project/Cuneyt/Jan2012/script/SongPipeline/cuneyt_jan2012

srcDir=/home/songgang/project/Cuneyt/Jan2012/input/gzipped
qsuboutDir=/home/songgang/project/Cuneyt/Jan2012/output

# currentDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
# echo $currentDir;

:<<haha
pathList="
ALVIN-PRE/SUPINE-30cm/ALVIN-PRE-SUPINE-30cm
"
haha


pathList="
ALVIN-POST/PRONE-30cm/ALVIN-POST-PRONE-30cm
ALVIN-POST/SUPINE-30cm/ALVIN-POST-SUPINE-30cm
ALVIN-PRE/SUPINE-30cm/ALVIN-PRE-SUPINE-30cm

BARTLETT-POST/PRONE-30cm/BARTLETT-POST-PRONE-30cm
BARTLETT-POST/SUPINE-30cm/BARTLETT-POST-SUPINE-30cm
BARTLETT-PRE/SUPINE-30cm/BARTLETT-PRE-SUPINE-30cm

CLYDE-POST/PRONE-30cm/CLYDE-POST-PRONE-30cm
CLYDE-POST/SUPINE-30cm/CLYDE-POST-SUPINE-30cm
CLYDE-PRE/SUPINE-30cm/CLYDE-PRE-SUPINE-30cm

DALLAS-POST/PRONE-30cm/DALLAS-POST-PRONE-30cm
DALLAS-POST/SUPINE-30cm/DALLAS-POST-SUPINE-30cm
DALLAS-PRE/SUPINE-30cm/DALLAS-PRE-SUPINE-30cm

EVANT-POST/PRONE-30cm/EVANT-POST-PRONE-30cm
EVANT-POST/SUPINE-30cm/EVANT-POST-SUPINE-30cm
EVANT-PRE/SUPINE-30cm/EVANT-PRE-SUPINE-30cm

FLINT-POST/PRONE-30cm/FLINT-POST-PRONE-30cm
FLINT-POST/SUPINE-30cm/FLINT-POST-SUPINE-30cm
FLINT-PRE/SUPINE-30cm/FLINT-PRE-SUPINE-30cm

GILMER-POST/PRONE-30cm/GILMER-POST-PRONE-30cm
GILMER-POST/SUPINE-30cm/GILMER-POST-SUPINE-30cm
GILMER-PRE/SUPINE-30cm/GILMER-PRE-SUPINE-30cm

"





pathList=( ${pathList} ) # convert to array from string
nbPath=${#pathList[@]} # get number of elements in array

echo "Total $nbPath files"


for (( i=0; i<nbPath; i++ )); do
	pathA=${pathList[i]};

	dogtiming=`perl -e '$_="'$pathA'"; /(.+)\/(.+)\/(.+)/; print $1;'`;
	pospressure=`perl -e '$_="'$pathA'"; /(.+)\/(.+)\/(.+)/; print $2;'`;
	imgname=`perl -e '$_="'$pathA'"; /(.+)\/(.+)\/(.+)/; print $3;'`;
	
	dog=`perl -e'$_="'$dogtiming'"; /(.+)-(.+)/;print $1;'`;
	timing=`perl -e'$_="'$dogtiming'"; /(.+)-(.+)/;print $2;'`;
	
	pos=`perl -e'$_="'$pospressure'"; /(.+)-(.+)/;print $1;'`;
	pressure=`perl -e'$_="'$pospressure'"; /(.+)-(.+)/;print $2;'`;
	
	# verify names
	imgnameA="$dog-$timing-$pos-$pressure";
	if [ $imgname != $imgnameA ];
	then
		echo "!!!!!!!!!!!!!! inconsistent file names: ";
		echo "   path: $pathA";
		echo "   imagname as substring from path: $imgname";
		echo "   imgname constructed from path: $imgnameA";
	fi;
	
	if [ ! -f $srcDir/${pathA}.hdr ];
	then
		echo "!!!!!!!!!!!!!!!!!!!!! file not exist: $srcDir/${pathA}.hdr";
		break;
	fi;
	

  echo -e "pathA: \t$pathA"
	echo -e "dog: \t$dog"
	echo -e "timing: \t$timing"
	echo -e "pos: \t$pos"
	echo -e "pressuure: \t$pressure"

  qsub -pe serial 4 -e $qsuboutDir -o $qsuboutDir -j y $commonScriptDir/convert_deformation_field_to_vtk.sh $srcDir/${pathA}.hdr
  # bash $commonScriptDir/convert_deformation_field_to_vtk.sh $srcDir/${pathA}.hdr

	# break;

done;

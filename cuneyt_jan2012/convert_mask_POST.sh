#!/bin/bash
#$ -S /bin/bash

inputImg=$1;
outputDir=$2;
lobes=( 'LLL' 'LML' 'LUL' );

C3D=/home/songgang/pkg/bin/c3d

dogtiming=`perl -e '$_="'$inputImg'"; /(.+\/)*(.+)\/(.+)\/(.+).hdr$/; print $2;'`;
pospressure=`perl -e '$_="'$inputImg'"; /(.+\/)*(.+)\/(.+)\/(.+).hdr$/; print $3;'`;
imgname=`perl -e '$_="'$inputImg'"; /(.+\/)*(.+)\/(.+)\/(.+).hdr$/; print $4;'`;
inputDir=`dirname $inputImg`;
	
dog=`perl -e'$_="'$dogtiming'"; /(.+)-(.+)/;print $1;'`;
timing=`perl -e'$_="'$dogtiming'"; /(.+)-(.+)/;print $2;'`;
	
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
mkdir -p $subout

# output lung mask file
outmask=$subout/$imgname-lungmask.nii.gz


l1=$inputDir/MaskFiles/${lobes[0]}-$imgname.hdr
l2=$inputDir/MaskFiles/${lobes[1]}-$imgname.hdr
l3=$inputDir/MaskFiles/${lobes[2]}-$imgname.hdr

$C3D $l1 -threshold 976 976 1 0 -as A -clear $l2 -threshold 976 976 1 0 -push A -add -as A -clear $l3 -threshold 976 976 1 0 -push A -add -as A -clear -push A -threshold 1 Inf 1 0 -o $outmask

ln -s $inputImg $subout/$imgname.hdr
ln -s $(dirname $inputImg)/$(basename $inputImg .hdr).img.gz $subout/$imgname.img.gz



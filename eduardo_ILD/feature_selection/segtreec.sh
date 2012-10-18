
#!/bin/bash

# created date: Nov 20, 2008
# a sample script to segment the vessel tree 
# try the following three methods:
# 1. binary thresholding
# 2. convolution with Gabor filters
# 3. use min-cut segmentation (to be done)


# needed parameters:
METHOD=$1
LUNGIMG=$2
LUNGMASK=$3
LUNGVESSEL=$4
TMPDIR=$5
LUNGNAME=$6
FILTER_THRES=$7

MYDO(){
echo "-------------------------------------------------"
echo $*
echo "-------------------------------------------------"
$*
echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
}

process_binary() {
echo "TODO:"
echo $C3D $INDIR/$IMG-seg.hdr -threshold 4 6 1 0 -o $INDIR/$IMG-segb.hdr
echo $FILTER $DDIR/$IMG.hdr $INDIR/$IMG-segb.hdr $INDIR/$IMG-vessel.hdr

}

process_gabor() {

KERNELDIR=/home/songgang/mnt/data/HRCT/hres/tree/result/kernel
KERNEL=orie46B-
CONV=/home/songgang/mnt/project/imgfea/gccrel-bigmac/fftconvmultimaxidx
C3D=/home/songgang/mnt/pkg/bin/c3d
NICKSDT=/mnt/data1/tustison/Utilities/bin64/GenerateDistanceImage

# use input value
# FILTER_THRES=200

# MYDO "$CONV $LUNGIMG $KERNELDIR/$KERNEL 1 92 $TMPDIR/$LUNGNAME""_fmax.nii.gz"
# use nick's distance transform to replace:
# MYDO "$C3D $LUNGMASK -threshold 2 3 1 0 -sdt -o $TMPDIR/$LUNGNAME""_lungsdt.nii.gz" 

MYDO "$C3D $LUNGMASK -threshold 2 3 1 0 -o $TMPDIR/$LUNGNAME""_lungonly.nii.gz" 
MYDO "$NICKSDT 3 $TMPDIR/$LUNGNAME""_lungonly.nii.gz  $TMPDIR/$LUNGNAME""_lungsdt.nii.gz" 
MYDO "$C3D $TMPDIR/$LUNGNAME""_lungsdt.nii.gz -threshold -Inf -1 1 0 $TMPDIR/$LUNGNAME""_fmax.nii.gz -threshold $FILTER_THRES Inf 1 0 -multiply -o $LUNGVESSEL"
}


process_mincut() {
    echo "TODO: segment with mincut"
}


echo "$*"

case "$METHOD" in 
    "binary" ) 
        echo "use binary segmentation" 
        process_binary $LUNGIMG $MASK $LUNGVESSEL
        ;;
    "gabor" ) 
        echo "use gabor filter for segmentation"
        process_gabor
        ;;
    "mincut" ) 
        echo "use min cut filter for segmentation"
#        process_mincut
        ;;
    * ) echo "Unknown options:" "$*";;
esac








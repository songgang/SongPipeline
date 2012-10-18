#!/bin/bash

# analysis for dynamic air trapping vs. emphysema
# prerequisite: 
#  registration between inspiration and expiration 
#  and compute the deformation field metrics
# fixed: insp, moving: exp
# results stored 
# to obtain $dbroot $mydate $myimg 
# . dblist.sh
 . dblist1.sh


RESROOT=/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008
REGSUBDIR=reg_exp2insp

# RESSDNAME=metric  # name for subdir to store results
# SEGMASK=segmentation # name for the lung mask

echo $datelist

make_dir(){
    if [ -f $1 ]
    then
        echo 'As a file: ' $1
#        rm $1
        return
    fi

    if [ ! -d $1 ]
    then
        echo creating directory $RESDIR
        mkdir $1
    fi
}

func(){
for mydate in $datelist
do
    echo process: $dbroot/$mydate    

    d$mydate
    local let nb_img=`wc -w <<< $imglist`
    echo total $nb_img files
    local i
    for((i=1; i <= nb_img; i+=2 ))
    do
        local fixname
        local movname
        local j
        let j=$i+1

        fixname=`awk "{print $"$j"}" <<< $imglist`
        movname=`awk "{print $"$i"}" <<< $imglist`

        echo "fixed image: " $fixname
        echo "moving image: " $movname
        
#        local    FIXEDIMAGE=$dbroot/$mydate/$fixname/$fixname'.nii.gz'
#        local    MOVINGIMAGE=$dbroot/$mydate/$movname/$movname'.nii.gz'
#        local    RESDIR=$RESROOT/$fixname/$REGSUBDIR
#        local    FIXEDMASKIMAGE=$RESROOT/$fixname/$fixname'_smooth.nii.gz'

        local RESDIR=$RESROOT/$fixname/$REGSUBDIR
        local FIXEDIMAGE=$RESDIR/fixed_resampled.nii.gz
        local MOVINGIMAGE=$RESDIR/moving_resampled.nii.gz
        local FIXEDMASKIMAGEBIG=$RESROOT/$fixname/$fixname'_smooth.nii.gz'
        local FIXEDMASKIMAGE=$RESDIR/mask_resampled2.nii.gz
        local MOVINGMASKIMAGEBIG=$RESROOT/$movname/$movname'_smooth.nii.gz'
        local MOVINGMASKIMAGE=$RESDIR/mask_moving_resampled2.nii.gz
        local FIXVESSEL=$RESDIR/"fixed_vessel.nii.gz"
        local MOVVESSEL=$RESDIR/"moving_vessel.nii.gz"
        local VESSELMETHOD="gabor"

#        /mnt/data1/tustison/Utilities/bin64/ResampleImage 3 $MOVINGMASKIMAGEBIG $MOVINGMASKIMAGE 256x256x256 1 1
#        /mnt/data1/tustison/Utilities/bin64/ThresholdImage 3 $MOVINGMASKIMAGE $MOVINGMASKIMAGE 2 3 1 0

#    
#    echo "FIXEDIMAGE: " $FIXEDIMAGE
#    echo "MOVINGIMAGE: " $MOVINGIMAGE
#    echo "RESDIR: " $RESDIR
#    echo "FIXEDMASKIMAGE:" $FIXEDMASKIMAGE

#        make_dir $RESDIR

        if [ ! -f $FIXEDMASKIMAGE ]
        then
            echo $FIXEDMASKIMAGE does not exist!
            continue
        fi
 
#          qsub -q highmem -S /bin/bash -N "do-"$myimg".sh" -j y -o $CURDIR segtreec_resampled.sh $VESSELMETHOD $FIXEDIMAGE $FIXEDMASKIMAGE $FIXVESSEL $RESDIR "fixed" $FILTER_THRES
#          qsub -q highmem -S /bin/bash -N "do-"$myimg".sh" -j y -o $CURDIR segtreec_resampled.sh $VESSELMETHOD $MOVINGIMAGE $MOVINGMASKIMAGE $MOVVESSEL $RESDIR "MOVING" $FILTER_THRES

#          local FILTER_THRES=100
#          bash segtreec_resampled.sh $VESSELMETHOD $FIXEDIMAGE $FIXEDMASKIMAGE $FIXVESSEL $RESDIR fixed $FILTER_THRES
          local FILTER_THRES=100
          bash segtreec_resampled.sh $VESSELMETHOD $MOVINGIMAGE $MOVINGMASKIMAGE $MOVVESSEL $RESDIR "moving" $FILTER_THRES

        
        break;



    done
done
}


func

#!/bin/bash

# analysis for dynamic air trapping vs. emphysema
# prerequisite: 
#  registration between inspiration and expiration 
#  and compute the deformation field metrics
# fixed: insp, moving: exp
# results stored 
# to obtain $dbroot $mydate $myimg 
 . dblist.sh
# . dblist1.sh


RESROOT=/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008
REGSUBDIR=reg2_exp2insp
OLDREGSUBDIR=reg_exp2insp

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
        
        local    FIXEDIMAGE=$dbroot/$mydate/$fixname/$fixname'.nii.gz'
        local    MOVINGIMAGE=$dbroot/$mydate/$movname/$movname'.nii.gz'
        local    RESDIR=$RESROOT/$fixname/$REGSUBDIR
        local    FIXEDMASKIMAGE=$RESROOT/$fixname/$fixname'_smooth.nii.gz'
        local    MOVINGMASKIMAGE=$RESROOT/$movname/$movname'_smooth.nii.gz'
        local    AIRWAYMASK=$fixname'_airways.nii.gz'
        local    AIRWAYMASKDIR=$RESROOT/$fixname/
        local 	 OLDRESDIR=$RESROOT/$fixname/$OLDREGSUBDIR
        local    TMPDIR=$CURDIR/"tmp_script"
    
#    echo "FIXEDIMAGE: " $FIXEDIMAGE
#    echo "MOVINGIMAGE: " $MOVINGIMAGE
#    echo "RESDIR: " $RESDIR
#    echo "FIXEDMASKIMAGE:" $FIXEDMASKIMAGE

#        make_dir $RESDIR

        if [ ! -f $AIRWAYMASKDIR/$AIRWAYMASK ]
        then
           echo $AIRWAYMASKDIR/$AIRWAYMASK does not exist!
            continue
        fi

#        sleep 2
#		qsub -q mac -S /bin/bash -N "at-"$fixname".sh" -o $TMPDIR -e $TMPDIR analyze_airtrapping.sh $FIXEDIMAGE $MOVINGIMAGE $RESDIR $FIXEDMASKIMAGE $MOVINGMASKIMAGE $AIRWAYMASK $AIRWAYMASKDIR $OLDRESDIR

# temporary to copy the lung volume file (res-Volume in the expiration directory to the inspiration directory)
# noted by GS, Aug 13, 2010, these volume masks contain airways and vessels, should be replaced by res-aeroted-Volume.txt
#  which is generated from aeroted_mask_resampled.nii.gz, and also res-moving-aeroted-Volume.txt from moving_aeroted_mask_resampled.nii.gz
#    	cp $RESROOT/$movname/res-Volume.txt $RESROOT/$fixname/reg2_exp2insp/res-exp-full-Volume.txt
#    	cp $RESROOT/$fixname/res-Volume.txt $RESROOT/$fixname/reg2_exp2insp/res-insp-full-Volume.txt


# noted by GS, Aug 13, 2010, 
# analyze_airtrapping2.sh extract airways and vessels from computing lung volumes
        bash analyze_airtrapping2.sh $FIXEDIMAGE $MOVINGIMAGE $RESDIR $FIXEDMASKIMAGE $MOVINGMASKIMAGE $AIRWAYMASK $AIRWAYMASKDIR $OLDRESDIR

        
#        break;



    done
done
}

CURDIR=`pwd`
func

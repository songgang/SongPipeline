#!/bin/bash

# registration between inspiration and expiration 
#  and compute the deformation field metrics
# fixed: insp, moving: exp
# results stored 
# to obtain $dbroot $mydate $myimg 
. dblist.sh
#. dblist1.sh


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
        
        local    FIXEDIMAGE=$dbroot/$mydate/$fixname/$fixname'.nii.gz'
        local    MOVINGIMAGE=$dbroot/$mydate/$movname/$movname'.nii.gz'
        local    RESDIR=$RESROOT/$fixname/$REGSUBDIR
        local    FIXEDMASKIMAGE=$RESROOT/$fixname/$fixname'_smooth.nii.gz'
    
#    echo "FIXEDIMAGE: " $FIXEDIMAGE
#    echo "MOVINGIMAGE: " $MOVINGIMAGE
#    echo "RESDIR: " $RESDIR
#    echo "FIXEDMASKIMAGE:" $FIXEDMASKIMAGE

        make_dir $RESDIR

        if [ ! -f $FIXEDMASKIMAGE ]
        then
            echo $FIXEDMASKIMAGE does not exist!
            continue
        fi


       qsub -q highmem -S /bin/bash -N "reg-"$fixname".sh" -o $RESDIR -e $RESDIR register.sh $FIXEDIMAGE $MOVINGIMAGE $RESDIR $FIXEDMASKIMAGE
    

#        echo bash register.sh $FIXEDIMAGE $MOVINGIMAGE $RESDIR $FIXEDMASKIMAGE

        
#       break;



    done
done
}


func

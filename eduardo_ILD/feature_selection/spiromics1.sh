#!/bin/bash

# compute the metric
# http://ntustison.wikidot.com/gsk-pipeline:spiromics-pipeline-on-gsk-data

# to obtain $dbroot $mydate $myimg 
. dblist.sh
# . dblist1.sh


RESROOT=/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases/Oct_07_2008
# RESSDNAME=metric  # name for subdir to store results
# SEGMASK=segmentation # name for the lung mask

echo $datelist

make_metric_dir(){
    if [ -f $RESDIR ]
    then
        echo 'As a file: ' $RESDIR
        rm $RESDIR
    fi

    if [ ! -d $RESDIR ]
    then
        mkdir $RESDIR
    fi
}

CURDIR=`pwd`

func(){
for mydate in $datelist
do
    echo process: $dbroot/$mydate    

    d$mydate

    for myimg in $imglist
    do
        echo ===========================================================
        echo image: $myimg

        # MASK=$dbroot/$mydate/$myimg/$SEGMASK.nii        
        IMG=$dbroot/$mydate/$myimg/$myimg'.nii.gz'
        IMGNAME=$myimg
        RESDIR=$RESROOT/$myimg

        if [ ! -f $IMG ]
        then
            echo $IMG does not exist!
            continue
        fi
    
        make_metric_dir
qsub -q highmem -S /bin/bash -N "do-"$myimg".sh" -j y -o $CURDIR
#        qsub -q highmem -S /bin/bash -N "do-"$myimg".sh" -o $RESDIR -e $RESDIR -v IMG=$IMG,IMGNAME=$IMGNAME,RESDIR=$RESDIR process.sh
#        . process.sh

        
#        break;

    done

#   break;
done
}

func

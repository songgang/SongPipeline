#!/bin/bash

# compute the metric
# http://ntustison.wikidot.com/gsk-pipeline:spiromics-pipeline-on-gsk-data

# to obtain $dbroot $mydate $myimg $SEGMASK
# . dblist.sh
#. dblist_rerun.sh
 . dblist1.sh


RESROOT=/mnt/aibs1/PUBLIC/Data/Output/DrewReconstructionKernelsHRCT/Aug_22_2008
RESSDNAME=metric  # name for subdir to store results
SEGMASK=segmentation # name for the lung mask

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



#        qsub -q x86 -S /bin/bash -N $myimg".sh" -o $RESDIR -e $RESDIR -v IMG=$IMG,IMGNAME=$IMGNAME,RESDIR=$RESDIR,LUNGMASKBIN=$LUNGMASKBIN,LUNGMASKBINNAME=$LUNGMASKBINNAME,LOBMASK=$LOBMASK process_wmask.sh
        . process.sh

        
#        break;

    done

#   break;
done
}

func

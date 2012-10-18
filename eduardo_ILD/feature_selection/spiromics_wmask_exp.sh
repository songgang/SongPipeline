#!/bin/bash

# compute the metric
# http://ntustison.wikidot.com/gsk-pipeline:spiromics-pipeline-on-gsk-data

# to obtain $dbroot $mydate $myimg $SEGMASK
# . dblist.sh
#. dblist_rerun.sh
# . dblist1.sh
. dblist_exp.sh


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


        LUNGMASKBIN=/mnt/aibs1/PUBLIC/Data/Output/DrewReconstructionKernelsHRCT/Aug_22_2008/B20expf_pad/B20expf_pad-lungmaskbin.nii.gz
        LUNGMASKBINNAME=B20expf-lungmaskbin
        LOBMASK=/mnt/aibs1/PUBLIC/Data/Output/DrewReconstructionKernelsHRCT/Aug_22_2008/B20expf_pad/B20expf_pad-lobe.nii.gz

#        qsub -q highmem -S /bin/bash -N $myimg"-wmask.sh" -o $RESDIR -e $RESDIR -v IMG=$IMG,IMGNAME=$IMGNAME,RESDIR=$RESDIR,LUNGMASKBIN=$LUNGMASKBIN,LUNGMASKBINNAME=$LUNGMASKBINNAME,LOBMASK=$LOBMASK process_wmask.sh
        . process_wmask.sh

        
#        break;

    done

#   break;
done
}

func

#!/bin/bash

# the new version script to modulize the spiromics 
# module1: lung segmentation: (final result: smoothlungs ==> separate.nii.gz)
# module2: compute individual metric
# module3: segment vessels 

# compute the metric
# http://ntustison.wikidot.com/gsk-pipeline:spiromics-pipeline-on-gsk-data



make_metric_dir(){

local RESDIR=$1

    if [ -f $RESDIR ]
    then
        echo 'As a file: ' $RESDIR
        rm $RESDIR
    fi

    if [ ! -d $RESDIR ]
    then
        echo creating $RESDIR
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
        
        LUNGIMG=$dbroot/$mydate/$myimg/$myimg'.nii.gz'
        RESDIR=$dbroot/$mydate/$myimg'_shrink'
        NEWLUNGIMG=$RESDIR/$myimg'_shrink.nii.gz'

        

        # LUNGMASK_PREFIX=$RESDIR/$LUNGNAME   

        if [ ! -f $IMG ]
        then
            echo $IMG does not exist!
            continue
        fi
    
        make_metric_dir $RESDIR


        make_metric_dir $CURDIR/tmp_script

        TMPQSUB_FILE=$CURDIR/"tmp_script/shrink-"$myimg".sh"

        touch $TMPQSUB_FILE
        echo "#!/bin/bash" > $TMPQSUB_FILE
        echo /home/songgang/mnt/project/c3d/gccrel-x64nothread/c3d $LUNGIMG -interpolation Cubic -resample 100x100x50% -o $NEWLUNGIMG >> $TMPQSUB_FILE
        qsub -q highmem -S /bin/bash -N "s-"${myimg}".sh" -j y -o $CURDIR $TMPQSUB_FILE


         


    done


done
}

# to obtain $dbroot $mydate $myimg 
. dblist.sh

# RESROOT=/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008
CURDIR=`pwd`
echo $datelist
func

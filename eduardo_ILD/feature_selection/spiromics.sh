#!/bin/bash

# the new version script to modulize the spiromics 
# module1: lung segmentation: (final result: smoothlungs ==> separate.nii.gz)
# module2: compute individual metric
# module3: segment vessels 
# module4: segment airways

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
        LUNGNAME=$myimg
        RESDIR=$RESROOT/$myimg
        LUNGMASK=$RESDIR/$myimg'_smooth.nii.gz'
        VESSELMETHOD="gabor"
        LUNGVESSEL=$RESDIR/$myimg"_vessel.nii.gz"
        AIRWAYMASK=$RESDIR/$myimg"_airways.nii.gz"
        TMPDIR=$RESDIR/$myimg
        

        # LUNGMASK_PREFIX=$RESDIR/$LUNGNAME   

        if [ ! -f $IMG ]
        then
            echo $IMG does not exist!
            continue
        fi
        
        
        # for airway segmentation only
		SEEDFILE=$RESDIR"/airway_seed.txt"
        if [ ! -f $SEEDFILE ]
        then 
        	echo $SEEDFILE does not exist "for" airway segmentation!
        	continue
        fi
        
        
    
        make_metric_dir $RESDIR

        make_metric_dir $CURDIR/tmp_script

        TMPQSUB_FILE=$CURDIR/"tmp_script/leakage-"$myimg".sh"

        echo $LUNGNAME

        touch $TMPQSUB_FILE
 
        echo "#!/bin/bash" > $TMPQSUB_FILE
        echo bash $CURDIR/segairwaysLS1.sh $LUNGIMG $RESDIR $AIRWAYMASK $LUNGNAME >> $TMPQSUB_FILE
       
#        echo bash $CURDIR/seglungc.sh $LUNGIMG $RESDIR $LUNGMASK $LUNGNAME >> $TMPQSUB_FILE
#        echo bash $CURDIR/metricc.sh $LUNGIMG $LUNGMASK $LUNGNAME $RESDIR >> $TMPQSUB_FILE

#		sleep 2
			
#     /bin/bash $TMPQSUB_FILE
  	 itksnap -g $LUNGIMG -s $AIRWAYMASK
     #   qsub -q mac -S /bin/bash -N "leakage-"${myimg}".sh" -j y -o $CURDIR/"tmp_script" $TMPQSUB_FILE

        # echo seglungc.sh $LUNGIMG $RESDIR $LUNGMASK $LUNGNAME
        # echo metricc.sh $LUNGIMG $LUNGMASK $LUNGNAME $RESDIR

#        break


    done
    


done
}

# to obtain $dbroot $mydate $myimg 
# . dblist.sh
. dblist_badairway.sh

RESROOT=/mnt/data1/PUBLIC/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008
CURDIR=`pwd`
echo $datelist
func

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
        mkdir -p $RESDIR
    fi
}


func(){
	
dList
	
for mysubject in $subjectlist
do
    echo process: $dbroot/$mysubject    

    for myphase in $phaselist
    do
    	
    	myimg=$myphase
        echo ===========================================================
        echo image: $myimg

        LUNGIMG=$dbroot/$mysubject/$myphase'.nii.gz'
        LUNGNAME=$myimg
        SEGDIR=$RESROOT/$mysubject/segmentation/$myimg
           
           
        LUNGMASK=$SEGDIR/$myimg'_smooth.nii.gz'
        
        PREDIR=$RESROOT/$mysubject/preprocess/$myimg
        LUNGONLYMASK=$PREDIR/$myimg'_lungonlymask.nii.gz'
        MASKEDLUNG=$PREDIR/$myimg'_masked.nii.gz'

        
        if [ ! -f $IMG ]
        then
            echo $IMG does not exist!
            continue
        fi
        
        
        make_metric_dir $SEGDIR
        make_metric_dir $PREDIR

        make_metric_dir $CURDIR/tmp_script

        TMPQSUB_FILE=$CURDIR/"tmp_script/feature-"$myimg".sh"

        touch $TMPQSUB_FILE
 
        echo "#!/bin/bash" > $TMPQSUB_FILE

        echo bash $CURDIR/seglungc.sh $LUNGIMG $SEGDIR $LUNGMASK $LUNGNAME >> $TMPQSUB_FILE
		    echo bash $CURDIR/masklungc.sh $LUNGIMG $LUNGMASK $LUNGONLYMASK $MASKEDLUNG >> $TMPQSUB_FILE

				

#		sleep 2
			
#     /bin/bash $TMPQSUB_FILE
#  	 itksnap -g $LUNGIMG -s $AIRWAYMASK
     #   qsub -q mac -S /bin/bash -N "leakage-"${myimg}".sh" -j y -o $CURDIR/"tmp_script" $TMPQSUB_FILE

	      ssh compute-1-13 bash $TMPQSUB_FILE


#        break


    done
    
#	break

done
}

# to obtain $dbroot $mydate $myimg 
# . dblist.sh
. dblist.sh

RESROOT=/home/songgang/picsl/project/GermanLung/output
CURDIR=`pwd`
echo $datelist
func

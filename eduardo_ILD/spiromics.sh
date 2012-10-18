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
    	
    	myimg=$mysubject$myphase
        echo ===========================================================
        echo image: $myimg

        # MASK=$dbroot/$mydate/$myimg/$SEGMASK.nii        
        
        LUNGIMG=$dbroot/$mysubject/$myimg'.nii.gz'
        LUNGNAME=$myimg
        RESDIR=$RESROOT/$mysubject/$myimg

        
        ALEXLUNGMASK=$ALEXMASKROOT/$myimg'_manual_char.nii.gz'
        MAYALUNGMASK=$MAYAMASKROOT/$myimg'_label_both_lungs.nii.gz'


        
		# VESSELMETHOD="gabor"
        # LUNGVESSEL=$RESDIR/$myimg"_vessel.nii.gz"
        # AIRWAYMASK=$RESDIR/$myimg"_airways.nii.gz"
        TMPDIR=$RESDIR/$myimg
        
        if [ ! -f $IMG ]
        then
            echo $IMG does not exist!
            continue
        fi
        
        if [ ! -f $ALEXLUNGMASK ]
        then
            echo "$ALEXLUNGMASK does not exist! Only try Maya's Mask."
            # subject 6 7 12 27 36 do not have alex's masks
            # need to skip whole lung analysis for them
            ALEXLUNGMASK="NotAvailable"
        fi

        if [ ! -f $MAYALUNGMASK ]
        then
            echo "$MAYALUNGMASK does not exist! Skip the whole analysis."
            continue
        fi
        

        # for airway segmentation only
		# SEEDFILE=$RESDIR"/airway_seed.txt"
        # if [ ! -f $SEEDFILE ]
        # then 
#        	echo $SEEDFILE does not exist "for" airway segmentation!
#        	continue
#        fi
        
        
    
        make_metric_dir $RESDIR

        make_metric_dir $CURDIR/tmp_script

        TMPQSUB_FILE=$CURDIR/"tmp_script/feature-"$myimg".sh"

        echo $LUNGNAME

        touch $TMPQSUB_FILE
 
        echo "#!/bin/bash" > $TMPQSUB_FILE
# airway segmentation not fully working well yet        
#        echo bash $CURDIR/segairwaysLS1.sh $LUNGIMG $RESDIR $AIRWAYMASK $LUNGNAME >> $TMPQSUB_FILE
#        echo bash $CURDIR/seglungc.sh $LUNGIMG $RESDIR $LUNGMASK $LUNGNAME >> $TMPQSUB_FILE
#        echo bash $CURDIR/metricc.sh $LUNGIMG $LUNGMASK $LUNGNAME $RESDIR >> $TMPQSUB_FILE
        echo bash $CURDIR/metricc.sh $LUNGNAME $LUNGIMG $ALEXLUNGMASK $MAYALUNGMASK $RESDIR >> $TMPQSUB_FILE


#		sleep 2
			
#     /bin/bash $TMPQSUB_FILE
#  	 itksnap -g $LUNGIMG -s $AIRWAYMASK
     
     qsub -pe serial 3 -S /bin/bash -N "ILD-"${myimg}".sh" -j y -o $CURDIR/"tmp_script" $TMPQSUB_FILE
     # bash $TMPQSUB_FILE

    #    break


    done

done
}

# to obtain $dbroot $mydate $myimg 
. dblist.sh
# . dblist_debug.sh
# . dblist_AlexMissing6.sh

# ALEXMASKROOT=/mnt/data/PUBLIC/data1/Data/Input/DrewWarrenLungData/ILD/AlexMask
# MAYAMASKROOT=/mnt/data/PUBLIC/data1/Data/Input/DrewWarrenLungData/ILD/MayaMask
# RESROOT=/mnt/data/PUBLIC/data1/Data/Input/DrewWarrenLungData/ILD/Output_AlexMaya
ALEXMASKROOT=/home/songgang/project/EduardoILD/AlexMask
MAYAMASKROOT=/home/songgang/project/EduardoILD/MayaMask
RESROOT=/home/songgang/project/EduardoILD/Output_AlexMaya
CURDIR=`pwd`
echo $datelist
func

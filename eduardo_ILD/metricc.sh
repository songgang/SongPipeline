 #!/bin/bash

# needs variable: IMG, IMGNAME, RESDIR

# C3D=/home/songgang/mnt/pkg/c3d/c3d-0.8.2-Linux-x86_64/bin/c3d
# BINDIR=/home/tustison/build/Utilities/bin
# BINDIR2=/home/songgang/mnt/project/Nick/gccrel # for GeneratePercentileAttenuationMask2, changed number of bins from 100 to 200 (and upper thres should set as 0.99999, not 1)
C3D=/home/songgang/pkg/bin/c3d
# BINDIR=/home/tustison/Utilities/bin64
BINDIR=/home/songgang/project/tustison/Utilities/gccrel


MYDO(){
# echo "-------------------------------------------------"
# echo $*
# echo "-------------------------------------------------"
 $*
 # echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
}

function myecho
{
    echo
    echo $*
    # time $1
    $*
}

tic(){
START=$(date +%s)
}

toc(){
# START=$(date +%s)
END=$(date +%s)
DIFF=$(( $END - $START ))
echo "It took $DIFF seconds"
}



###########################
process_whole_lung(){

local IMG=$1
local MASK=$2
local RESDIR=$3


local res_Volume=$RESDIR/res-Volume.txt
local res_FirstOrder=$RESDIR/res-FirstOrder.txt
local res_Cooccur=$RESDIR/res-Cooccur.txt
local res_RLM=$RESDIR/res-RLM.txt

MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $MASK  > $res_Volume
MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $MASK 1 100 /tmp/tmp_${res_FirstOrder}.tmp.txt > $res_FirstOrder
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 > $res_RLM

}


##########################
process_ero_mask(){

local IMG=$1
local MASK=$2
local RESDIR=$3
local MASKNAME=$4

local radius_list=(5 10) #radius for erosion
local num_radius=${#radius_list[*]}
local i
for ((i=0; i < num_radius ; i++))
do

    local R=${radius_list[i]}
    local IBMASK=$RESDIR/$MASKNAME"-ib-P"$i.nii.gz
    local OBMASK=$RESDIR/$MASKNAME"-ob-P"$i.nii.gz


    # MYDO $EROBINDIR/GenerateErosionMask $MASK 1 $IBMASK 1 $R

	# perhapse a bug in erode? have -Inf in output, use threshold to remove
    MYDO $C3D $MASK -erode 1 ${R}x${R}x${R}vox -threshold 1 1 1 0 -o $IBMASK

    local res_IB_Volume=$RESDIR/res'-ib-P'$i'-Volume.txt'
    local res_IB_FirstOrder=$RESDIR/res'-ib-P'$i'-FirstOrder.txt'
    local res_IB_Cooccur=$RESDIR/res'-ib-P'$i'-Cooccur.txt'
    local res_IB_RLM=$RESDIR/res'-ib-P'$i'-RLM.txt'
    
    MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $IBMASK  > $res_IB_Volume
    MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $IBMASK 1 100 /tmp/tmp_${res_IB_FirstOrder}.tmp.txt > $res_IB_FirstOrder
    MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $IBMASK 1 > $res_IB_Cooccur
    MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $IBMASK 1 > $res_IB_RLM



    # MYDO $EROBINDIR/SubtractImage $MASK $IBMASK $OBMASK
    MYDO $C3D $MASK $IBMASK -scale -1 -add -o $OBMASK


    local res_OB_Volume=$RESDIR/res'-ob-P'$i'-Volume.txt'
    local res_OB_FirstOrder=$RESDIR/res'-ob-P'$i'-FirstOrder.txt'
    local res_OB_Cooccur=$RESDIR/res'-ob-P'$i'-Cooccur.txt'
    local res_OB_RLM=$RESDIR/res'-ob-P'$i'-RLM.txt'

    MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $OBMASK  > $res_OB_Volume
    MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $OBMASK 1  100 /tmp/tmp_${res_OB_FirstOrder}.tmp.txt > $res_OB_FirstOrder
    MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $OBMASK 1 > $res_OB_Cooccur
    MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $OBMASK 1 > $res_OB_RLM

    MYDO rm $IBMASK
    MYDO rm $OBMASK

done

}


#############################
process_att_mask(){

local IMG=$1
local MASK=$2
local RESDIR=$3
local MASKNAME=$4

local att_lower_list=(0.9 0.95 0.99)
local att_upper_list=(0.99999 0.99999 0.99999)
local num_att=${#att_lower_list[*]}
local i
for ((i=0; i < num_att ; i++))
do
    local att_lower=${att_lower_list[i]}
    local att_upper=${att_upper_list[i]}

    local ATTMASK=$RESDIR/$MASKNAME"-att-P"$i.nii.gz
    MYDO $BINDIR2/GeneratePercentileAttenuationMask 3 $IMG $ATTMASK $att_lower $att_upper 1 $MASK 1


    local res_ATT_Volume=$RESDIR/res'-att-P'$i'-Volume.txt'
    local res_ATT_FirstOrder=$RESDIR/res'-att-P'$i'-FirstOrder.txt'

    MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $ATTMASK  > $res_ATT_Volume
    MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $ATTMASK 1  100 /tmp/tmp_${res_ATT_FirstOrder}.tmp.txt  > $res_ATT_FirstOrder             

    MYDO rm $ATTMASK
done


}

################################
process_lobe_mask(){

local IMG=$1
local SEPMASK=$2
local RESDIR=$3
local LUNGNAME=$4

# to divide the lobe into four regions and run statistics on them 

LOBMASK=$RESDIR/$LUNGNAME"_lobe".nii.gz
MYDO $BINDIR/DivideLungs $SEPMASK $LOBMASK 2 2 

local loblabel_list=(1 2 3 4) # different lung lobs
local num_label=${#loblabel_list[*]}
local i
for ((i=1; i <= num_label ; i++))
do

    local res_LOBE_Volume=$RESDIR/res'-lobe-P'$i'-Volume.txt'
    local res_LOBE_FirstOrder=$RESDIR/res'-lobe-P'$i'-FirstOrder.txt'
    local res_LOBE_Cooccur=$RESDIR/res'-lobe-P'$i'-Cooccur.txt'
    local res_LOBE_RLM=$RESDIR/res'-lobe-P'$i'-RLM.txt'
    
    MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $LOBMASK $i > $res_LOBE_Volume
    MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $LOBMASK $i 100 /tmp/tmp_${res_LOBE_FirstOrder}.tmp.txt > $res_LOBE_FirstOrder
    MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $LOBMASK $i > $res_LOBE_Cooccur
    MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $LOBMASK $i > $res_LOBE_RLM

done

# MYDO rm $LOBMASK

}


################################
process_emphysema(){

local IMG=$1
local LUNGONLYMASK=$2
local RESDIR=$3
local LUNGNAME=$4
local TMPENPHYMASK=$RESDIR/tmp.nii.gz
local res_Emphysema_Volume=$RESDIR/res'-Emphysema-Rel-Volume.txt'

# to divide the lobe into four regions and run statistics on them 

MYDO $C3D $IMG -threshold -Inf -950 1 0 $LUNGONLYMASK -multiply -o $TMPENPHYMASK
MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $TMPENPHYMASK 1 $LUNGONLYMASK 1 > $res_Emphysema_Volume

MYDO rm $TMPENPHYMASK

}

###########################
process_alex_whole_lung(){

local IMG=$1
local MASK=$2
local RESDIR=$3


local res_Volume=$RESDIR/res-alex-Volume.txt
local res_FirstOrder=$RESDIR/res-alex-FirstOrder.txt
local res_Cooccur=$RESDIR/res-alex-Cooccur.txt
local res_RLM=$RESDIR/res-alex-RLM.txt

MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $MASK  > $res_Volume
MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $MASK 1 100 /tmp/tmp_${res_FirstOrder}.tmp.txt > $res_FirstOrder
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 > $res_RLM

# try use scale 2, 4 in GenerateCooccurrenceMeasures and GenerateRunLengthMeasures
local offsetRadius=2;
local res_Cooccur=$RESDIR/res-alex-Cooccur-R{$offsetRadius}.txt
local res_RLM=$RESDIR/res-alex-RLM-R{$offsetRadius}.txt
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 $offsetRadius > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 $offsetRadius> $res_RLM

local offsetRadius=4;
local res_Cooccur=$RESDIR/res-alex-Cooccur-R{$offsetRadius}.txt
local res_RLM=$RESDIR/res-alex-RLM-R{$offsetRadius}.txt
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 $offsetRadius > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 $offsetRadius> $res_RLM

}

###########################
process_maya_outer(){

local IMG=$1
local MASK=$2
local RESDIR=$3


local res_Volume=$RESDIR/res-maya-outer-Volume.txt
local res_FirstOrder=$RESDIR/res-maya-outer-FirstOrder.txt
local res_Cooccur=$RESDIR/res-maya-outer-Cooccur.txt
local res_RLM=$RESDIR/res-maya-outer-RLM.txt

MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $MASK  > $res_Volume
MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $MASK 1 100 /tmp/tmp_${res_FirstOrder}.tmp.txt > $res_FirstOrder
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 > $res_RLM

# try use scale 2, 4 in GenerateCooccurrenceMeasures and GenerateRunLengthMeasures
local offsetRadius=2;
local res_Cooccur=$RESDIR/res-maya-outer-Cooccur-R{$offsetRadius}.txt
local res_RLM=$RESDIR/res-maya-outer-RLM-R{$offsetRadius}.txt
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 $offsetRadius > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 $offsetRadius> $res_RLM

local offsetRadius=4;
local res_Cooccur=$RESDIR/res-maya-outer-Cooccur-R{$offsetRadius}.txt
local res_RLM=$RESDIR/res-maya-outer-RLM-R{$offsetRadius}.txt
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 $offsetRadius > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 $offsetRadius> $res_RLM

}

###########################
process_maya_inner(){

local IMG=$1
local MASK=$2
local RESDIR=$3


local res_Volume=$RESDIR/res-maya-inner-Volume.txt
local res_FirstOrder=$RESDIR/res-maya-inner-FirstOrder.txt
local res_Cooccur=$RESDIR/res-maya-inner-Cooccur.txt
local res_RLM=$RESDIR/res-maya-inner-RLM.txt

MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $MASK  > $res_Volume
MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $MASK 1 100 /tmp/tmp_${res_FirstOrder}.tmp.txt > $res_FirstOrder
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 > $res_RLM

# try use scale 2, 4 in GenerateCooccurrenceMeasures and GenerateRunLengthMeasures
local offsetRadius=2;
local res_Cooccur=$RESDIR/res-maya-inner-Cooccur-R{$offsetRadius}.txt
local res_RLM=$RESDIR/res-maya-inner-RLM-R{$offsetRadius}.txt
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 $offsetRadius > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 $offsetRadius> $res_RLM

local offsetRadius=4;
local res_Cooccur=$RESDIR/res-maya-inner-Cooccur-R{$offsetRadius}.txt
local res_RLM=$RESDIR/res-maya-inner-RLM-R{$offsetRadius}.txt
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 $offsetRadius > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 $offsetRadius> $res_RLM

}

###########################
process_maya_both(){

local IMG=$1
local MASK=$2
local RESDIR=$3


local res_Volume=$RESDIR/res-maya-both-Volume.txt
local res_FirstOrder=$RESDIR/res-maya-both-FirstOrder.txt
local res_Cooccur=$RESDIR/res-maya-both-Cooccur.txt
local res_RLM=$RESDIR/res-maya-both-RLM.txt

MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $MASK  > $res_Volume
MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $MASK 1 100 /tmp/tmp_${res_FirstOrder}.tmp.txt > $res_FirstOrder
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 > $res_RLM

# try use scale 2, 4 in GenerateCooccurrenceMeasures and GenerateRunLengthMeasures
local offsetRadius=2;
local res_Cooccur=$RESDIR/res-maya-both-Cooccur-R{$offsetRadius}.txt
local res_RLM=$RESDIR/res-maya-both-RLM-R{$offsetRadius}.txt
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 $offsetRadius > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 $offsetRadius> $res_RLM

local offsetRadius=4;
local res_Cooccur=$RESDIR/res-maya-both-Cooccur-R{$offsetRadius}.txt
local res_RLM=$RESDIR/res-maya-both-RLM-R{$offsetRadius}.txt
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 256 $MASK 1 $offsetRadius > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 256 $MASK 1 $offsetRadius> $res_RLM

}







#         . metricc.sh $LUNGIMG $LUNGMASK $LUNGNAME $RESDIR

LUNGNAME=$1
IMG=$2
ALEXLUNGMASK=$3
MAYALUNGMASK=$4
RESDIR=$5


echo LUNGNAME: $1


# sanity check
if [ ! -f $LUNGMASK ]
then
    echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    echo $LUNGMASK 'DOES NOT EXIST!!!'
    echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    exit
fi


ALEXLUNGONLYMASK=$RESDIR/$LUNGNAME"_alexlungonly"".nii.gz"


if [ $ALEXLUNGMASK != "NotAvailable" ]
then
    echo "process Alex whole lung mask"
    tic
    # combine label 2:right 3:left 5:vessel
    echo ALEXLUNGONLYMASK: $ALEXLUNGONLYMASK
    MYDO $C3D $ALEXLUNGMASK -as A -threshold 2 3 1 0 -push A -threshold 5 5 1 0 -add -o $ALEXLUNGONLYMASK

    echo 1: $IMG 2: $ALEXLUNGONLYMASK 3: $RESDIR

    process_alex_whole_lung $IMG $ALEXLUNGONLYMASK $RESDIR
    toc
else
    echo $IMG "Alex whole lung mask not existed. Skip whole lung analysis."
fi


echo "process Maya outer sphere lung mask"
tic
MAYAOUTERMASK=$RESDIR/$LUNGNAME"_mayaouter"".nii.gz"
echo MAYAOUTERMASK $MAYAOUTERMASK
# label 1 is outer
# if [ $ALEXLUNGMASK != "NotAvailable" ]
if (( 1==0 )) # not using Alex's mask
then
    MYDO $C3D $MAYALUNGMASK -threshold 1 1 1 0 $ALEXLUNGONLYMASK -times -o $MAYAOUTERMASK
else
    echo $IMG "Alex whole lung mask not existed. Use the whole image domain as fake lung foreground for Maya's outer spheres."
    MYDO $C3D $MAYALUNGMASK -threshold 1 1 1 0 -o $MAYAOUTERMASK
fi
process_maya_outer $IMG $MAYAOUTERMASK $RESDIR
toc

echo "process Maya inner sphere lung mask"
tic
MAYAINNERMASK=$RESDIR/$LUNGNAME"_mayainner"".nii.gz"
echo MAYAINNERMASK $MAYAINNERMASK
# label 2 is inner
# if [ $ALEXLUNGMASK != "NotAvailable" ]
if (( 1==0 )) # not using Alex's mask
then
    MYDO $C3D $MAYALUNGMASK -threshold 2 2 1 0 $ALEXLUNGONLYMASK -times -o $MAYAINNERMASK
else
    echo $IMG "Alex whole lung mask not existed. Use the whole image domain as fake lung foreground for Maya's inner spheres."
    MYDO $C3D $MAYALUNGMASK -threshold 2 2 1 0 -o $MAYAINNERMASK
fi
process_maya_inner $IMG $MAYAINNERMASK $RESDIR
toc




echo "process Maya both outer+inner sphere lung mask"
tic
MAYABOTHMASK=$RESDIR/$LUNGNAME"_mayaboth"".nii.gz"
echo MAYABOTHMASK $MAYABOTHMASK
# label 2 is inner, label 1 is outer
# if [ $ALEXLUNGMASK != "NotAvailable" ]
if (( 1==0 )) # not using Alex's mask
then
    MYDO $C3D $MAYALUNGMASK -threshold 1 2 1 0 $ALEXLUNGONLYMASK -times -o $MAYABOTHMASK
else
    echo $IMG "Alex whole lung mask not existed. Use the whole image domain as fake lung foreground for Maya's both spheres."
    MYDO $C3D $MAYALUNGMASK -threshold 1 2 1 0 -o $MAYABOTHMASK
fi
process_maya_both $IMG $MAYABOTHMASK $RESDIR
toc



exit




























LUNGONLYMASKNAME=$LUNGNAME"_lungonly"
LUNGONLYMASK=$RESDIR/$LUNGONLYMASKNAME".nii.gz"



# sanity check
if [ ! -f $LUNGMASK ]
then
    echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    echo $LUNGMASK 'DOES NOT EXIST!!!'
    echo '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
    exit
fi

MYDO $C3D $LUNGMASK -threshold 2 3 1 0 -o $LUNGONLYMASK


echo "process whole lung"
tic
# process_whole_lung $IMG $LUNGONLYMASK $RESDIR
toc

echo "process erosion mask"
tic
# process_ero_mask $IMG $LUNGONLYMASK $RESDIR $LUNGONLYMASKNAME
toc

echo "process attenuation mask"
tic
# process_att_mask  $IMG $LUNGONLYMASK $RESDIR $LUNGONLYMASKNAME
toc


echo "process lobe mask"
tic
# process_lobe_mask $IMG $LUNGMASK $RESDIR $LUNGNAME
toc

echo "process emphysema"
tic
# process_emphysema $IMG $LUNGONLYMASK $RESDIR $LUNGNAME
toc

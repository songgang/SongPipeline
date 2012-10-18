#!/bin/bash

# needs variable: IMG, IMGNAME, RESDIR

C3DDIR=/home/songgang/mnt/project/c3d/gccrel-x64nothread
EROBINDIR=/mnt/aibs1/songgang/project/imgfea/gccrel-x64nothread
BINDIR=/mnt/data1/tustison/Utilities/bin64
BINDIR2=/mnt/data1/tustison/Utilities/bin64


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
MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $MASK 1 > $res_FirstOrder
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG $MASK 1 > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG $MASK 1 > $res_RLM

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


    MYDO $EROBINDIR/GenerateErosionMask $MASK 1 $IBMASK 1 $R

    local res_IB_Volume=$RESDIR/res'-ib-P'$i'-Volume.txt'
    local res_IB_FirstOrder=$RESDIR/res'-ib-P'$i'-FirstOrder.txt'
    local res_IB_Cooccur=$RESDIR/res'-ib-P'$i'-Cooccur.txt'
    local res_IB_RLM=$RESDIR/res'-ib-P'$i'-RLM.txt'
    
    MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $IBMASK  > $res_IB_Volume
    MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $IBMASK 1 > $res_IB_FirstOrder
    MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG $IBMASK 1 > $res_IB_Cooccur
    MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG $IBMASK 1 > $res_IB_RLM



    MYDO $EROBINDIR/SubtractImage $MASK $IBMASK $OBMASK



    local res_OB_Volume=$RESDIR/res'-ob-P'$i'-Volume.txt'
    local res_OB_FirstOrder=$RESDIR/res'-ob-P'$i'-FirstOrder.txt'
    local res_OB_Cooccur=$RESDIR/res'-ob-P'$i'-Cooccur.txt'
    local res_OB_RLM=$RESDIR/res'-ob-P'$i'-RLM.txt'

    MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $OBMASK  > $res_OB_Volume
    MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $OBMASK 1 > $res_OB_FirstOrder
    MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG $OBMASK 1 > $res_OB_Cooccur
    MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG $OBMASK 1 > $res_OB_RLM

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
local att_upper_list=(1 1 1)
local num_att=${#att_lower_list[*]}
local i
for ((i=0; i < num_att ; i++))
do
    local att_lower=${att_lower_list[i]}
    local att_upper=${att_upper_list[i]}

    local ATTMASK=$RESDIR/$MASKNAME"-att-P"$i.nii.gz
    MYDO $BINDIR/GeneratePercentileAttenuationMask 3 $IMG $ATTMASK $att_lower $att_upper 1 $MASK 1


    local res_ATT_Volume=$RESDIR/res'-att-P'$i'-Volume.txt'
    local res_ATT_FirstOrder=$RESDIR/res'-att-P'$i'-FirstOrder.txt'

    MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $ATTMASK  > $res_ATT_Volume
    MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $ATTMASK 1 > $res_ATT_FirstOrder             

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
    MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $LOBMASK $i > $res_LOBE_FirstOrder
    MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG $LOBMASK $i > $res_LOBE_Cooccur
    MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG $LOBMASK $i > $res_LOBE_RLM

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

MYDO $C3DDIR/c3d $IMG -threshold -Inf -910 1 0 $LUNGONLYMASK -multiply -o $TMPENPHYMASK
MYDO $BINDIR/CalculateVolumeFromBinaryImage 3 $TMPENPHYMASK 1 $LUNGONLYMASK 1 > $res_Emphysema_Volume

# MYDO rm $TMPENPHYMASK

}



#         . metricc.sh $LUNGIMG $LUNGMASK $LUNGNAME $RESDIR
IMG=$1
LUNGMASK=$2
LUNGNAME=$3
RESDIR=$4

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

if [ ! -f $LUNGONLYMASK ]
then
    MYDO $C3DDIR/c3d $LUNGMASK -threshold 2 3 1 0 -o $LUNGONLYMASK
fi


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
process_emphysema $IMG $LUNGONLYMASK $RESDIR $LUNGNAME
toc

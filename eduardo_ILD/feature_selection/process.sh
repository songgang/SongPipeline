#!/bin/bash

# needs variable: IMG, IMGNAME, RESDIR

# BINDIR=/mnt/data1/tustison/Projects/Spiromics/bin
#C3DDIR=/home/songgang/mnt/project/c3d/gccrel-x32
#EROBINDIR=/mnt/aibs1/songgang/project/imgfea/gccrel-bigmac
#BINDIR=/mnt/data1/tustison/Utilities/bin/3D/float
#BINDIR2=/mnt/data1/tustison/Utilities/bin/3D/float

C3DDIR=/home/songgang/mnt/project/c3d/gccrel-x64nothread
EROBINDIR=/mnt/aibs1/songgang/project/imgfea/gccrel-x64nothread
BINDIR=/mnt/data1/tustison/Utilities/bin64
BINDIR2=/mnt/data1/tustison/Utilities/bin64


MYDO(){
echo "-------------------------------------------------"
echo $*
echo "-------------------------------------------------"
$*
echo ">>>>>>>>> DONE <<<<<<<<<<<<<<<<"
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

res_Volume=$RESDIR/res-Volume.txt
res_FirstOrder=$RESDIR/res-FirstOrder.txt
res_Cooccur=$RESDIR/res-Cooccur.txt
res_RLM=$RESDIR/res-RLM.txt
$DO $BINDIR/CalculateVolumeFromBinaryImage 3 $MASK  > $res_Volume
$DO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $MASK 1 > $res_FirstOrder
$DO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG $MASK 1 > $res_Cooccur
$DO $BINDIR/GenerateRunLengthMeasures 3 $IMG $MASK 1 > $res_RLM

}


##########################
process_ero_mask(){

echo process_ero_mask

radius_list=(5 10) #radius for erosion
num_radius=${#radius_list[*]}
for ((i=0; i < num_radius ; i++))
do

    R=${radius_list[i]}
    IBMASK=$RESDIR/$SEGMASK"-ib-P"$i.nii.gz
    OBMASK=$RESDIR/$SEGMASK"-ob-P"$i.nii.gz


    $DO $EROBINDIR/GenerateErosionMask $MASK 1 $IBMASK 1 $R

    res_IB_Volume=$RESDIR/res'-ib-P'$i'-Volume.txt'
    res_IB_FirstOrder=$RESDIR/res'-ib-P'$i'-FirstOrder.txt'
    res_IB_Cooccur=$RESDIR/res'-ib-P'$i'-Cooccur.txt'
    res_IB_RLM=$RESDIR/res'-ib-P'$i'-RLM.txt'
    
    $DO $BINDIR/CalculateVolumeFromBinaryImage 3 $IBMASK  > $res_IB_Volume
    $DO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $IBMASK 1 > $res_IB_FirstOrder
    $DO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG $IBMASK 1 > $res_IB_Cooccur
    $DO $BINDIR/GenerateRunLengthMeasures 3 $IMG $IBMASK 1 > $res_IB_RLM



    $DO $EROBINDIR/SubtractImage $MASK $IBMASK $OBMASK



    res_OB_Volume=$RESDIR/res'-ob-P'$i'-Volume.txt'
    res_OB_FirstOrder=$RESDIR/res'-ob-P'$i'-FirstOrder.txt'
    res_OB_Cooccur=$RESDIR/res'-ob-P'$i'-Cooccur.txt'
    res_OB_RLM=$RESDIR/res'-ob-P'$i'-RLM.txt'

    $DO $BINDIR/CalculateVolumeFromBinaryImage 3 $OBMASK  > $res_OB_Volume
    $DO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $OBMASK 1 > $res_OB_FirstOrder
    $DO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG $OBMASK 1 > $res_OB_Cooccur
    $DO $BINDIR/GenerateRunLengthMeasures 3 $IMG $OBMASK 1 > $res_OB_RLM

    $DO rm $IBMASK
    $DO rm $OBMASK

done

}


#############################
process_att_mask(){

att_lower_list=(0.9 0.95 0.99)
att_upper_list=(1 1 1)
num_att=${#att_lower_list[*]}
for ((i=0; i < num_att ; i++))
do
    att_lower=${att_lower_list[i]}
    att_upper=${att_upper_list[i]}

    ATTMASK=$RESDIR/$SEGMASK"-att-P"$i.nii.gz
    $DO $BINDIR/GeneratePercentileAttenuationMask 3 $IMG $ATTMASK $att_lower $att_upper 1 $MASK 1
    
    res_ATT_Volume=$RESDIR/res'-att-P'$i'-Volume.txt'
    res_ATT_FirstOrder=$RESDIR/res'-att-P'$i'-FirstOrder.txt'

    $DO $BINDIR/CalculateVolumeFromBinaryImage 3 $ATTMASK  > $res_ATT_Volume
    $DO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $ATTMASK 1 > $res_ATT_FirstOrder             

    $DO rm $ATTMASK
done


}

################################
process_lobe_mask(){

# to divide the lobe into four regions and run statistics on them 
#LOBMASK=$RESDIR/$SEGMASK"-lobe".nii.gz
LOBMASK=$RESDIR/$PRE"-lobe".nii.gz

# $DO $BINDIR/DivideLobes $MASK $LOBMASK 2 2 0
# $DO $BINDIR/DivideLobes $LOBMASK $LOBMASK 2 2 2

# $DO $BINDIR/DivideLungs $MASK $LOBMASK 2 2 0
# $DO $BINDIR/DivideLungs $LOBMASK $LOBMASK 2 2 2

loblabel_list=(1 2 3 4) #radius for erosion
num_label=${#loblabel_list[*]}
for ((i=1; i <= num_label ; i++))
do

    res_LOBE_Volume=$RESDIR/res'-lobe-P'$i'-Volume.txt'
    res_LOBE_FirstOrder=$RESDIR/res'-lobe-P'$i'-FirstOrder.txt'
    res_LOBE_Cooccur=$RESDIR/res'-lobe-P'$i'-Cooccur.txt'
    res_LOBE_RLM=$RESDIR/res'-lobe-P'$i'-RLM.txt'
    
    $DO $BINDIR/CalculateVolumeFromBinaryImage 3 $LOBMASK $i > $res_LOBE_Volume
    $DO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $LOBMASK $i > $res_LOBE_FirstOrder
    $DO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG $LOBMASK $i > $res_LOBE_Cooccur
    $DO $BINDIR/GenerateRunLengthMeasures 3 $IMG $LOBMASK $i > $res_LOBE_RLM

done

$DO rm $LOBMASK

}


extract_lung_mask(){
    IMG=$1
    PRE=$2
    LUNGMASK=$RESDIR/$PRE"-lungmask.nii.gz"
    AIRWAYMASK=$RESDIR/$PRE"-airwaymask.nii.gz"
    SEPMASK=$RESDIR/$PRE"-sepmask.nii.gz"
    SMOOTHMASK=$RESDIR/$PRE"-sepmask-smooth.nii.gz"
    LOBMASK=$RESDIR/$PRE"-lobe".nii.gz
    
    # echo $IMG
    # echo $PRE

    $DO $BINDIR/ExtractLungs $IMG $LUNGMASK

    # binarize the lung region to 1 (before it is 2, body is 1)    
    LUNGMASKBIN=$MASK
    $DO $C3DDIR/c3d $LUNGMASK -threshold 2 2 1 0 -o $LUNGMASKBIN
    
    # tic
    # echo $BINDIR/SegmentAirways $IMG $LUNGMASK $AIRWAYMASK
    $DO $BINDIR/SegmentAirways $IMG $LUNGMASK $AIRWAYMASK
    # toc
    
    # tic
    # echo $BINDIR/SeparateLungs $IMG $AIRWAYMASK $SEPMASK
    $DO $BINDIR/SeparateLungs $IMG $AIRWAYMASK $SEPMASK
    # toc
    
    # tic
    # echo $BINDIR/SmoothLungs $IMG $SEPMASK $SMOOTHMASK
    # $BINDIR/SmoothLungs $IMG $SEPMASK $SMOOTHMASK  
    # toc
    
    # divide into lobes
    $DO $BINDIR/DivideLungs $SEPMASK $LOBMASK 2 2 
    
    loblabel_list=(1 2 3 4) #radius for erosion
    num_label=${#loblabel_list[*]}
    for ((i=1; i <= num_label ; i++))
    do

        res_LOBE_Volume=$RESDIR/res'-lobe-P'$i'-Volume.txt'
        res_LOBE_FirstOrder=$RESDIR/res'-lobe-P'$i'-FirstOrder.txt'
        res_LOBE_Cooccur=$RESDIR/res'-lobe-P'$i'-Cooccur.txt'
        res_LOBE_RLM=$RESDIR/res'-lobe-P'$i'-RLM.txt'
    
        $DO $BINDIR/CalculateVolumeFromBinaryImage 3 $LOBMASK $i > $res_LOBE_Volume
        $DO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $LOBMASK $i > $res_LOBE_FirstOrder
        $DO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG $LOBMASK $i > $res_LOBE_Cooccur
        $DO $BINDIR/GenerateRunLengthMeasures 3 $IMG $LOBMASK $i > $res_LOBE_RLM

    done

}

extract_lung_mask_only(){
    IMG=$1
    PRE=$2
    LUNGMASK=$RESDIR/$PRE"-lungmask.nii.gz"
    AIRWAYMASK=$RESDIR/$PRE"-airwaymask.nii.gz"
    SEPMASK=$RESDIR/$PRE"-sepmask.nii.gz"
    SMOOTHMASK=$RESDIR/$PRE"-sepmask-smooth.nii.gz"
    LOBMASK=$RESDIR/$PRE"-lobe".nii.gz
    
    # echo $IMG
    # echo $PRE

    echo $DO $BINDIR/ExtractLungs $IMG $LUNGMASK
    $DO $BINDIR/ExtractLungs $IMG $LUNGMASK

    # binarize the lung region to 1 (before it is 2, body is 1)    
    LUNGMASKBIN=$MASK
    echo $DO $C3DDIR/c3d $LUNGMASK -threshold 2 2 1 0 -o $LUNGMASKBIN
    $DO $C3DDIR/c3d $LUNGMASK -threshold 2 2 1 0 -o $LUNGMASKBIN
    
    # tic
    echo $BINDIR/SegmentAirways $IMG $LUNGMASK $AIRWAYMASK
    $DO $BINDIR/SegmentAirways $IMG $LUNGMASK $AIRWAYMASK
    # toc
    
    # tic
    echo $BINDIR/SeparateLungs $IMG $AIRWAYMASK $SEPMASK
    $DO $BINDIR/SeparateLungs $IMG $AIRWAYMASK $SEPMASK
    # toc
    
    # tic
    echo $BINDIR/SmoothLungs $SEPMASK $SMOOTHMASK 15
    $BINDIR/SmoothLungs $SEPMASK $SMOOTHMASK 15
    # toc
    
    # divide into lobes
    echo $DO $BINDIR/DivideLungs $SEPMASK $LOBMASK 2 2 
    $DO $BINDIR/DivideLungs $SEPMASK $LOBMASK 2 2 
    


}


PRE=$IMGNAME
SEGMASK=$PRE"-lungmaskbin"
MASK=$RESDIR/$PRE"-lungmaskbin.nii.gz"


echo "extract lung masks only..."
tic
extract_lung_mask_only $IMG $PRE
toc

# echo "extract lung masks..."
# tic
# extract_lung_mask $IMG $PRE
# toc


echo $MASK

echo "process whole lung and lobe mask"
tic
process_whole_lung
toc

echo "process erosion mask"
tic
process_ero_mask
toc

echo "process attenuation mask"
tic
process_att_mask
toc

echo "process lobe mask"
tic
process_lobe_mask
toc


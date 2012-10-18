#!/bin/bash
# needs variable: IMG, IMGNAME, RESDIR, LUNGMASKBIN, LUNGMASKBINNAME, LOBMASK
# use the calculate masks to compute metrics

# BINDIR=/mnt/data1/tustison/Projects/Spiromics/bin
C3DDIR=/home/songgang/mnt/project/c3d/gccrel-x64nothread
EROBINDIR=/mnt/aibs1/songgang/project/imgfea/gccrel-x64nothread
BINDIR=/mnt/data1/tustison/Utilities/bin64/3D/float
BINDIR2=/mnt/data1/tustison/Utilities/bin64/3D/float
# DO=echo
# DO=myecho

function myecho
{
    echo
    echo $1
    # time $1
    $1
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

$DO $BINDIR/CalculateVolumeFromBinaryImage $LUNGMASKBIN 1 > $res_Volume
$DO $BINDIR/CalculateFirstOrderStatisticsFromImage $IMG $LUNGMASKBIN 1 > $res_FirstOrder
$DO $BINDIR/GenerateCooccurrenceMeasures $IMG $LUNGMASKBIN 1 > $res_Cooccur
$DO $BINDIR/GenerateRunLengthMeasures $IMG $LUNGMASKBIN 1 > $res_RLM

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


    $DO $EROBINDIR/GenerateErosionMask $LUNGMASKBIN 1 $IBMASK 1 $R

    res_IB_Volume=$RESDIR/res'-ib-P'$i'-Volume.txt'
    res_IB_FirstOrder=$RESDIR/res'-ib-P'$i'-FirstOrder.txt'
    res_IB_Cooccur=$RESDIR/res'-ib-P'$i'-Cooccur.txt'
    res_IB_RLM=$RESDIR/res'-ib-P'$i'-RLM.txt'
    
    $DO $BINDIR/CalculateVolumeFromBinaryImage $IBMASK  > $res_IB_Volume
    $DO $BINDIR/CalculateFirstOrderStatisticsFromImage $IMG $IBMASK 1 > $res_IB_FirstOrder
    $DO $BINDIR/GenerateCooccurrenceMeasures $IMG $IBMASK 1 > $res_IB_Cooccur
    $DO $BINDIR/GenerateRunLengthMeasures $IMG $IBMASK 1 > $res_IB_RLM



    $DO $EROBINDIR/SubtractImage $LUNGMASKBIN $IBMASK $OBMASK



    res_OB_Volume=$RESDIR/res'-ob-P'$i'-Volume.txt'
    res_OB_FirstOrder=$RESDIR/res'-ob-P'$i'-FirstOrder.txt'
    res_OB_Cooccur=$RESDIR/res'-ob-P'$i'-Cooccur.txt'
    res_OB_RLM=$RESDIR/res'-ob-P'$i'-RLM.txt'

    $DO $BINDIR/CalculateVolumeFromBinaryImage $OBMASK  > $res_OB_Volume
    $DO $BINDIR/CalculateFirstOrderStatisticsFromImage $IMG $OBMASK 1 > $res_OB_FirstOrder
    $DO $BINDIR/GenerateCooccurrenceMeasures $IMG $OBMASK 1 > $res_OB_Cooccur
    $DO $BINDIR/GenerateRunLengthMeasures $IMG $OBMASK 1 > $res_OB_RLM

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
    $DO $BINDIR/GeneratePercentileAttenuationMask $IMG $ATTMASK $att_lower $att_upper 1 $LUNGMASKBIN 1
    
    res_ATT_Volume=$RESDIR/res'-att-P'$i'-Volume.txt'
    res_ATT_FirstOrder=$RESDIR/res'-att-P'$i'-FirstOrder.txt'

    $DO $BINDIR/CalculateVolumeFromBinaryImage $ATTMASK  > $res_ATT_Volume
    $DO $BINDIR/CalculateFirstOrderStatisticsFromImage $IMG $ATTMASK 1 > $res_ATT_FirstOrder             

    $DO rm $ATTMASK
done


}

    
###############################
process_lobe_mask(){

    loblabel_list=(1 2 3 4) #radius for erosion
    num_label=${#loblabel_list[*]}
    for ((i=1; i <= num_label ; i++))
    do

        res_LOBE_Volume=$RESDIR/res'-lobe-P'$i'-Volume.txt'
        res_LOBE_FirstOrder=$RESDIR/res'-lobe-P'$i'-FirstOrder.txt'
        res_LOBE_Cooccur=$RESDIR/res'-lobe-P'$i'-Cooccur.txt'
        res_LOBE_RLM=$RESDIR/res'-lobe-P'$i'-RLM.txt'
    
        $DO $BINDIR/CalculateVolumeFromBinaryImage $LOBMASK $i > $res_LOBE_Volume
        $DO $BINDIR/CalculateFirstOrderStatisticsFromImage $IMG $LOBMASK $i > $res_LOBE_FirstOrder
        $DO $BINDIR/GenerateCooccurrenceMeasures $IMG $LOBMASK $i > $res_LOBE_Cooccur
        $DO $BINDIR/GenerateRunLengthMeasures $IMG $LOBMASK $i > $res_LOBE_RLM

    done

}


PRE=$IMGNAME
SEGMASK=$LUNGMASKBINNAME

echo input image: $IMG
echo input mask: $LUNGMASKBINNAME

echo "process whole lung"
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







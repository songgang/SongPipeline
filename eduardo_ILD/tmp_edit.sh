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
MYDO $BINDIR/CalculateFirstOrderStatisticsFromImage 3 $IMG $MASK 1 > $res_FirstOrder
MYDO $BINDIR/GenerateCooccurrenceMeasures 3 $IMG 3 1x0x0 0x1x0 0x0x1 $MASK 1 > $res_Cooccur
MYDO $BINDIR/GenerateRunLengthMeasures 3 $IMG 3 1x0x0 0x1x0 0x0x1 $MASK 1 > $res_RLM

}



echo "process Maya both outer+inner sphere lung mask"
tic
MAYABOTHMASK=$RESDIR/$LUNGNAME"_mayaboth"".nii.gz"
echo MAYABOTHMASK $MAYABOTHMASK
# label 2 is inner, label 1 is outer
if [ $ALEXLUNGMASK != "NotAvailable" ]
then
    MYDO $C3D $MAYALUNGMASK -threshold 1 2 1 0 $ALEXLUNGONLYMASK -times -o $MAYABOTHMASK
else
    echo $IMG "Alex whole lung mask not existed. Use the whole image domain as fake lung foreground for Maya's both spheres."
    MYDO $C3D $MAYALUNGMASK -threshold 1 2 1 0 -o $MAYABOTHMASK
fi
process_maya_both $IMG $MAYABOTHMASK $RESDIR
toc
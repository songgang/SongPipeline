#!/bin/bash

# combine several binary image files into one multiple-labels
# specifically:
# everything should be inside mask.img

# label:
#  aerotated: 1
#  airway: 2
#  vessel: 3

CURDIR=/mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/40i_20080918122237465_CT

MASK=$CURDIR/reg_exp2insp/mask_resampled.nii.gz
AIRWAY=$CURDIR/reg2_exp2insp/fixed_airway_resampled.nii.gz
VESSEL=$CURDIR/reg2_exp2insp/fixed_vessel_resampled.nii.gz
OUTPUT=$CURDIR/reg2_exp2insp/xml/fixed_mixed_seg.nii.gz
TMPIMG=$CURDIR/reg2_exp2insp/xml/tmp.nii.gz

LMASK=1
LAIRWAY=2
LVESSEL=3

# use c3d
C3D=/home/songgang/mnt/pkg/bin/c3d
IMDILATE=/home/songgang/mnt/cis537/myutil/gccrel/imdilate

# dilate the airways a little
$IMDILATE $AIRWAY 0.2 $TMPIMG

bash /mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/replace_label.sh $MASK $TMPIMG $LAIRWAY $OUTPUT

# a prepossing of the vessel image
# V(M)=0 or V .* M
$C3D $VESSEL $MASK -times -o $TMPIMG

bash /mnt/data/PUBLIC/data1/Data/Output/DrewWarrenLungData/ATCases/Dec_06_2008/script/replace_label.sh $OUTPUT $TMPIMG $LVESSEL $OUTPUT



#!/bin/bash

# compute the metric
# ExpB41f  ExpB50f  InspB41f  InspB50f

dome(){
    qsub -q mac -S /bin/bash -N $IMGNAME"-wmask.sh" -o $RESDIR -e $RESDIR -v IMG=$IMG,IMGNAME=$IMGNAME,RESDIR=$RESDIR,LUNGMASKBIN=$LUNGMASKBIN,LUNGMASKBINNAME=$LUNGMASKBINNAME,LOBMASK=$LOBMASK process_wmask.sh
    # . process_wmask.sh
}

IMG=/mnt/data2/PUBLIC/Data/Input/DrewCTLungs/ImageVolumes/ExpB41f.nii.gz
IMGNAME=ExpB41f
RESDIR=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_8_2008/ExpB41f
LUNGMASKBIN=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_3_2008/ExpB41f/ExpB41f-lungmaskbin.nii.gz
LUNGMASKBINNAME=ExpB41f-lungmaskbin
LOBMASK=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_3_2008/ExpB41f/ExpB41f-lobe.nii.gz

dome


IMG=/mnt/data2/PUBLIC/Data/Input/DrewCTLungs/ImageVolumes/ExpB50f.nii.gz
IMGNAME=ExpB50f
RESDIR=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_8_2008/ExpB50f-w-ExpB41f
LUNGMASKBIN=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_3_2008/ExpB41f/ExpB41f-lungmaskbin.nii.gz
LUNGMASKBINNAME=ExpB41f-lungmaskbin
LOBMASK=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_3_2008/ExpB41f/ExpB41f-lobe.nii.gz

dome

IMG=/mnt/data2/PUBLIC/Data/Input/DrewCTLungs/ImageVolumes/InspB41f.nii.gz
IMGNAME=InspB41f
RESDIR=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_8_2008/InspB41f
LUNGMASKBIN=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_3_2008/InspB41f/InspB41f-lungmaskbin.nii.gz
LUNGMASKBINNAME=InspB41f-lungmaskbin
LOBMASK=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_3_2008/InspB41f/InspB41f-lobe.nii.gz

dome

IMG=/mnt/data2/PUBLIC/Data/Input/DrewCTLungs/ImageVolumes/InspB50f.nii.gz
IMGNAME=InspB50f
RESDIR=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_8_2008/InspB50f-w-InspB41f
LUNGMASKBIN=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_3_2008/InspB41f/InspB41f-lungmaskbin.nii.gz
LUNGMASKBINNAME=InspB41f-lungmaskbin
LOBMASK=/mnt/data2/PUBLIC/Data/Results/DrewCTLungs/spiromics/Jul_3_2008/InspB41f/InspB41f-lobe.nii.gz

dome


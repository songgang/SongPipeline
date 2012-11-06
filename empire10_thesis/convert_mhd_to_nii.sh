#$ -S /bin/bash

# one-time script
# convert file formats in EMPIRE10 database from .mhd
# to .nii.gz for smaller file size
#
# INPUTROOTA: the original Empire10 file formats, in .mhd
# INPUTROOT: the local file formats, in .nii.gz
# and also the mask file names are changed 
#	from XX_Fixed.mhd to XX_FixedMask.nii.gz
#	from XX_Moving.mhd to XX_MovingMask.nii.gz
#
# Example:
bash /home/songgang/project/Empire10/Empire10_thesis/Script/SongPipeline/empire10_thesis/convert_mhd_to_nii.sh 01


IMAGENAME=$1

C3D=/home/songgang/pkg/bin/c3d

# INPUTROOTA=/home/songgang/project/Empire10/Empire10/Original
INPUTROOTA=/home/songgang/project/Empire10/Empire10/Original2/Onsite
INPUTROOT=/home/songgang/project/Empire10/Empire10_thesis/Input/original

if [ ! -d $INPUTROOT/scans ]
then
	mkdir -p $INPUTROOT/scans
fi

if [ ! -d $INPUTROOT/lungMasks ]
then
	mkdir -p $INPUTROOT/lungMasks
fi

FIXEDIMAGEA=$INPUTROOTA/scans/${IMAGENAME}_Fixed.mhd
FIXEDMASKA=$INPUTROOTA/lungMasks/${IMAGENAME}_Fixed.mhd
MOVINGIMAGEA=$INPUTROOTA/scans/${IMAGENAME}_Moving.mhd
MOVINGMASKA=$INPUTROOTA/lungMasks/${IMAGENAME}_Moving.mhd

FIXEDIMAGE=$INPUTROOT/scans/${IMAGENAME}_Fixed.nii.gz
FIXEDMASK=$INPUTROOT/lungMasks/${IMAGENAME}_FixedMask.nii.gz
MOVINGIMAGE=$INPUTROOT/scans/${IMAGENAME}_Moving.nii.gz
MOVINGMASK=$INPUTROOT/lungMasks/${IMAGENAME}_MovingMask.nii.gz

$C3D $FIXEDIMAGEA -o $FIXEDIMAGE
$C3D $FIXEDMASKA -o $FIXEDMASK
$C3D $MOVINGIMAGEA -o $MOVINGIMAGE
$C3D $MOVINGMASKA -o $MOVINGMASK


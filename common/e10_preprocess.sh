#$ -S /bin/sh

# 1. mask the lung out: original * lung mask
# 2. rescale the lung to 0 to 1
# 3. 1 - after rescaled
# 4. mask the lung out again (set background to be 0)

UTILITYDIRECTORY=/home/tustison/Utilities/bin64
C3D=/home/songgang/pkg/bin/c3d
ANTSDIRECTORY=/home/tustison/ANTS/bin64

DIMENSION=3

INPUTIMAGE=$1
MASKIMAGE=$2
OUTPUTPREFIX=$3
OUTPUTIMAGE=$4

$C3D $INPUTIMAGE $MASKIMAGE -times -o $OUTPUTPREFIX"tmp1.nii.gz"
${UTILITYDIRECTORY}/RescaleImageIntensity 3 $OUTPUTPREFIX"tmp1.nii.gz" $OUTPUTPREFIX"tmp2.nii.gz" 0 1
$C3D $OUTPUTPREFIX"tmp2.nii.gz" -scale -1 -shift 1 $MASKIMAGE -times -o $OUTPUTPREFIX"tmp3.nii.gz"
$ANTSDIRECTORY/ImageMath 3 $OUTPUTIMAGE PadImage $OUTPUTPREFIX"tmp3.nii.gz" 10


rm $OUTPUTPREFIX"tmp3.nii.gz"
rm $OUTPUTPREFIX"tmp2.nii.gz"
rm $OUTPUTPREFIX"tmp1.nii.gz"

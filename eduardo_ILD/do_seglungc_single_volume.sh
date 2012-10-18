SUBJECT=27
LUNGNAME=27I

INPUTIMAGE=/home/songgang/project/EduardoILD/Nifty/${SUBJECT}/${LUNGNAME}.nii.gz
RESDIR=/home/songgang/project/EduardoILD/Output/${SUBJECT}/${LUNGNAME}

FINALMASK=$RESDIR/${LUNGNAME}_smooth.nii.gz


if [ ! -d $RESDIR ]
then
	mkdir -p $RESDIR	
fi;

echo $FINALMASK
bash seglungc.sh $INPUTIMAGE $RESDIR $FINALMASK $LUNGNAME

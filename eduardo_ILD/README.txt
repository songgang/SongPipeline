notes for ILD sutype study.txt

* Oct 18

Needs 


* Oct 18

Visual inspection of UIP and non-UIP case
UIP severe: #27
non-UIP severe: # 19

visually i think it is difficult to tell the difference of the texture patter. both
exhibte ground glass patter. #17 has more background noise, which might comes from
the reconstruction kernel.

needs to consult Eduardo about his experience in telling these two images apart



* subject 27

There is a discrepency of image header of some mask

* subject 36

c3d cannot handle this image, need bigger c3d





* GenerateCooccurrenceMeasures and RLM has changed interface and output numbers
Need to update Matlab function when loading these values

* debug zero numbers in Calcuate First Order 

one-line running case:
debug_zeros_in_FirstOrder.sh


error outputs has zeros 
[/home/tustison/Utilities/bin64/CalculateFirstOrderStatisticsFromImage]
-647.23 203.502 -3.57725e+08 1.63229 5.29768 0 0 0 0 0 -1024 327


$ /home/tustison/Utilities/bin64/CalculateFirstOrderStatisticsFromImage
Usage: /home/tustison/Utilities/bin64/CalculateFirstOrderStatisticsFromImage imageDimension inputImage [labelImage] [label] [numberOfBins=100] [histogramFile]
  Output:  mean sigma sum skewness kurtosis entropy 5th% 95th% 5th%mean 95th%mean min max 


 * try recompile using nick's git code and itk new code
 * ok, seems Nick has changed some interface: need to call like

 Without the extra arguments after 1: 
$ CalculateFirstOrderStatisticsFromImage 3 img.nii.gz label.nii.gz 1 
[/home/songgang/project/tustison/Utilities/gccrel/CalculateFirstOrderStatisticsFromImage]
-647.23 203.502 -3.57725e+08 1.63229 5.29768 0 0 0 0 0 -1024 327 0 0


The correct way is:

$ CalculateFirstOrderStatisticsFromImage 3 img.nii.gz label.nii.gz 1
100 void_dump_file_for_image
[/home/songgang/project/tustison/Utilities/gccrel/CalculateFirstOrderStatisticsFromImage]
-647.23 203.502 -3.57725e+08 1.63229 5.29768 5.48414 -851.072 -151.751
-992.915 -5.88203 -1024 327 -706.515 0

I will use /tmp/LUNGNAME.tmp.txt as the file name for void_dump_file_for_image

* subject 1 only has 1I, no 1E

to segment lung for this subject, run
do_seglungc_single_volume.sh


* subject 27: 27I 

segmentation on 27I is not successul !! Has to skip or just use it as it is !!

* Alex's missing masks

There are 6 masks missing from Alex's refined masks:

 1 6 7 12 27 36 

First) 

 copy the automated mask from Output/ to AlexMask/
 and renamed from 1I_smooth.nii.gz 
 to 1I_manual_char.nii.gz

 Here are the one-line script:

A=/home/songgang/project/EduardoILD/Output; B=/home/songgang/project/EduardoILD/AlexMask; for a in 1 6 7 12 27 36; do echo $a; cp $A/$a/${a}I/${a}I_smooth.nii.gz $B/${a}I_manual_char.nii.gz; done;

Second) 
 
  modify the dblist to contain only these 6, and only run Alex mask for metric computation


bash command to replace whitespace to underscore
from stackoverflow:
	http://stackoverflow.com/questions/1806868/linux-replacing-spaces-in-the-file-names?rq=1

for file in *; do mv "$file" `echo $file | tr ' ' '_'` ; done

If it is a string (not a character), use sed:

for i in `ls *modified*`; do   mv "$i" `echo $i | sed -e 's/_modified//g'`; done



AlexMask:
	manual modification of the automated segmentation:
	0: background
	1: body
	2: right lung 
	3: left lung
	4: airway
	5: vessel

	./2I.nii.gz 
	only inspiration (*I.nii.gz) was segmented

Nifty:
	1/1I.nii.gz   subject 1 inspiration in Nifty file format
	subject 1 only has 1I, no 1E

	2/2I.nii.gz 2E.nii.gz, subject 2 has both inspiration and expiration
	each file rough size ~120M

Mask/unzip:
	each file is either named as:
	1I_label both lungs.nii.gz
	or
	2I_label both lungs modified.nii.gz

	Maya labeled the lungs with sphere structures on inside / outside. Eduardo/Maya reviewed and modified them.

	label 1: along lung paranchyma
	label 2: inside lung

MayaMask
	23I_label_both_lungs.nii.gz
	This is copied from Mask/unzip, whitespace changed to underscores and "_modified" removed

Output:
	the old results, using the ILD pipeline + auto segmentation. The old segmentation results are not satifactory. 

RawData:
	the original .cab file from Eduardo. May be deleted. ===========> to confirm with Eduardo







--------------------------------------------------------------------------------------------

Old log:

project log on Eduardo's feature selection

1. convert .cab to nifty

used perl with user input I/O of input/output directory names
No.1 data is corrupted

also see convert.log 


2. image feature analysis

tutorial: 
http://www.fp.ucalgary.ca/mhallbey/tutorial.htm

Nick's seems to change the interface of Cooccurrence and RLM features
There is an new para: offsets:

??? In Nick's GenerateCooccurrenceMeasures.cxx
Why set mask to all zeros? (solved, label is also zero by default


Nick's GeneratePercentileAttenuationMask.cxx is deprecated due to 
itkDenseFrequencyContainer is out of new statistics framework
Tried to set ITK_REVIEW and ITK_REVIEW_STATISTICS on,
but when Quantile = 1.0 the output will be nan, which is possible a bug

check with Eduaro if vessels have to be removed first

# MYDO $C3D $RESDIR/fixed_resampled.nii.gz -threshold -Inf -50 1 0 $OLDRESDIR/mask_resamp
led.nii.gz -multiply -o $RESDIR/aeroted_mask_resampled1.nii.gz


check with Nick about segmentation of whole lung in expiration data ???

# segmentation label in 2I_smooth.nii.gz
1: body
2: right lung
3: left lung
4: trachea
NEW: 5: vessel (coded in seglungc.sh)

Eduardo: what is a good threshold for vessels? -50 seems not good

directory structure:
subject/imagename/feature
1/1E/res_lobe.txt
1/1I/res_lobe.txt


lung segmentation -> image feature computation
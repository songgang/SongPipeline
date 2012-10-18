#!/usr/bin/perl

use Cwd;
use File::Basename;

$SEPARATEINI = "/home/songgang/mnt/project/FitzgeraldData/Script/Fitzdcm2nii.ini";
$NULLECHO = "";

open( LOG, ">convert.log" );

print "For Eduardo's ILD subtypes feature selection study:
Convert raw .cab files to DICOM to Nifty files 
current directory : " . getcwd() . "
";

print "
User: input original raw data top directory (\$INPUTDIR), for example:
\$INPUTDIR/19/E/***.cab
\$INPUTDIR/19/I/***.cab
Now enter \$INPUTDIR: 
";

#chomp($INPUTDIR=<STDIN>);
$INPUTDIR="/mnt/data/PUBLIC/data1/Data/Input/DrewWarrenLungData/ILD/RawData";
print '$INPUTDIR=' . $INPUTDIR. "\nhehe";

print "
User: what is your output dir for Nifty (\$OUTPUTDIR), for example, output .nii.gz will be stored as: 
\$OUTPUTDIR/19/E/19E.nii.gz
\$OUTPUTDIR/19/I/19I.nii.gz
(temporary DICOM slices will be stored as:
\$OUTPUTDIR/19/***.dcm
Now enter \$OUTPUTDIR:
";

#chomp($OUTPUTDIR=<STDIN>);
$OUTPUTDIR="/mnt/data/PUBLIC/data1/Data/Input/DrewWarrenLungData/ILD/Nifty";
#rint '$OUTPUTDIR=' . $OUTPUDR . "\n";

@subjects=<$INPUTDIR/*>;

foreach $a (@subjects) {
    if (-d $a) {
    	print "subject: $subject \n";
    	$subject=basename($a);
    	
	    @phases=<$a/*>;
    	foreach $b (@phases) {
    		$phase=basename($b);
    		print "phase: $phase \n";
    		
    		@cabfile=<$b/*.cab>;
    		
    		if ($#cabfile !=0) {
    			$n=$#cabfile+1;
    			print LOG "==> WARNING\n==> cab file directory: $b\n==> have $n instead of 1 *.cab files, will skip\n";
    			print LOG join('\n', @cabfile) . "\n";
    			next;
    		} 
    		
    		$cabfile = @cabfile[0];
    		
    		# extract cabfile to temp dicom directory
    		$dicom_output_dir = "$OUTPUTDIR/$subject/$phase/DICOM";
    		
    		if (! -d $dicom_output_dir) {
    			system("$NULLECHO mkdir -p $dicom_output_dir\n");
    		}
    		
    		system("$NULLECHO 7za e -o$dicom_output_dir $cabfile");
    		
    		$nifty_output_dir = "$OUTPUTDIR/$subject/$phase/NIFTY";
    		if (! -d $nifty_output_dir) {
    			system("$NULLECHO mkdir -p $nifty_output_dir\n");
    		}
    		
    		system("$NULLECHO dcm2nii -b $SEPARATEINI -o $nifty_output_dir $dicom_output_dir");
    		
    		@niifile = <$nifty_output_dir/*.nii.gz>;
    		if ( $#niifile == 0) {
    			# renaming nifty file
    			$niifile = @niifile[0];
    			$finalfile = "$OUTPUTDIR/$subject/$subject$phase.nii.gz";
    			system("$NULLECHO mv $niifile $finalfile");
    			
    		} else {
    			print LOG "==> WARNING\n==> converting dicom to nifty\n==> $dicom_output_dir \n==> $nifty_output_dir\n";
    			$nb = $#niifile + 1;
    			print LOG "==> have $nb instead of 1  *.nii.gz files\n ";
    		}
    		
#    		last;
    	}
    	
#    	last;
	    	
    }
#    last;
}



close(LOG);
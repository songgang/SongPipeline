#

# separate different dicom sequences according to their Dcm:SeriesDescription
# to lung pipeline friendly format

# match a SeriesNumber to a SeriesDescription

#!/usr/bin/perl -w
#
# Take a bunch of dicom files and sort them into a pipedream friendly format.
#

use strict;
use File::Basename;
use File::Path;
use File::Copy;

# use FindBin qw($Bin);

#my $a = "abc";
#my $b = "def";
#
#my $c = $a . " " . $b;
#print $c ."\n";
#
#return;

my $usage = qq {
  Usage: separate_dicom.sh <output_dir> <rename_files> <dicom_file1> ... <dicomfileN>

    <output_dir> - output base directory
 
    <rename_files> - 1 if you want to rename files (if possible) in the output directory, 0 otherwise.
      
    example: dicom2series.sh /home/user/data/subjectsDICOM/subject /home/user/data/raw/dicom/*

    White space and special characters in the protocol / file names will be removed or replaced with underscores.

    Output will be sorted into separate directories named by acquisition date. Within each date scans will be named as 
    SeriesNumber_ProtocolName. If <rename_files> == 1, the files will be called InstanceNumber_SeriesNumber_SeriesDescription. 
    Otherwise, file names are preserved (but spaces etc will still be removed).
    
    Common compressed file extensions will be preserved, so if your files end with something matching /gz|bz|zip|rar/ 
    (regardless of case), the extension will be copied even if <rename_files> == 1.. If you are compressing your files with 
    something unusual then you  will need to decompress before calling dicom2series or rename files after the fact. 
     
};


my %seqTable = ( # each item is a patient, and value is another hash for all sequences
#   "HUP3B03" => {   
#       "15" => "EXPIRATION  1.0  B41f", 
#       "16" => "somthing else" 
#   },
);




#addIntoSeqTable(\%seqTable, "HUP3B03", "15", "thehehehe");
#print_hash_of_hash(\%seqTable);
#return;



print $#ARGV . "\n";

if ( !( $#ARGV + 1 ) ) {
    print "$usage\n";
    exit 0;
}
elsif ( $#ARGV < 2 ) {
    die "ERROR: Missing arguments, run without args to see usage\n\t";
}

my ( $outputDir, $renameFiles, @dicomFiles ) = @ARGV;

my $imageMagickDir = $ENV{'IMAGEMAGICKPATH'};

if ( !-d "${outputDir}" ) {
    # mkpath("${outputDir}", {verbose => 1}) or die "cannot create output directory ${outputDir}";
}

# Array of files that cannot be correctly converted, typically due to missing header information
my @problemFiles;

my $cnt_total=0;
my $cnt_good=0;
foreach my $dicomFile (@dicomFiles) {

    #	my ( $isDicom, $missingInfo, $timepoint, $seriesDir, $newFileName ) = getFileInfo( $dicomFile, $renameFiles );
    $cnt_total++;


    my ( $isDicom, $missingInfo, $seriesNumber, $seriesDescription, $patientID, $convolutionKernel, $sliceThickness ) =
      getFileInfo2( $dicomFile, $renameFiles );

    # Make sure file really is dicom
    if ( !$isDicom ) {
        
        my $msg = "$dicomFile => ERROR: Skipping non DICOM file";
        print "$msg \n";
        push( @problemFiles, $msg);
        
        next;
    }

    if ($missingInfo) {
        my $msg = "$dicomFile => ERROR: Insufficient header information to process";
        print "$msg \n";
        push( @problemFiles, $msg);
        
        next;
    }

    my ( $breathingPhase, $sliceThickness2, $convolutionKernel2 ) = parseDescription($seriesDescription);
    my $sliceThicknessStr = getStr4Float($sliceThickness2);
    my $imgName = "${patientID}_${breathingPhase}_${convolutionKernel2}_${sliceThicknessStr}";

  
#    print "checking consistency ... \n";
#    print "seriesNumber: ($seriesNumber) \n"
#      . "seriesDescription: ($seriesDescription)\n"
#      . "patientID: ($patientID)\n"
#      . "convolutionKernel: ($convolutionKernel)\n"
#      . "sliceThickness: ($sliceThickness)\n";
#
#    print "parsing seriesDescription: \n"
#      . "breathingPhase: ($breathingPhase)\n"
#      . "sliceThickness2: ($sliceThickness2)\n"
#      . "convolutionKernel2: ($convolutionKernel2)\n";
#    
    my $a = eval("$sliceThickness - $sliceThickness2 == 0") ? "true" : "false";
    if ($a eq "false") {
        my $msg = "$dicomFile => ERROR: slickThickness and seriesDescription not consistent";
        print "$msg \n";
        push( @problemFiles, $msg);
        next;
    }
    
        
    
    addIntoSeqTable(\%seqTable, $patientID, $seriesNumber, $seriesDescription);
    $cnt_good++;
    
    my $newFileName;
    {
        my ( $fileBaseName, $dirName, $fileExtension ) = fileparse( $dicomFile, '\.[^.]*' );
        $newFileName="${imgName}.${fileBaseName}";    
    }
    
    
    
    
    my $newDir = "${outputDir}/${patientID}";
    my $newFilePath = "${newDir}/${newFileName}";
    
#    print "$dicomFile => ($patientID) ($seriesNumber) ($seriesDescription) => ($newFilePath)\n";
    
    
	if ( !-d $newDir  ) {
    	mkpath($newDir) or die "  Cannot create series directory $newDir";
	}

	if ( -f $newFilePath ) {
	    my $msg = "$dicomFile =>  WARNING: Multiple files map to $newFilePath";
        print "$msg\n";
		push( @problemFiles, $msg);
	}
	else {
#		print "$dicomFile -> $newFilePath\n";
		copy( $dicomFile, $newFilePath )  or die "Cannot copy files";
   }

}

print "\n------------------SUMMARY-----------------\n";
print "total DCM files parsed: $cnt_total\n";
print "good DCM files: $cnt_good\n";
print "patient and sequence table:\n";
print_hash_of_hash(\%seqTable);

if ( $#problemFiles > -1 ) {

    # There can be a lot of these so don't reprint them all
    #
        print "\nThe following dicom files could not be processed, most likely due to missing header information:\n";
    
        foreach my $problemFile (@problemFiles) {
    	print "$problemFile\n";
        }

#     print "WARNING: Some dicom files could not be processed, most likely due to missing header information\n\n";

}

#
# (isDICOM, missingInfo, acquisitionDate, seriesDir, newFileName) = getFileInfo($dcmFile, $renameFiles)
#
# If file is not DICOM, return an array of zeros.
#
# The new file name is either the original file name, or InstanceNumber_SeriesNumber_ProtocolName.
# If header data is missing, the old file name is preserved. If the information is available, the
# file is renamed if $renameFiles == 1.
#
sub getFileInfo {

    my ( $dcmFile, $renameFiles ) = @_;

    # parse the file name
    my ( $fileBaseName, $dirName, $fileExtension ) = fileparse( $dcmFile, '\.[^.]*' );

    # -ping should speed things up, hopefully without breaking anything
    # my $header = `${imageMagickDir}/identify -ping -verbose "$dcmFile" 2> /dev/null`;
    my $header = `identify -ping -verbose "$dcmFile" 2> /dev/null`;

    my $isDicom = 1;

    if ( !( $header =~ m/Format: DCM \(Digital Imaging and Communications in Medicine image\)/ ) ) {
        $isDicom = 0;

        return ( 0, 0, 0, 0, 0 );
    }

    # What to return if we can't map this file sensibly
    my @missingInfo = ( 1, 1, 0, 0, 0 );

    $header =~ m/[D|d]cm:AcquisitionDate:\s(\d+)/ or return @missingInfo;

    my $acquisitionDate = trim($1);

    # Some headers have missing instance numbers, as a fallback use original file name
    my $acquisitionNumber = "";

    if ( $header =~ m/[D|d]cm:Instance.*Number:\s(\d+)/ ) {
        $acquisitionNumber = trim($1);
        $acquisitionNumber = sprintf( "%.4d", $acquisitionNumber );
    }
    else {

        # Don't complain about this, but do not rename file if we don't have an instance number.
        $renameFiles = 0;
    }

    $header =~ m/[D|d]cm:SeriesNumber:\s(\d+)/ or return @missingInfo;

    my $seriesNumber = trim($1);
    $seriesNumber = sprintf( "%.4d", $seriesNumber );

    # No fallback here. If the protocol name is missing something is seriously wrong
    $header =~ m/[D|d]cm:ProtocolName:\s(.+)/ or return @missingInfo;

    my $protocolName = trim($1);

    # Allow [\w] in protocol names, nothing else
    # [\s,-] -> underscore.
    $protocolName =~ s/[,\s-]+/_/g;
    $protocolName =~ s/[^\w]//g;
    $protocolName =~ s/_+/_/g;

    my $seriesDir = join( '_', $seriesNumber, $protocolName );

    my $newFileName = $fileBaseName . $fileExtension;

    if ($renameFiles) {
        $newFileName = join( '_', $acquisitionNumber, $seriesNumber, $protocolName );

        # Regardless of file naming, preserve file extension if it indicates compression
        if ( $fileExtension =~ m/gz|bz|zip|rar/i ) {
            $newFileName = $newFileName . $fileExtension;
        }
    }

    # Remove special characters that can mess up unix
    #
    # \s and , -> underscore. Allow dashes. Everything else goes away
    $newFileName =~ s/[,\s-]+/_/g;

    # Begone, you demons of stupid file naming!
    $newFileName =~ s/[^\.\w]//g;

    # Finally, clear up multiple underscores
    $newFileName =~ s/_+/_/g;

    return ( ${isDicom}, 0, ${acquisitionDate}, ${seriesDir}, ${newFileName} );

}

sub trim {

    my ($string) = @_;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}

#
# (isDICOM, missingInfo, acquisitionDate, seriesDir, newFileName) = getFileInfo($dcmFile, $renameFiles)
#
# If file is not DICOM, return an array of zeros.
#
# The new file name is either the original file name, or InstanceNumber_SeriesNumber_ProtocolName.
# If header data is missing, the old file name is preserved. If the information is available, the
# file is renamed if $renameFiles == 1.
#
#
# get the following fields
#   Dcm:SeriesNumber:
#   Dcm:SeriesDescription:
#   Dcm:Patient'sID:
#   Dcm:ConvolutionKernel:
#   Dcm:SliceThickness

sub getFileInfo2 {

    my ( $dcmFile, $renameFiles ) = @_;

    # parse the file name
    my ( $fileBaseName, $dirName, $fileExtension ) = fileparse( $dcmFile, '\.[^.]*' );

    # -ping should speed things up, hopefully without breaking anything
    # my $header = `${imageMagickDir}/identify -ping -verbose "$dcmFile" 2> /dev/null`;
    my $header = `identify -ping -verbose "$dcmFile" 2> /dev/null`;

    my $isDicom = 1;

    if ( !( $header =~ m/Format: DCM \(Digital Imaging and Communications in Medicine image\)/ ) ) {
        $isDicom = 0;

        return ( 0, 0, 0, 0, 0, 0, 0 );
    }

    # What to return if we can't map this file sensibly
    my @missingInfo = ( 1, 1, 0, 0, 0, 0, 0 );

    $header =~ m/[D|d]cm:SeriesNumber:\s(\d+)/ or return @missingInfo;
    my $seriesNumber = trim($1);

    $header =~ m/[D|d]cm:SeriesDescription:\s(.+)/ or return @missingInfo;
    my $seriesDescription = trim($1);

    $header =~ m/[D|d]cm:Patient\'sID:\s(\w+)/ or return @missingInfo;
    my $patientID = trim($1);

    $header =~ m/[D|d]cm:ConvolutionKernel:\s(\w+)/ or return @missingInfo;
    my $convolutionKernel = trim($1);

    $header =~ m/[D|d]cm:SliceThickness:\s([0-9]*\.?[0-9]+)/ or return @missingInfo;
    my $sliceThickness = trim($1);
    
    
    
    #	my $newFileName = $fileBaseName . $fileExtension;
    #
    #	if ($renameFiles) {
    #		$newFileName = join( '_', $acquisitionNumber, $seriesNumber, $protocolName );
    #
    #		# Regardless of file naming, preserve file extension if it indicates compression
    #		if ( $fileExtension =~ m/gz|bz|zip|rar/i ) {
    #			$newFileName = $newFileName . $fileExtension;
    #		}
    #	}
    #
    #	# Remove special characters that can mess up unix
    #	#
    #	# \s and , -> underscore. Allow dashes. Everything else goes away
    #	$newFileName =~ s/[,\s-]+/_/g;
    #
    #	# Begone, you demons of stupid file naming!
    #	$newFileName =~ s/[^\.\w]//g;
    #
    #	# Finally, clear up multiple underscores
    #	$newFileName =~ s/_+/_/g;

    return ( $isDicom, 0, $seriesNumber, $seriesDescription, $patientID, $convolutionKernel, $sliceThickness );

}

sub parseDescription {

    my $seriesDescription = @_[0];
#    print "parse: $seriesDescription\n";

    my @args = split(/\s+/, $seriesDescription);

    my $breathingPhase     = @args[0];
    my $sliceThickness2    = @args[1];
    my $convolutionKernel2 = @args[2];

    return ( $breathingPhase, $sliceThickness2, $convolutionKernel2 );

}

sub getStr4Float {
        $_ = sprintf("%.2f", @_[0]);
        s/\./d/;
        return $_; 
}

sub print_hash_of_hash {
    while ( (my $key, my $value) = each %{$_[0]} ) {
        print "($key) => { \n";
            while ( (my $subkey, my $subvalue) = each %{$value}) {
                print "\t ($subkey) => ($subvalue)\n";
            }
        print "}\n";
    }
}


sub addIntoSeqTable {
    
    my $seqTable = @_[0]; # this is a reference
    my $patientID = @_[1];;
    my $sequenceID = @_[2];
    my $sequenceDesc =  @_[3];
    
#    print "checking if the sequence is already found ...\n";
    if ( exists $seqTable->{$patientID} && exists $seqTable->{$patientID}{$sequenceID} )  {
#            print "exist both patient and sequence \n";
            my $sequenceDescOld= $seqTable->{$patientID}{$sequenceID};
#            print $sequenceDescOld . "\n";
            if ($sequenceDescOld ne $sequenceDesc){
                print "NEW OLD sequenceDesc not match => ($sequenceDesc) ($sequenceDescOld)\n";
            }
    }  
    else {
#        print "no exist \n";
        $seqTable->{$patientID}{$sequenceID} = $sequenceDesc;
    }
    
#    print_hash_of_hash($seqTable);
    
   return $_[0];
    
    # print_hash_of_hash(\%seqTable);
}

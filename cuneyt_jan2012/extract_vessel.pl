#!/usr/bin/perl -w

use File::Basename;

$maskFile = $ARGV[0];
$outputDirectory = $ARGV[1];
$mhaDirectory = $ARGV[2];

# $maskFile="/home/songgang/project/Cuneyt/Jan2012/input/gzipped/ALVIN-PRE/SUPINE-10cm/MaskFiles/LLL-ALVIN-PRE-SUPINE-10cm.hdr";
# convert the mask file to the lobe and the vessel file
# $outputDirectory = "/home/songgang/project/Cuneyt/Jan2012/input/gzipped/ALVIN-PRE/SUPINE-10cm/test/";

# use backtick to trap the output of the system call

# $maskName = basename($maskFile);
($maskName, $dir, $ext) = fileparse($maskFile, '\..*');


$tmpPrefix = "tmp-$maskName";
$outputPrefix = "$maskName";

print "mask name is: $maskName\nmask input dir is: $dir\nmask ext is: $ext\n";
print "outputDirectory is $outputDirectory\n";
print "mhaDirectory is $mhaDirectory\n";
print "outputPrefix is $outputPrefix\n";
print "tmpPrefix is $tmpPrefix\n";
print "\n";

# system("/bin/gzip -f ${mhaDirectory}/${outputPrefix}_fulllobe.mha");
exit;


if (1)
{
  $msg = `/home/songgang/pkg/bin/c3d $maskFile -info`;


# matching the string: Image #1: dim = [512, 512, 360] ...
  if ($msg =~ /Image #1: dim = \[\d*, \d*, (\d*)\].*/)
  {
    $nbSlices = $1;
    print "slice number is $nbSlices!\n";
  }
  else 
  {
    print "exit from error-----------------------> cannot parse the number of slices\n";
    exit;
  }

# iterate over all the slices in the z direction
  for( $i = 0; $i < $nbSlices; $i++ )
  {
# extract the current slice

    print "current slice: $i\n";

    system("/home/songgang/pkg/bin/c3d", $maskFile, "-slice", "z", $i,  "-o", "${outputDirectory}/${tmpPrefix}${i}.nii.gz" );

    system("/home/songgang/pkg/bin/c3d ${outputDirectory}/${tmpPrefix}${i}.nii.gz -thresh 1 Inf 1 0 -o ${outputDirectory}/${tmpPrefix}${i}-binary.nii.gz");


    system("/home/tustison/Utilities/bin/FloodFill", 2,
      "${outputDirectory}/${tmpPrefix}${i}-binary.nii.gz", "${outputDirectory}/${tmpPrefix}${i}-fill.nii.gz",
      "-1", "0", "1", "1x1" );

    # get lobe mask, with all the vessels filled
    system("/home/songgang/pkg/bin/c3d ${outputDirectory}/${tmpPrefix}${i}-fill.nii.gz -scale -1 -shift 1 -o ${outputDirectory}/${tmpPrefix}${i}_fulllobe.nii.gz");

    # get blood vessel mask
    system("/home/songgang/pkg/bin/c3d ${outputDirectory}/${tmpPrefix}${i}-fill.nii.gz ${outputDirectory}/${tmpPrefix}${i}-binary.nii.gz -add -threshold 1 Inf 1 0 -o ${outputDirectory}/${tmpPrefix}${i}_vessels.nii.gz");

    system( "/home/tustison/Utilities/bin/FloodFill", 2,
      "${outputDirectory}/${tmpPrefix}${i}_vessels.nii.gz",
      "${outputDirectory}/${tmpPrefix}${i}_vessels.nii.gz",
      "1", "1", "0", "1x1" );

    system( "/home/tustison/Utilities/bin/ThresholdImage", 2,
      "${outputDirectory}/${tmpPrefix}${i}_vessels.nii.gz",
      "${outputDirectory}/${tmpPrefix}${i}_vessels.nii.gz", 1, 1, 0, 1 );
  }

# stacking all the vessel files into one 
  system( "/home/tustison/Utilities/bin/ConvertImageSeries", $outputDirectory,  "${tmpPrefix}%d_vessels.nii.gz", "${outputDirectory}/${outputPrefix}_vessels.nii.gz", 0, $nbSlices-1, 1);

  system("/home/songgang/pkg/bin/c3d $maskFile ${outputDirectory}/${outputPrefix}_vessels.nii.gz -copy-transform -o  ${outputDirectory}/${outputPrefix}_vessels.nii.gz");

# stacking all the lobe files into one 
  system( "/home/tustison/Utilities/bin/ConvertImageSeries", $outputDirectory,  "${tmpPrefix}%d_fulllobe.nii.gz", "${outputDirectory}/${outputPrefix}_fulllobe.nii.gz", 0, $nbSlices-1, 1);

  system("/home/songgang/pkg/bin/c3d $maskFile ${outputDirectory}/${outputPrefix}_fulllobe.nii.gz -copy-transform -o  ${outputDirectory}/${outputPrefix}_fulllobe.nii.gz");






# reset the header of the mask file to match with the original mask file
# get orientation code
  #
# matching the string: Image #1: dim = [512, 512, 360] ...
# $msg =~ /Image #1:.*orient = ([a-zA-Z]{3})/;
# $orieCode = $1;
# print "orie from the mask file is: $orieCode !\n";
# system("/home/songgang/pkg/bin/c3d ${outputDirectory}/${outputPrefix}_vessels.nii.gz -orient $orieCode -o  ${outputDirectory}/${outputPrefix}_vessels.nii.gz");

  # clean up the temp files
  system("rm ${outputDirectory}/${tmpPrefix}*.nii.gz");


  # convert to mha files
  system("/home/songgang/pkg/bin/c3d ${outputDirectory}/${outputPrefix}_vessels.nii.gz -o ${mhaDirectory}/${outputPrefix}_vessels.mha");

  # gzip them otherwise will running out quota
  system("/bin/gzip ${mhaDirectory}/${outputPrefix}_vessels.mha");


  system("/home/songgang/pkg/bin/c3d ${outputDirectory}/${outputPrefix}_fulllobe.nii.gz -o ${mhaDirectory}/${outputPrefix}_fulllobe.mha");

  system("/bin/gzip ${mhaDirectory}/${outputPrefix}_fulllobe.mha");

}

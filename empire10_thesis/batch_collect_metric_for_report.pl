#!/usr/bin/perl

# baseline benchmark for the Empire10 database
#
# To collect metric for each image to generate a sphnix documentation with R to plot curves

# basic point:
# 
# 1. reuse the parameters from Empire10 test 
# 2. a framework to dispatch
# 3. (TODO) a framework to collect data 
# 4. (TODO) a framework to generate a sphinx report


## main loop over all the tasks 
	# 1. a temporary script is generated for each node
	# 2. the script will iterate over the list of all images for each node
		# in the begining of the temporary script, 
		# first output the images names of the current node
		# then call the actual script to process the image 


use strict;
use Switch;
use File::Path;
use File::Basename;
use Data::Dumper;
use empire10;
use Scalar::Util qw(looks_like_number);

# this is for preprocess Input/tmp
# my $temp_execute_root = "/home/songgang/project/Empire10/Empire10_thesis/Input/tmp";

my $test_case = "baseline-register";
my $output_root="/home/songgang/project/Empire10/Empire10_thesis/Output/${test_case}";


my @image_tasks = define_image_tasks();
# my @image_tasks = define_image_tasks_one_image_per_taskB();
# my @image_tasks = define_image_tasks_debug_one_image();

# two steps:
# 1. iterate over all images
# collect .txt files for each image(pair)
# to get a .csv file for all images
# and a .readme file to explain,
# which might serve as the title of the table
# 2. generate sphinx documentation from .csv files


# collect registration time
# collect metric 1
# collect metric 2

my @image_list = ();
for(my $id_task=0; $id_task<@image_tasks; $id_task++) {
	my $current_node = $image_tasks[$id_task][0];
	my @current_image_list = @{$image_tasks[$id_task][1]};
	push(@image_list, @current_image_list);
}

print "image list:" . join(' ', @image_list) . "\n";


# open(OUTFILE, ">$current_script"); # begining of printing the 
open(OUTFILE, ">test.csv");
print OUTFILE "image, NeighborCC, NormalizedCC, PearsonCC, affineNeighborCC, affineNormalizedCC, affinePearsonCC\n";
for(my $id_image=0; $id_image<@image_list; $id_image++){
	my $current_image = $image_list[$id_image];

	my $metric_file = "$output_root/$current_image/${current_image}_${test_case}_fix2movmetricCC.txt";
	
	my $metric_gsyn_NeighborCC 		= get_scalar_value_in_the_next_line_of_keyword($metric_file, "NeighborhoodCorrelation");
	my $metric_gsyn_NormalizedCC 	= get_scalar_value_in_the_next_line_of_keyword($metric_file, "NormalizedCorrelation");
	my $metric_gsyn_PearsonCC 	= get_scalar_value_in_the_next_line_of_keyword($metric_file, "PearsonsCorrelation");

	my $metric_file = "$output_root/$current_image/${current_image}_${test_case}_fix2movmetricCC_affineonly.txt";	

	my $metric_affine_NeighborCC 	= get_scalar_value_in_the_next_line_of_keyword($metric_file, "NeighborhoodCorrelation");
	my $metric_affine_PearsonCC 	= get_scalar_value_in_the_next_line_of_keyword($metric_file, "PearsonsCorrelation");

	print OUTFILE "$current_image, $metric_gsyn_NeighborCC, $metric_gsyn_NormalizedCC, $metric_gsyn_PearsonCC, $metric_affine_NeighborCC, $metric_affine_NormalizedCC, $metric_affine_PearsonCC\n";
}

close(OUTFILE);	# end of printing the temporary script


# generate sphinx documentation

open RSTFILE, ">test.rst";
print RSTFILE
"**************************************

**image_list** ``\@image_list``

.. csv-table:: Frozen Delights!
	:header-rows: 1
	:file: test.csv

";
close RSTFILE; 

sub get_scalar_value_in_the_next_line_of_keyword($$) {
	my $filename = shift;
	my $keyword = shift;

	open ( INPUTFILE, "$filename") || return "File-not-found";
	my @content = <INPUTFILE>;
	close(INPUTFILE);

	my $p=0;
	my $ret = "N/A";
	while($p<scalar(@content)) {
		my $line = $content[$p];
		if ( $line eq '' ) {
			next;
		}
		$line =~ s/\r|\n//g;
		if ($line =~ /$keyword/) {
			$ret =$content[++$p];
			$ret =~ s/\r|\n//g;
			last;
		}
		$p++;
	}

	if (!looks_like_number($ret)) {
		$ret = "N/A";
	}

	return $ret;
}


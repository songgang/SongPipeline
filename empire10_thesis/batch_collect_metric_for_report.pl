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

# this is for preprocess Input/tmp
# my $temp_execute_root = "/home/songgang/project/Empire10/Empire10_thesis/Input/tmp";

# this is for preprocess Output/tmp
my $temp_execute_root = "/home/songgang/project/Empire10/Empire10_thesis/Output/tmp";
my $test_case = "baseline-register";
my $process_script = "/home/songgang/project/Empire10/Empire10_thesis/Script/SongPipeline/empire10_thesis/process_one_pair.sh";

# my @image_tasks = define_image_tasks();
# my @image_tasks = define_image_tasks_one_image_per_taskB();
my @image_tasks = define_image_tasks_debug_one_image();

# either of the following are good for print array
# of references of arrays
print_image_tasks(@image_tasks);
# print Dumper(@image_tasks);

for(my $id_task=0; $id_task<@image_tasks; $id_task++) {
	
	my $current_node = $image_tasks[$id_task][0];
	my @current_image_list = @{$image_tasks[$id_task][1]};

	print "DEBUG>> ====================================\n";
	print "DEBUG>> $current_node\n";	
	print "DEBUG>> @current_image_list \n";
	print "DEBUG>> $current_script \n";

	print "DEBUG>> ------------------------------------\n";
	open(OUTFILE, ">$current_script"); # begining of printing the 
	
	for (my $id_image=0; $id_image< scalar(@current_image_list); $id_image++ ) {		
		my $image_name = $current_image_list[$id_image];
		
		print OUTFILE "bash $process_script $image_name $test_case\n";
	}

	close(OUTFILE);	# end of printing the temporary script	
	print "DEBUG>> ------------------------------------\n";
	
}

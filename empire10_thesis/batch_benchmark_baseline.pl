#!/usr/bin/perl

# baseline benchmark for the Empire10 database
#

# 1. a downsampled version for debugging only
# 2. a fullsize version for 

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
my $serial_slots = 6;

# my %global_para = (
# 	test_case => $test_case,
# 	process_script => $process_script,
# 	);

my @image_tasks = define_image_tasks();
# my @image_tasks = define_image_tasks_one_image_per_taskB();
# my @image_tasks = define_image_tasks_debug_one_image();

# either of the following are good for print array
# of references of arrays
print_image_tasks(@image_tasks);
# print Dumper(@image_tasks);

for(my $id_task=0; $id_task<@image_tasks; $id_task++) {
	
	my $current_node = $image_tasks[$id_task][0];
	my @current_image_list = @{$image_tasks[$id_task][1]};

	my $current_exec_directory = "$temp_execute_root/$test_case/$current_node";
	my $current_script = "$current_exec_directory/do-${test_case}-${current_node}.sh";

	confirm_directory(dirname($current_script));

	print "DEBUG>> ====================================\n";
	print "DEBUG>> $current_node\n";	
	print "DEBUG>> @current_image_list \n";
	print "DEBUG>> $current_script \n";

	print "DEBUG>> ------------------------------------\n";
	open(OUTFILE, ">$current_script"); # begining of printing the temporary script
	# open(OUTFILE, ">-"); #debug: to the stdin

	print OUTFILE '#$ -S /bin/bash' . "\n\n";
	print OUTFILE "echo Script: $current_script\n";
	print OUTFILE "echo Node: $current_node\n";
	print OUTFILE "echo Image List: @current_image_list\n";
	print OUTFILE "\n";

	for (my $id_image=0; $id_image< scalar(@current_image_list); $id_image++ ) {		
		my $image_name = $current_image_list[$id_image];
		
		print OUTFILE "bash $process_script $image_name $test_case\n";
	}

	close(OUTFILE);	# end of printing the temporary script	
	print "DEBUG>> ------------------------------------\n";
	
	# start executing the script
	# print("cd $current_exec_directory; nohup /usr/bin/time ssh $current_node bash $current_script &" . "\n");
	# system("cd $current_exec_directory; nohup /usr/bin/time ssh $current_node bash $current_script &");

	my $exec_args = "";

	if (1) { # submit to qsub !!!!!
		if ($current_node =~ m/^compute-[01]-\d{1,2}/) { # a valid node example: compute-1-15
			$exec_args = "qsub -l hostname=$current_node -o $current_exec_directory -e $current_exec_directory -pe serial $serial_slots $current_script";
		} else { # no valide node given
			print "DEBUG>> $current_node : no valid node given for qsub, not specifying hostname in qsub\n";
			$exec_args = "qsub -o $current_exec_directory -e $current_exec_directory -pe serial $serial_slots $current_script";

		}
		print "$exec_args\n";
		system($exec_args);
	} else { # for debugging only
		print("bash $current_script\n");
		system("bash $current_script");
	}

}

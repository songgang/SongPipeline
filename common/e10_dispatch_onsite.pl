# dispatch the tasks for EMPIRE10
# for the onsite session

# pipeline
# 01.mhd
#		: rescale and padding
# 01_rescaled_padded.nii.gz
#		: do ants
#	E10_pGsyn_0_4_0TotalWarpxvec.nii.gz
# E10_pGsyn_0_4_0deformed.nii.gz
# 	: unpad
# E10_pGsyn_0_4_0TotalWarpUnpadedxvec.mhd/raw ???
#		: zip

# executation method
#  this perl script will generate a temp bash script for each image. In this script, each line executes a predefined .sh script
#  for example:
#  tmp_Do_something.sh
#    #! -S /bin/bash
#    bash XXXXX.sh imageA imageB
#    bash YYYYY.sh imageB imageC
#    bash ZZZZZ.sh 12 imageC imageD

#!/usr/bin/perl

use strict;
use Switch;
use File::Path;        # mkpath
use File::Basename;    # basename

# parameters
# 	directory names
#		Image pair
#   Similarity
# 	Transform
#		Regularization
# 	Iteration
# 	Others
#		Computing node

# directory need to confirm
# temp script, temp working for nohup
# rescaled
# registration
# submit

my $temp_execute_root = "/home/songgang/project/Empire10/Empire10/Script/onsite_gsyn";
my $test_case         = "gsyn";
my $output_root       = "/home/songgang/project/Empire10/Empire10/OutputOnsite";

my $temp_script_path_prefix = "${temp_execute_root}/tmp_${test_case}_";

my %global_para = (
	original_lung_directory => "/home/songgang/project/Empire10/Empire10/Original2/Onsite/scans",
	original_mask_directory => "/home/songgang/project/Empire10/Empire10/Original2/Onsite/lungMasks",

	preprocessed_image_directory => "${output_root}/Rescaled",
	preprocessed_postfix         => '_rescaled_padded.nii.gz',
	preprocessing_script         => "/home/songgang/project/Empire10/Empire10/Script/e10_preprocess.sh",

	registration_directory => "${output_root}/Output",
	registration_script    => "/home/songgang/project/Empire10/Empire10/Script/e10_register.sh",

	submit_directory => "${output_root}/Submit",
	packing_script   => "/home/songgang/project/Empire10/Empire10/Script/e10_pack.sh",

	test_case => $test_case,
);

my %registration_para = (
						  metric_type            => "CC",
						  radius                 => 2,
						  deformable_iterations  => "200x200x200x200x50",
						  use_recursive_gaussian => "false",
						  transformation_type    => "GreedySyN",
						  gradient_step          => 0.25,
						  regularization_type    => "Gauss",
						  gradient_sigma         => 6.0,
						  total_field_sigma => 0,
);


sub define_image_tasks() {
#  my @image_tasks = ( [ 'compute-0-3.local', [ '01' ] ] );
	my @image_tasks = ( [ 'compute-0-3.local', [ '21'] ] );
	push(@image_tasks, ( [ 'compute-0-13.local', [ '22'] ] ));
	push(@image_tasks, ( [ 'compute-1-12.local', [ '23'] ] ));
	push(@image_tasks, ( [ 'compute-0-8.local', [ '24' ] ] ));
	push(@image_tasks, ( [ 'compute-1-6.local', [ '25' ] ] ));
  push(@image_tasks, ( [ 'compute-1-8.local', [ '26' ] ] ));
	push(@image_tasks, ( [ 'compute-1-13.local', [ '27' ] ] ));
	push(@image_tasks, ( [ 'compute-0-4.local', [ '28' ] ] ));
	push(@image_tasks, ( [ 'compute-0-6.local', [ '29' ] ] ));
	push(@image_tasks, ( [ 'compute-0-9.local', [ '30' ] ] ));
			
	return @image_tasks;
}


my @image_tasks = define_image_tasks();
print "> defined image tasks: " . "\n";
print_image_tasks(@image_tasks);

for ( my $id_task = 0 ; $id_task < @image_tasks ; $id_task++ ) {
	my $current_node   = $image_tasks[$id_task][0];
	my $current_script = $temp_script_path_prefix . "${current_node}.sh";
	
	confirm_directory(dirname($current_script));
	

	open( OUTFILE, ">$current_script" );
	# open( OUTFILE, ">-" );
	print "--------------------------------\n";
	print $current_script . "\n";

	print OUTFILE '#$ -S /bin/sh' . " \n\n";
	for ( my $id_image = 0 ; $id_image <= $#{ $image_tasks[$id_task]->[1] } ; $id_image++ ) {

		my $image_name = $image_tasks[$id_task]->[1][$id_image];

		my $preprocessing_args = assemble_preprocess_script( \%global_para, $image_name );
		print OUTFILE $preprocessing_args . "\n";

		my $registration_args = assemble_registration_script( \%global_para, \%registration_para, $image_name );
		print OUTFILE $registration_args . "\n";

		my $packing_args = assemble_packing_script( \%global_para, $image_name );
		print OUTFILE $packing_args . "\n";
	}

	close(OUTFILE);

	my $current_exec_directory = "${temp_execute_root}/${current_node}";
	confirm_directory($current_exec_directory);

	print("cd $current_exec_directory; ssh $current_node bash $current_script \n");
	system("cd $current_exec_directory; nohup /usr/bin/time ssh $current_node bash $current_script &");

	# system("cd $current_exec_directory; nohup ssh $current_node bash $current_script &");

}



sub get_transformation {

	my $transformation;
	switch ( $_[0]{transformation_type} ) {
		case "GreedySyN" {
			$transformation = "SyN" . "[" . $_[0]{gradient_step} . "]";
		}
		case "TimeSyN" {
			$transformation =
			  "SyN" . "[" . $_[0]{gradient_step} . "," . $_[0]{time_step} . "," . $_[0]{integration_delta} . "]";
		}
		case "Exp" {
			$transformation = "Exp" . "[" . $_[0]{gradient_step} . "," . $_[0]{exp_time_steps} . "]";
		}
		case "GreedyExp" {
			$transformation = "GreedyExp" . "[" . $_[0]{gradient_step} . "," . $_[0]{exp_time_steps} . "]";
		}
		case "Elast" {
			$transformation = "Elast" . "[" . $_[0]{gradient_step} . "," . $_[0]{exp_time_steps} . "]";
		}
	}

	return $transformation;
}

sub get_regularization {

	my $regularization;

	switch ( $_[0]{regularization_type} ) {
		case "Gauss" {
			$regularization = "Gauss" . "[" . $_[0]{gradient_sigma} . "," . $_[0]{total_field_sigma} . "]";
		}
		case "DMFFD" {
			$regularization = "DMFFD" . "[" . $_[0]{DMMFD_points} . "," . "0]";
		}
	}
	
#	print $_[0]{regularization_type} . "\n";
#	print ">>>>>>>> reg: $regularization \n";

	return $regularization;
}

sub get_resigtration_directory_sub {
	my $registration_directory_sub = "$_[0]{registration_directory}/$_[0]{test_case}/$_[1]";
	return $registration_directory_sub;
}

sub assemble_packing_script() {

	if ( $#_ != 1 ) {
		my $func_name = ( caller(0) )[3];
		print "$func_name needs 1, not $#_ variables !\n ";
		return;
	}

	my $image_name                 = $_[1];
	my $registration_directory_sub = get_resigtration_directory_sub( $_[0], $image_name );
	my $output_prefix              = "$registration_directory_sub/E10_$_[0]{test_case}_${image_name}";
	my $original_fixed_image       = "$_[0]{original_lung_directory}/${image_name}_Fixed.mhd";
	my $submit_directory_sub       = "$_[0]{submit_directory}/$_[0]{test_case}/${image_name}";
	my $submit_tmp_prefix          = "${submit_directory_sub}/E10_${image_name}TotalWarp";
	my $original_moving_image      = "$_[0]{original_lung_directory}/${image_name}_Moving.mhd";

	print "submit_directory: " . $submit_directory_sub . "\n";
	confirm_directory($submit_directory_sub);

	my $args =
	  sprintf(   "bash $_[0]{packing_script}"
			   . " $output_prefix"
			   . " $original_fixed_image"
			   . " $submit_tmp_prefix"
			   . " $submit_directory_sub"
			   . " $original_moving_image"
			   . "\n" );

	return $args;
}

sub assemble_registration_script() {
	if ( $#_ != 2 ) {
		my $func_name = ( caller(0) )[3];
		print "$func_name needs 2, not $#_ variables! \n";
		return;
	}

	my $global_para       = $_[0];
	my $registration_para = $_[1];
	my $image_name        = $_[2];

	my $fixed_image  = "$_[0]{preprocessed_image_directory}/${image_name}_Fixed$_[0]{preprocessed_postfix}";
	my $moving_image = "$_[0]{preprocessed_image_directory}/${image_name}_Moving$_[0]{preprocessed_postfix}";
	my $fixed_mask   = "$_[0]{original_mask_directory}/${image_name}_Fixed.mhd";
	my $moving_mask  = "$_[0]{original_mask_directory}/${image_name}_Moving.mhd";

	my $affine_metric     = "MSQ[$fixed_mask,$moving_mask,1]";
	my $deformable_metric = "$_[1]{metric_type}" . "[" . "${fixed_image},${moving_image},1,$_[1]{radius}" . "]";

	my $deformable_iterations = $_[1]{deformable_iterations};

	my $transformation = get_transformation( $_[1] );
	my $regularization = get_regularization( $_[1] );

	my $use_recursive_gaussian = $_[1]{use_recursive_gaussian};

	my $registration_directory_sub = get_resigtration_directory_sub( $_[0], $image_name );

	my $output_prefix = "$registration_directory_sub/E10_$_[0]{test_case}_${image_name}";

	my $original_fixed_image = "$_[0]{original_lung_directory}/${image_name}_Fixed.mhd}";

	confirm_directory($registration_directory_sub);

	my $args_registration =
	  sprintf(   "bash $_[0]{registration_script}"
			   . " $output_prefix"
			   . " $affine_metric"
			   . " $deformable_iterations"
			   . " $transformation"
			   . " $regularization"
			   . " $deformable_metric"
			   . " $use_recursive_gaussian"
			   . " $fixed_image"
			   . " $moving_image"
			   . " \n " );
	return $args_registration;
}

sub assemble_preprocess_script() {

	if ( $#_ != 1 ) {
		my $func_name = ( caller(0) )[3];
		print "$func_name needs 1, not $#_ variables !\n ";
		return;
	}

	my $image_name = $_[1];

	my $args_fix =
	  sprintf(   "bash $_[0]{preprocessing_script}"
			   . " $_[0]{original_lung_directory}/${image_name}_Fixed.mhd"
			   . " $_[0]{original_mask_directory}/${image_name}_Fixed.mhd"
			   . " $_[0]{preprocessed_image_directory}/${image_name}_Fixed"
			   . " $_[0]{preprocessed_image_directory}/${image_name}_Fixed$_[0]{preprocessed_postfix}"
			   . " \n" );

	my $args_mov =
	  sprintf(   "bash $_[0]{preprocessing_script}"
			   . " $_[0]{original_lung_directory}/${image_name}_Moving.mhd"
			   . " $_[0]{original_mask_directory}/${image_name}_Moving.mhd"
			   . " $_[0]{preprocessed_image_directory}/${image_name}_Moving"
			   . " $_[0]{preprocessed_image_directory}/${image_name}_Moving$_[0]{preprocessed_postfix}"
			   . " \n" );

	confirm_directory( $_[0]{preprocessed_image_directory} );

	my $args = sprintf( "$args_fix" . "$args_mov" );

	return $args;

}

sub print_array() {

	#	if ( $#_ == -1 ) {
	#		my $func_name = ( caller(0) )[3];
	#		print "$func_name => no input directory name !" . " \n ";
	#		return;
	#	}

	foreach (@_) {
		print "$_ \n ";
	}

}

sub print_array_of_arrays() {

	for my $i ( 0 .. $#_ ) {
		print " [ @{ $_[$i] } ], \n ";
	}
}

sub print_image_tasks() {

	for my $i ( 0 .. $#_ ) {
		print "[$_[$i][0], @{$_[$i][1]}]\n";
	}
}


sub confirm_directory {

	if ( $#_ == -1 ) {
		my $func_name = ( caller(0) )[3];
		print "$func_name => no given input directory name !" . " \n ";
		return;
	}

	my $outDirectory = $_[0];

	if ( !-e $outDirectory ) {
		print " mkpath : $outDirectory " . "\n";
		mkpath($outDirectory);
	}
}

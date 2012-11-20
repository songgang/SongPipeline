package empire10;

use strict;
use warnings;
use Exporter;
use File::Path;

our @ISA = qw( Exporter );

# these CAN be exported.
our @EXPORT_OK = qw( );

# these are exported by default.
our @EXPORT = qw( export_me define_image_tasks  print_image_tasks confirm_directory define_image_tasks_one_image_per_task define_image_tasks_one_image_per_taskB define_image_tasks_debug_one_image );

sub export_me {
  print "hehe\n";
}

sub export_me_too {

}


sub define_image_tasks_one_image_per_task{
	my @image_tasks = ( ['n01', [qw(01)]]);
	push(@image_tasks, ['n02', [qw(02)]]);
	push(@image_tasks, ['n03', [qw(03)]]);
	push(@image_tasks, ['n04', [qw(04)]]);
	push(@image_tasks, ['n05', [qw(05)]]);
	push(@image_tasks, ['n06', [qw(06)]]);
	push(@image_tasks, ['n07', [qw(07)]]);
	push(@image_tasks, ['n08', [qw(08)]]);
	push(@image_tasks, ['n09', [qw(09)]]);
	push(@image_tasks, ['n10', [qw(10)]]);
	push(@image_tasks, ['n11', [qw(11)]]);
	push(@image_tasks, ['n12', [qw(12)]]);
	push(@image_tasks, ['n13', [qw(13)]]);
	push(@image_tasks, ['n14', [qw(14)]]);
	push(@image_tasks, ['n15', [qw(15)]]);
	push(@image_tasks, ['n16', [qw(16)]]);
	push(@image_tasks, ['n17', [qw(17)]]);
	push(@image_tasks, ['n18', [qw(18)]]);
	push(@image_tasks, ['n19', [qw(19)]]);
	push(@image_tasks, ['n20', [qw(20)]]);
	return @image_tasks;
}

sub define_image_tasks_one_image_per_taskB{
	my @image_tasks = ( ['n21', [qw(21)]]);
	push(@image_tasks, ['n22', [qw(22)]]);
	push(@image_tasks, ['n23', [qw(23)]]);
	push(@image_tasks, ['n24', [qw(24)]]);
	push(@image_tasks, ['n25', [qw(25)]]);
	push(@image_tasks, ['n26', [qw(26)]]);
	push(@image_tasks, ['n27', [qw(27)]]);
	push(@image_tasks, ['n28', [qw(28)]]);
	push(@image_tasks, ['n29', [qw(29)]]);
	push(@image_tasks, ['n30', [qw(30)]]);
	return @image_tasks;
}

sub define_image_tasks_debug_one_image{
	my @image_tasks = ( ['a01', [qw(05)] ] );
}
sub define_image_tasks {

	# @image_tasks define the pair of a computing node and the list
	# of images to run. This can be used to control inddividual 
	# assignments to the cluster
	# [node_name, [image_name_1, image_name_2, ... ]]
	# if node_name is not like 'compute-XXX', 
	#  this means it will automatically use the node from qsub
	# otherwise, it will submit directly to the specified node compute-XXX
	# but in any case, 
	#
	# MAKE SURE node_names ARE UNIQUE !!!!!!!!!!!!!!!!!!!!!
	#
	# otherwise, it will overwrite the temp execution directory of the last node 
	# of same names. The temp execution directories are named by the nodes !!!

	# perl grammar: array of reference of arrays
	# @image_tasks is an array of references
	# square bracket is the reference of the array

	# my @image_tasks = ( ['acompute-0-3', [qw(21 22 23)]]);
	# push(@image_tasks, ['bcompute-0-4', [qw(31 32 33)]]);
	# push(@image_tasks, ['compute-0-5', [qw(51 52 53 54)] ]);

	my @image_tasks = ( ['n01', [qw(01)]]);
	push(@image_tasks, ['n02', [qw(02)]]);
	push(@image_tasks, ['n03', [qw(03)]]);
	push(@image_tasks, ['n04', [qw(04)]]);
	push(@image_tasks, ['n05', [qw(05)]]);
	push(@image_tasks, ['n06', [qw(06)]]);
	push(@image_tasks, ['n07', [qw(07)]]);
	push(@image_tasks, ['n08', [qw(08)]]);
	push(@image_tasks, ['n09', [qw(09)]]);
	push(@image_tasks, ['n10', [qw(10)]]);
	push(@image_tasks, ['n11', [qw(11)]]);
	push(@image_tasks, ['n12', [qw(12)]]);
	push(@image_tasks, ['n13', [qw(13)]]);
	push(@image_tasks, ['n14', [qw(14)]]);
	push(@image_tasks, ['n15', [qw(15)]]);
	push(@image_tasks, ['n16', [qw(16)]]);
	push(@image_tasks, ['n17', [qw(17)]]);
	push(@image_tasks, ['n18', [qw(18)]]);
	push(@image_tasks, ['n19', [qw(19)]]);
	push(@image_tasks, ['n20', [qw(20)]]);	
	push(@image_tasks, ['n21', [qw(21)]]);
	push(@image_tasks, ['n22', [qw(22)]]);
	push(@image_tasks, ['n23', [qw(23)]]);
	push(@image_tasks, ['n24', [qw(24)]]);
	push(@image_tasks, ['n25', [qw(25)]]);
	push(@image_tasks, ['n26', [qw(26)]]);
	push(@image_tasks, ['n27', [qw(27)]]);
	push(@image_tasks, ['n28', [qw(28)]]);
	push(@image_tasks, ['n29', [qw(29)]]);
	push(@image_tasks, ['n30', [qw(30)]]);

	return @image_tasks;
}

sub print_image_tasks {
	for my $i ( 0 .. $#_ ) {
		print "[node: $_[$i][0], images: @{$_[$i][1]}]\n";
	}
}

sub confirm_directory {
	# return;
	# $#_ is the total number of input arguments (as an array)
	if ($#_ == -1) {
		my $func_name = ( caller(0) )[3];
		print "$func_name => no given input direcotry name !\n";
		return;
	}

	my $outDirectory = $_[0];

	if (! -e $outDirectory) {
		print "running: mkpath $outDirectory \n";
		mkpath($outDirectory)
	}
}
#!/usr/bin/perl

$outputDir = '/home/songgang/project/Cuneyt/Jan2012/output';#'/home/tustison/Data/TakahashiDogData/AdditionalData/ImageVolumes/';

$dogs[0] = 'ALVIN';
push @dogs, 'BARTLETT';
push @dogs, 'CLYDE';
push @dogs, 'DALLAS';
push @dogs, 'EVANT';
push @dogs, 'FLINT';
push @dogs, 'GILMER';

$timings[0] = 'PRE';
push @timings, 'POST';

$positionsA[0] = 'SUPINE';
push @positionsA, 'PRONE';

$regcase = 'fix-30cm-mov-10cm';

$lobes[0] = 'LUL';
push @lobes, 'LML';
push @lobes, 'LLL';
push @lobes, 'RUL';
push @lobes, 'RML';
push @lobes, 'RLL';
push @lobes, 'RCL';
push @lobes, 'lung';

$strains[0] = 'PS1';
push @strains, 'PS2';
push @strains, 'PS3';
push @strains, 'DSxx';
push @strains, 'DSyy';
push @strains, 'DSzz';
push @strains, 'DSxy';
push @strains, 'DSxz';
push @strains, 'DSyz';


foreach $dog (@dogs) {
  $resultsFile = "${outputDir}/${dog}_results.csv";

  open( RESULTS, ">${resultsFile}" );
#  open( RESULTS, ">-" );

  print "Writing $resultsFile\n";
  print RESULTS 'measurement, ' . join(', ', map { ($_.'_mean', $_.'_std')} (@lobes) ) . "\n"; 

  foreach $timing (@timings){

    if ( $timing eq 'PRE' ) {
      @positions=qw(SUPINE);

    }elsif ( $timing eq 'POST' ) {
      @positions=qw(SUPINE PRONE);
    }


    foreach $position (@positions) {
      foreach $strain (@strains) {
        @v=();
        foreach $lobe (@lobes) {
          $file = "${outputDir}/${dog}-${timing}/${position}-$regcase/${dog}-${timing}-${position}-${regcase}_${strain}_${lobe}.txt";

          if ( -e $file ) {
            open( FILE, $file );
            chomp( @lines = (<FILE>) );
            close FILE;
            @stats = split( / /, $lines[1] );
            push @v, ${stats[0]}, ${stats[1]};
          }
          else {
            push @v, '0', '0';
          }
        }
        print RESULTS "$timing-$position-$strain, " . join(', ', @v) . "\n";
      }
    }
  }
}

exit;



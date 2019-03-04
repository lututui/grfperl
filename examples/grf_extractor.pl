#!perl

package grf_extractor;

use strict;

use FindBin qw($RealBin);
use lib "$RealBin/../";
use GRFPerl::GRF;

sub main {
	my ($file, @targets) = @_;
	
	die getUsage() if (not defined $file or not $file or not scalar @targets);
	die "File not found: $file" if (not -e $file or not -f $file);
	die "File is empty: $file" if (-z $file);
	
	GRFPerl::GRF->build($file)->extract(@targets);
}

main(@ARGV);

sub getUsage {
	die "TODO";
}

1;